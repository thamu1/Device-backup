"""
Code Author: Prashant Basa
Code Developed Date: 2022-05-31
Code Modified Date: 2022-05-31

Generic script to execute just a single external query.
Query pattern to support:
1) Executing a SP
2) Merge Command
3) Truncate Command
4) Delete Command
5) Update Command

The SQL file needs to be named as "bq_exec_query.sql" in the sql location directory

Arguments to pass:
1) Argument1: Dag
2) Argument2: Dag Details
3) Argument3: Default Args
4) Argument4: the object_properties_json file
"""


object_properties_json = ""


from bigdata.utils.gcp_extractMetadataFromMySQL import BQTableDtls
from bigdata.utils.airflow_factory import *
from airflow.operators.dummy_operator import DummyOperator
from datetime import date, datetime, timedelta
from airflow.models.baseoperator import chain
import sys
from airflow.models import Variable
from airflow.models import DAG


tmpl_search_path = Variable.get("bigdata_sql_loc")

dag_name_dtls = {'dag_name': "prod_GoldCore_email_activity_phase2"}

default_args = {
    "start_date": datetime(2020,9,1),
    "owner": "p_bd_ms_etl_svc",
    "email": ['BigData_Dev@pch.com'],
    "email_on_retry": False,
    "run_as_user": "p_bd_ms_etl_svc",
    # "max_active_runs": 1
}

getObjValue = {} # ==============> 

dag = DAG(dag_id=dag_name_dtls['dag_name'],
        schedule_interval=None, 
        default_args=default_args, catchup=False,
        tags=["tdmmlog"],
        user_defined_macros={'get_macro_value': getObjValue}, 
        template_searchpath=tmpl_search_path,
        description='ga4 compute',
        )



def _getObjectDetails():
        object_details = BQTableDtls(object_properties_json)
        return object_details

