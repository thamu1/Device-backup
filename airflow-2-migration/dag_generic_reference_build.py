"""
Code Author: Prashant Basa
Code Developed Date: 2021-08-03
Code Modified Date : 2021-09-30

This is the generic dag for all the online reference build

Arguments to pass:
1) Argument1: Dag
2) Argument2: Dag Details
3) Argument3: Default Args
4) Argument4: the object_properties_json file
"""

from bigdata.utils.gcp_extractMetadataFromMySQL import BQTableDtls
from bigdata.utils.airflow_factory import *
from airflow.operators.empty import EmptyOperator
from airflow import macros
from itertools import groupby
from datetime import datetime, timedelta

class GenericDAG:
    def __init__(self, dag, dag_name_dtls, default_args, object_properties_json):
        self.dag = dag
        self.dag_name = dag_name_dtls['dag_name']
        self.default_args = default_args
        self.object_properties_json = object_properties_json

    def _getObjectDetails(self):
        object_details = BQTableDtls(self.object_properties_json)
        return object_details

    def prepareDag(self):
        object_details = self._getObjectDetails()
        start_task = EmptyOperator(task_id="start_task", dag=self.dag)
        end_task = EmptyOperator(task_id="end_task", retries=1, retry_delay=timedelta(seconds=10), dag=self.dag)
        backfill_run_id = "{{ run_id }}"

        # Defining a intermediate variable
        counter = 0
        prev_exec_id = "-1"

        for i in object_details.object_id_list_sorted:
            object_details.exec_order = i
            object_details.airflow_control_flag = i
            object_details.airflow_mapping_id = i
            object_details.gcp_conn_var = i
            object_details.gcp_schema_initial = i
            object_details.object_name = i
            object_details.gcp_schema_intermediate = i
            object_details.gcp_partition_cols = i
            object_details.gcp_cluster_cols = i
            object_details.gcp_svc_json_path_var = i
            object_details.gcp_schema_final = i
            object_details.gcp_conn_bigdata_etl_metadata = i
            object_details.frequency = i
            object_details.subjectarea_name = i
            object_details.project_name = i

            if object_details.exec_order != prev_exec_id:
                exec_order_task_start = EmptyOperator(task_id="i" + str(object_details.exec_order), dag=self.dag)
                exec_order_task_end = EmptyOperator(task_id="j" + str(object_details.exec_order), dag=self.dag)


            if object_details.airflow_control_flag == "NoByPass":

                dag_st_time = "{{ data_interval_start.in_timezone('America/New_York').format('YYYY-MM-DD HH:mm:ss') }}"

                insert_sql = f"""insert into gcp_airflow_lastrun(airflow_mapping_id, airflow_backfill_id
                            , exec_status, exec_start_ts, exec_end_ts
                            , insert_dt) values('{object_details.airflow_mapping_id}', '{backfill_run_id}'
                            , 'Success'
                            , '{str(dag_st_time)}'
                            , CURRENT_TIMESTAMP
                            , CURRENT_DATE)
                            """

                bqOnlLoadStg_Task = gcp_bq_to_bq_load_sqltask("i" + str(object_details.exec_order)
                                            , object_details.gcp_conn_var
                                            , object_details.project_name
                                            , object_details.gcp_schema_initial
                                            , "vw_" + object_details.object_name
                                            , object_details.gcp_schema_intermediate
                                            , object_details.object_name
                                            , object_details.gcp_partition_cols
                                            , object_details.gcp_cluster_cols, self.dag)

                bqOnlStgCountCheck_Task = gcp_bq_obj_count_check("i" + str(object_details.exec_order)
                                            , object_details.gcp_conn_var
                                            , object_details.project_name
                                            , object_details.gcp_schema_intermediate
                                            , object_details.object_name, self.dag)

                bqOnlFinalTableTask = gcp_bq_to_bq_load("i" + str(object_details.exec_order)
                                            , object_details.gcp_conn_var
                                            , object_details.project_name
                                            , object_details.gcp_schema_intermediate
                                            , object_details.object_name
                                            , object_details.gcp_schema_final
                                            , object_details.object_name, self.dag)

                bq_sql_exec = f"select 'bigdata' as team,'online_etl' as process_type,'uat' as environment," \
                              f"'airflow' as tool,'airflow2_test' as subject_area," \
                              f"'{object_details.project_name}' as project_name," \
                              f"'{object_details.gcp_schema_final}' as dataset_name," \
                              f"'{object_details.object_name}' as object_name," \
                              f"'{object_details.frequency}' as frequency,'success' as exec_status," \
                              f"'na' as boundary_value" \
                              f",cast(DATETIME(CURRENT_TIMESTAMP,\"America/New_York\") as timestamp) as insert_ts"

                bqSqlExecOutAppndTask = gcp_sql_exec_bq_append("i" + str(object_details.exec_order)
                                            , object_details.object_name
                                            , object_details.gcp_conn_var
                                            , object_details.project_name
                                            , 'it_etl_monitoring'
                                            , 'bigdata_etl_logging'
                                            , bq_sql_exec
                                            , self.dag)

                mySQLInsertTask = gcp_mysqlDMLOperator("i" + str(object_details.exec_order)
                                            , object_details.object_name, insert_sql
                                            , self.dag)

                if counter == 0:
                    start_task >> exec_order_task_start
                    exec_order_task_start >> bqOnlLoadStg_Task
                else:
                    if object_details.exec_order == prev_exec_id:
                        exec_order_task_start >> bqOnlLoadStg_Task
                    else:
                        prev_exec_order >> exec_order_task_start
                        exec_order_task_start >> bqOnlLoadStg_Task

                bqOnlLoadStg_Task >> bqOnlStgCountCheck_Task
                bqOnlStgCountCheck_Task >> bqOnlFinalTableTask
                bqOnlFinalTableTask >> bqSqlExecOutAppndTask
                bqSqlExecOutAppndTask >> mySQLInsertTask
                mySQLInsertTask >> exec_order_task_end

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