"""
This is the DAG to execute the ga4 wom daily kpi objects
"""
from bigdata.utils.gcp_extractMetadataFromMySQL import BQTableDtls
from airflow.models import DAG, Variable
from datetime import datetime, timedelta, date
from dateutil.relativedelta import relativedelta
from bigdata.utils.airflow_factory import *
from airflow.operators.dummy_operator import DummyOperator
import sys

tmpl_search_path = Variable.get("bigdata_sql_loc")

default_args = {
    "start_date": datetime(2020, 9, 12),
    "owner": "p_bd_ms_etl_svc",
    "email": ['BigData_Dev@pch.com'],
    "email_on_retry": False,
    "run_as_user": "p_bd_ms_etl_svc",
    "max_active_runs": 1,
    "bigquery_conn_id": "gcs_uat_conn"
}

dag_name_dtls = {'dag_name': "goldCore_ga4_wom_kpi_raw_objects_mnthly_bld"}

object_properties_json = "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/variables/group_binding_id_105/json_124.json"

# Reading the values from the json properties file
object_details = BQTableDtls(object_properties_json)

# Main logic begins here
########################

# Now creating a dict to capure the metadata connecting to the ObjectID
object_id_macros_dict = {}

for i in object_details.object_id_list_sorted:
    object_details.recon_start_limit = i
    object_details.recon_end_limit = i
    object_details.object_id = i
    
    recon_start_dt = str((date.today().replace(day=1)) - relativedelta(months=int(object_details.recon_start_limit)))

    if object_details.recon_start_limit == 0:
        recon_end_dt = date.today()
    else:
        recon_end_dt = str(((date.today().replace(day=1)) - relativedelta(months=int(object_details.recon_end_limit))) - timedelta(days = 1))

    object_id_macros_dict[f'{object_details.object_id}_recon_start_dt'] = recon_start_dt
    object_id_macros_dict[f'{object_details.object_id}_recon_end_dt'] = recon_end_dt


def getObjValue(object_id):
    return object_id_macros_dict[object_id]


dag = DAG(dag_id=dag_name_dtls['dag_name'], schedule_interval=None
          , default_args=default_args, catchup=False, tags=["ga4_wom"]
          , user_defined_macros={'get_macro_value': getObjValue}, template_searchpath=tmpl_search_path)

start_task = DummyOperator(task_id="start_task", dag=dag)
end_task = DummyOperator(task_id="end_task", retries=1, retry_delay=timedelta(seconds=10), dag=dag)
backfill_run_id = "{{ run_id }}"

# Defining a intermediate variable
counter = 0
prev_exec_id = "-1"

for i in object_details.object_id_list_sorted:
    object_details.exec_order = i
    object_details.airflow_control_flag = i
    object_details.airflow_mapping_id = i
    object_details.gcp_conn_var = i
    object_details.gcp_schema_final = i
    object_details.object_name = i
    object_details.gcp_partition_cols = i
    object_details.gcp_cluster_cols = i
    object_details.gcp_conn_bigdata_etl_metadata = i
    object_details.frequency = i
    object_details.subjectarea_name = i
    object_details.project_name = i
    object_details.vw_sql_loc = i
    object_details.load_type = i

    if object_details.exec_order != prev_exec_id:
        exec_order_task_start = DummyOperator(task_id="i" + str(object_details.exec_order), dag=dag)
        exec_order_task_end = DummyOperator(task_id="j" + str(object_details.exec_order), dag=dag)

    if object_details.airflow_control_flag == "NoByPass":
        if object_details.load_type == "FULL":
            tgt_load = gcp_FromExtSQLFileExecQuery("i" + str(object_details.exec_order) + "_tgt_full"
                                                   , object_details.object_name
                                                   , object_details.vw_sql_loc
                                                   + "full_load"
                                                   , object_details.gcp_conn_var
                                                   , dag)
        else:
            tgt_load = gcp_FromExtSQLFileExecQuery("i" + str(object_details.exec_order) + "_tgt_full"
                                                   , object_details.object_name
                                                   , object_details.vw_sql_loc
                                                   + "incr_load"
                                                   , object_details.gcp_conn_var
                                                   , dag)
        insert_sql = f"insert into gcp_airflow_lastrun(airflow_mapping_id, airflow_backfill_id" \
                     f", exec_status, exec_start_ts, exec_end_ts" \
                     f", insert_dt) values('{object_details.airflow_mapping_id}', '{backfill_run_id}'" \
                     f", 'Success'" \
                     f", cast(REPLACE(SUBSTR('{backfill_run_id}'" \
                     f",INSTR('{backfill_run_id}','2'),19),\"T\",\" \") as datetime)" \
                     f",CURRENT_TIMESTAMP,CURRENT_DATE)"

        mySQLInsertTask = gcp_mysqlDMLOperator("i" + str(object_details.exec_order)
                                               , object_details.object_name, insert_sql
                                               , object_details.gcp_conn_bigdata_etl_metadata, dag)

        bq_sql_exec = f"select 'bigdata' as team,'online_etl' as process_type,'uat' as environment," \
                      f"'airflow' as tool,'{object_details.subjectarea_name}' as subject_area," \
                      f"'{object_details.project_name}' as project_name," \
                      f"'{object_details.gcp_schema_final}' as dataset_name," \
                      f"'{object_details.object_name}' as object_name," \
                      f"'{object_details.frequency}' as frequency,'success' as exec_status," \
                      f"'na' as boundary_value" \
                      f",cast(DATETIME(CURRENT_TIMESTAMP,\"America/New_York\") as timestamp) as insert_ts"

        bqSqlExecOutAppndTask = gcp_sql_exec_bq_append("i" + str(object_details.exec_order)
                                                       , object_details.object_name
                                                       , object_details.gcp_conn_var
                                                       , 'uat-gold-core'
                                                       , 'it_etl_monitoring'
                                                       , 'bigdata_etl_logging'
                                                       , bq_sql_exec
                                                       , dag)
        if counter == 0:
            start_task >> exec_order_task_start
            exec_order_task_start >> tgt_load
        else:
            if object_details.exec_order == prev_exec_id:
                exec_order_task_start >> tgt_load
            else:
                prev_exec_order >> exec_order_task_start
                exec_order_task_start >> tgt_load

        tgt_load >> mySQLInsertTask
        mySQLInsertTask >> bqSqlExecOutAppndTask
        bqSqlExecOutAppndTask >> exec_order_task_end

    else:
        if counter == 0:
            start_task >> exec_order_task_start
            exec_order_task_start >> exec_order_task_end
        else:
            if object_details.exec_order != prev_exec_id:
                prev_exec_order >> exec_order_task_start
                exec_order_task_start >> exec_order_task_end

    prev_exec_order = exec_order_task_end
    prev_exec_id = object_details.exec_order
    counter += 1

if counter == object_details.length_list:
    exec_order_task_end >> end_task