def prepareDag():
    
    object_details = _getObjectDetails()
    backfill_run_id = "{{ run_id }}"

    # Defining a intermediate variable
    counter = 0
    prev_exec_id = "-1"
    
    
    sql_exec = []
    sp_exec = []
    mysql_dml = []
    bq_dml = []
    
                
    start_task = DummyOperator(task_id="start_task", dag=dag)
    end_task = DummyOperator(task_id="end_task", retries=1, retry_delay=timedelta(seconds=10), dag=dag)

    for i in object_details.object_id_list_sorted:
        
        object_details.exec_order = i
        object_details.airflow_control_flag = i
        object_details.airflow_mapping_id = i
        object_details.gcp_conn_var = i
        object_details.object_name = i
        object_details.gcp_partition_cols = i
        object_details.gcp_cluster_cols = i
        object_details.gcp_schema_intermediate = i
        object_details.gcp_schema_final = i
        object_details.gcp_conn_bigdata_etl_metadata = i
        object_details.load_type = i
        object_details.vw_sql_loc = i
        object_details.project_name = i
        object_details.recon_start_limit = i
        object_details.recon_end_limit = i
        object_details.frequency = i
        object_details.subjectarea_name = i
        
        
        
        recon_start_limit = date.today - timedelta(days=object_details.recon_start_limit) 
        recon_end_limit = date.today - timedelta(days=object_details.recon_end_limit) 
        
        getObjValue[f'{object_details.object_name}_recon_start_limit'] = recon_start_limit
        getObjValue[f'{object_details.object_name}_recon_end_limit'] = recon_end_limit
        
        # ========>   "{{get_macro_value('recon_start_limit')}}"
        # ========>   "{{get_macro_value('recon_end_limit')}}"
        
        # recon_start_limit = recon_start_limit.strftime("%Y%m%d")
        # recon_end_limit = recon_end_limit.strftime("%Y%m%d")

        if object_details.exec_order != prev_exec_id:
            exec_order_task_start = DummyOperator(task_id="i" + str(object_details.exec_order), dag=dag)
            exec_order_task_end = DummyOperator(task_id="j" + str(object_details.exec_order), dag=dag)

        if object_details.airflow_control_flag == "NoByPass":
            
            
            bq_query_exec_task = gcp_FromExtSQLFileExecQuery("i" + str(object_details.exec_order) + str(object_details.object_name) + "_bq_exec"
                                    , object_details.object_name + "_1"
                                    , object_details.vw_sql_loc
                                    + "full"
                                    , object_details.gcp_conn_var
                                    , dag)
            
            sql_exec.append(bq_query_exec_task)

            sp_call_ingest_to_final = gcp_FromExtSQLFileExecQuery("i" + str(object_details.exec_order) + str(object_details.object_name) + "_sp_exec"
                                        , object_details.object_name + "_1"
                                        , object_details.vw_sql_loc
                                        + "incremental"
                                        , object_details.gcp_conn_var
                                        , dag)
            
            sp_exec.append(sp_call_ingest_to_final)
            
            if(object_details.object_name == "ga4_wom_agg"):
                
                bq_query_exec_for_agg_session_full = gcp_FromExtSQLFileExecQuery("i" + str(object_details.exec_order) + str(object_details.object_name) + "_sp_exec"
                                            , object_details.object_name + "_1"
                                            , object_details.vw_sql_loc
                                            + "minor_incremental"
                                            , object_details.gcp_conn_var
                                            , dag)
                
                bq_query_exec_for_agg_session_incre = gcp_FromExtSQLFileExecQuery("i" + str(object_details.exec_order) + str(object_details.object_name) + "_sp_exec"
                                            , object_details.object_name + "_1"
                                            , object_details.vw_sql_loc
                                            + "minor_incremental"
                                            , object_details.gcp_conn_var
                                            , dag)
                
                bq_query_exec_for_agg_load_full = gcp_FromExtSQLFileExecQuery("i" + str(object_details.exec_order) + str(object_details.object_name) + "_sp_exec"
                                            , object_details.object_name + "_1"
                                            , object_details.vw_sql_loc
                                            + "minor_incremental"
                                            , object_details.gcp_conn_var
                                            , dag)
                
                bq_query_exec_for_agg_load_incre = gcp_FromExtSQLFileExecQuery("i" + str(object_details.exec_order) + str(object_details.object_name) + "_sp_exec"
                                            , object_details.object_name + "_1"
                                            , object_details.vw_sql_loc
                                            + "minor_incremental"
                                            , object_details.gcp_conn_var
                                            , dag)
                
                bq_query_exec_for_agg_inter_load_incre = gcp_FromExtSQLFileExecQuery("i" + str(object_details.exec_order) + str(object_details.object_name) + "_sp_exec"
                                            , object_details.object_name + "_1"
                                            , object_details.vw_sql_loc
                                            + "minor_incremental"
                                            , object_details.gcp_conn_var
                                            , dag)
                


            # Creating a MySQL Success Entry Task
            insert_sql = f"insert into gcp_airflow_lastrun(airflow_mapping_id, airflow_backfill_id" \
                            f", exec_status, exec_start_ts, exec_end_ts" \
                            f", insert_dt) values('{object_details.airflow_mapping_id}', '{backfill_run_id}'" \
                            f", 'Success'" \
                            f", cast(REPLACE(SUBSTR('{backfill_run_id}'" \
                            f",INSTR('{backfill_run_id}','2'),19),\"T\",\" \") as datetime)" \
                            f",CURRENT_TIMESTAMP,CURRENT_DATE)"

            mySQLInsertTask = gcp_mysqlDMLOperator("i" + str(object_details.exec_order) + str(object_details.object_name)+"mysql"
                                                    , object_details.object_name, insert_sql
                                                    , object_details.gcp_conn_bigdata_etl_metadata, dag)

            mysql_dml.append(mySQLInsertTask)
            
            # Creating the BigQuery Success Entry Task
            bq_sql_exec = f"select 'bigdata' as team,'online_etl' as process_type,'uat' as environment," \
                            f"'airflow' as tool,'{object_details.subjectarea_name}' as subject_area," \
                            f"'{object_details.project_name}' as project_name," \
                            f"'{object_details.gcp_schema_final}' as dataset_name," \
                            f"'{object_details.object_name}' as object_name," \
                            f"'{object_details.frequency}' as frequency,'success' as exec_status," \
                            f"'na' as boundary_value" \
                            f",cast(DATETIME(CURRENT_TIMESTAMP,\"America/New_York\") as timestamp) as insert_ts"

            bqSqlExecOutAppndTask = gcp_sql_exec_bq_append("i" + str(object_details.exec_order) + str(object_details.object_name)+"gcp"
                                                            , object_details.object_name
                                                            , object_details.gcp_conn_var
                                                            , 'uat-gold-core'
                                                            , 'it_etl_monitoring'
                                                            , 'bigdata_etl_logging'
                                                            , bq_sql_exec
                                                            , dag)

            bq_dml.append(bqSqlExecOutAppndTask)


    chain(start_task, sql_exec, bq_query_exec_for_agg_session_full, bq_query_exec_for_agg_load_full,
          
          sp_exec, bq_query_exec_for_agg_session_incre, bq_query_exec_for_agg_load_incre, 
          bq_query_exec_for_agg_inter_load_incre,
          
          mysql_dml, bq_dml, end_task      
          )


prepareDag()

    #         if counter == 0:
    #                 start_task >> exec_order_task_start
    #                 exec_order_task_start >> bq_query_exec_task 
    #         else:
    #             if object_details.exec_order == prev_exec_id:
    #                 exec_order_task_start >> bq_query_exec_task
    #             else:
    #                 prev_exec_order >> exec_order_task_start
    #                 exec_order_task_start >> bq_query_exec_task

    #         bq_query_exec_task >> sp_call_ingest_to_final >> bq_query_exec_for_agg_session_full
    #         bq_query_exec_for_agg_session_full >> bq_query_exec_for_agg_session_incre 
    #         bq_query_exec_for_agg_session_incre >> bq_query_exec_for_agg_load_full 
    #         bq_query_exec_for_agg_load_full >> bq_query_exec_for_agg_load_incre >> bq_query_exec_for_agg_inter_load_incre >> mySQLInsertTask
    #         mySQLInsertTask >> bqSqlExecOutAppndTask
    #         bqSqlExecOutAppndTask >> exec_order_task_end
            
    #     else:
    #         if counter == 0:
    #             start_task >> exec_order_task_start
    #             exec_order_task_start >> exec_order_task_end
    #         else:
    #             if object_details.exec_order != prev_exec_id:
    #                 prev_exec_order >> exec_order_task_start
    #                 exec_order_task_start >> exec_order_task_end

    #     prev_exec_order = exec_order_task_end
    #     prev_exec_id = object_details.exec_order
    #     counter += 1

    # if counter == object_details.length_list:
    #     exec_order_task_end >> end_task
   
            
    


