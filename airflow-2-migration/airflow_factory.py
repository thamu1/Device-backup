from airflow.operators.bash import BashOperator
from airflow.providers.google.cloud.operators.bigquery import (BigQueryInsertJobOperator, 
        BigQueryCheckOperator)
from airflow.providers.google.cloud.transfers.bigquery_to_bigquery import BigQueryToBigQueryOperator
from airflow.providers.google.cloud.operators.gcs import GCSDeleteObjectsOperator
from datetime import datetime, timedelta
from airflow.providers.mysql.operators.mysql import MySqlOperator
import mysql
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator




def mysql_select_exec(query, host_name, usr, pwd, db_name):
    try:
        con = mysql.connector.connect(user=str(usr), password=str(pwd), host=host_name, database=str(db_name))
        cursor = con.cursor()
    except mysql.connector.Error as err:
        raise Exception
    else:
        query = cursor.execute(f"{query}")
        return cursor.fetchall()
    finally:
        cursor.close()
        con.close()

def mysql_update_insert_exec(query, host_name, usr, pwd, db_name):
    try:
        con = mysql.connector.connect(user=str(usr), password=str(pwd), host=host_name, database=str(db_name))
        cursor = con.cursor()
    except mysql.connector.Error as err:
        raise Exception
    else:
        query = cursor.execute(f"{query}")
        con.commit()
        return cursor.rowcount
    finally:
        cursor.close()
        con.close()


def gcp_bq_to_bq_load_sqltask(exec_order_task, gcp_conn_var, project_name, # Here added
                           gcp_schema_initial, bq_initial_tblname, 
                           gcp_schema_intermediate, bq_target_tblname, gcp_partition_cols, gcp_cluster_cols,
                           dag, write_disposition="WRITE_TRUNCATE", create_disposition="CREATE_IF_NEEDED"):
    task_id = exec_order_task + "_" + bq_target_tblname + '_' + "gcp_BqToBqLoadSQLTask"
    
    if(gcp_cluster_cols == None):
        cluster_by = None
    else:
        cluster_by = {"fields": gcp_cluster_cols}
        
    return BigQueryInsertJobOperator(
        task_id= task_id,
        configuration={
            "query": {
                "query" : f"select * from {project_name}.{gcp_schema_initial}.{bq_initial_tblname}", 
                "useLegacySql": False,
                "destinationTable": {
                    "projectId": project_name, 
                    "datasetId": gcp_schema_intermediate,
                    "tableId": bq_target_tblname
                },
                "clustering": cluster_by,
                "timePartitioning": gcp_partition_cols,
                "createDisposition": create_disposition,
                "writeDisposition": write_disposition,
                "allowLargeResults": True
            }
        },
        gcp_conn_id = gcp_conn_var,
        force_rerun = True,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag = dag
        # location=location,
    )
        
    
    
def gcp_bq_obj_count_check(exec_order_task, gcp_conn_var,
                        #    gcp_svc_account_json_path, 
                           project_name, gcp_schema_intermediate, object_name, dag ):
    task_id = exec_order_task + "_" + object_name + '_' + "gcp_BQObjCountCheck"
    return BigQueryCheckOperator(
        task_id=task_id,
        gcp_conn_id = gcp_conn_var,
        sql= f"""select count(1) from {project_name}.{gcp_schema_intermediate}.{object_name}""",
        use_legacy_sql = False,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag=dag
    )


def gcp_bq_to_bq_load(exec_order_task, gcp_conn_var, project_name, gcp_schema_intermediate, 
                      bq_intermediate_tblname, gcp_schema_target, bq_target_tblname, dag, 
                      write_disposition="WRITE_TRUNCATE"):
    task_id = exec_order_task + "_" + bq_target_tblname + '_' + "gcp_BQToBQLoad"
    return BigQueryToBigQueryOperator(
        task_id=task_id,
        gcp_conn_id=gcp_conn_var,
        source_project_dataset_tables= project_name +"."+gcp_schema_intermediate + "." + bq_intermediate_tblname,
        destination_project_dataset_table= project_name +"."+gcp_schema_target + "." + bq_target_tblname,
        write_disposition=write_disposition,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag=dag
    )
    

def gcp_sql_exec_bq_append(exec_order_task, object_name, gcp_conn_var, project_name, dest_tbl_schema,
                dest_tbl_name, sql_exec, dag, write_disposition="WRITE_APPEND", 
                create_disposition="CREATE_IF_NEEDED"):
    
    return BigQueryInsertJobOperator(
        task_id=exec_order_task + "_" + object_name + "_bq_success_entry",
        configuration={
            "query": {
                "query" : sql_exec,
                "useLegacySql": False,
                "destinationTable": {
                    "projectId": project_name,
                    "datasetId": dest_tbl_schema,
                    "tableId": dest_tbl_name
                },
                "createDisposition": create_disposition,
                "writeDisposition": write_disposition,
                "allowLargeResults": True
            }
        },
        gcp_conn_id = gcp_conn_var,
        force_rerun = True,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag = dag
        # location=location,
    )


    
# def gcp_mysqlDMLOperator(exec_order_task, object_name, dml_sql, gcp_mysql_conn, dag):
#     task_id = exec_order_task + "_" + object_name + '_' + "gcp_MySQLInsertTask"
#     return MySqlOperator(
#         task_id=task_id,
#         sql=dml_sql,
#         mysql_conn_id=gcp_mysql_conn,
#         autocommit=True,
#         dag=dag
#     )
    

def gcp_mysqlDMLOperator(exec_order_task, object_name, dml_sql, dag):
    task_id = exec_order_task + "_" + object_name + '_' + "gcp_MySQLInsertTask"
    return SQLExecuteQueryOperator(
        task_id=task_id,
        sql=dml_sql,
        autocommit=True,
        dag=dag
    )

def gcp_FromExtSQLFileToBQObj(exec_order_task, object_name, gcp_conn_var, project_name, dest_tbl_schema, 
                              dest_tbl_name, partitionedCols, clusterFields, sql_loc, dag, 
                              write_disposition="WRITE_TRUNCATE", create_disposition="CREATE_IF_NEEDED"): 
    task_id = exec_order_task + "_" + object_name + '_' + "gcp_FinalObjectLoad"
    
    if(clusterFields == None):
        cluster_by = None
    else:
        cluster_by = {"fields": clusterFields}
    
    return BigQueryInsertJobOperator(
        task_id= task_id,
        configuration={
            "query": {
                "query" : sql_loc + ".sql", 
                "useLegacySql": False,
                "destinationTable": {
                    "projectId": project_name,
                    "datasetId": dest_tbl_schema,
                    "tableId": dest_tbl_name
                },
                "clustering": cluster_by,
                "timePartitioning": partitionedCols,
                "createDisposition": create_disposition,
                "writeDisposition": write_disposition,
                "allowLargeResults": True
            }
        },
        gcp_conn_id = gcp_conn_var,
        force_rerun = True,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag = dag
        # location=location,
    )
    
    

def gcp_FromExtSQLFileToBQObj_without_pc(exec_order_task, object_name, gcp_conn_var, project_name,  
                              dest_tbl_schema, dest_tbl_name, sql_loc, dag, 
                              write_disposition="WRITE_TRUNCATE", create_disposition="CREATE_IF_NEEDED"): 
    task_id = exec_order_task + "_" + object_name + '_' + "gcp_FinalObjectLoad"
    return BigQueryInsertJobOperator(
        task_id= task_id,
        configuration={
            "query": {
                "query" : sql_loc + ".sql", 
                "useLegacySql": False,
                "destinationTable": {
                    "projectId": project_name,
                    "datasetId": dest_tbl_schema,
                    "tableId": dest_tbl_name
                },
                "createDisposition": create_disposition,
                "writeDisposition": write_disposition,
                "allowLargeResults": True
            }
        },
        gcp_conn_id = gcp_conn_var,
        force_rerun = True,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag = dag
        # location=location,
    )


def BigQueryValueCheckOperator(task_id, gcp_conn_var, sql, dag):
    task_id = task_id
    return BigQueryInsertJobOperator(
        task_id= task_id,
        configuration={
            "query": {
                "query" : sql, 
                "useLegacySql": False,
            }
        },
        gcp_conn_id = gcp_conn_var,
        force_rerun = True,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag = dag
        # location=location,
    )


def gcp_FromExtSQLFileExecQuery(exec_order_task, object_name, sql_loc, gcp_conn_var, dag):
    task_id = exec_order_task + "_" + object_name + '_' + "gcp_FinalObjectLoad"
    return BigQueryInsertJobOperator(
        task_id= task_id,
        configuration={
            "query": {
                "query" : sql_loc + ".sql", 
                "useLegacySql": False,
            }
        },
        gcp_conn_id = gcp_conn_var,
        force_rerun = True,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag = dag
        # location=location,
    )



def gcp_FromExtSQLFileToBQObj_Append(exec_order_task, object_name, gcp_conn_var, project_name, dest_tbl_schema, dest_tbl_name
                              , partitionedCols, clusterFields, sql_loc, dag, write_disposition="WRITE_APPEND", create_disposition = "CREATE_IF_NEEDED"):
    task_id = exec_order_task + "_" + object_name + '_' + "gcp_FinalObjectLoad"
    
    if(clusterFields == None):
        cluster_by = None
    else:
        cluster_by = {"fields": clusterFields}
        
    return BigQueryInsertJobOperator(
        task_id= task_id,
        configuration={
            "query": {
                "query" : sql_loc + ".sql", 
                "useLegacySql": False,
                "destinationTable": {
                    "projectId": project_name,
                    "datasetId": dest_tbl_schema,
                    "tableId": dest_tbl_name
                },
                "clustering": cluster_by,
                "timePartitioning": partitionedCols,
                "createDisposition": create_disposition,
                "writeDisposition": write_disposition,
                "allowLargeResults": True
            }
        },
        gcp_conn_id = gcp_conn_var,
        force_rerun = True,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag = dag
        # location=location,
    )
        
    

def gcp_bq_to_bq_load_append(exec_order_task, gcp_conn_var, project_name, gcp_schema_initial, bq_initial_tblname
                      , gcp_schema_target, bq_target_tblname, dag, write_disposition="WRITE_APPEND", 
                      create_disposition: str = "CREATE_IF_NEEDED"):
    task_id = exec_order_task + "_" + bq_target_tblname + '_' + "gcp_BQToBQLoad"
    return BigQueryToBigQueryOperator(
        task_id=task_id,
        gcp_conn_id=gcp_conn_var,
        source_project_dataset_tables= project_name + "." + gcp_schema_initial + "." + bq_initial_tblname,
        destination_project_dataset_table= project_name + "." + gcp_schema_target + "." + bq_target_tblname,
        write_disposition=write_disposition,
        create_disposition = create_disposition,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag=dag
    )
    

def gcp_bq_to_bq_copy_partition(exec_order_task, gcp_conn_var, project_name, gcp_schema_initial, bq_initial_tblname
                                , gcp_schema_target, bq_target_tblname, partition_value, dag, 
                                write_disposition="WRITE_TRUNCATE", create_disposition = "CREATE_IF_NEEDED" ):
    return BigQueryToBigQueryOperator(
        task_id = exec_order_task + "_" + bq_target_tblname + '_' + "gcp_BQToBQCopyPartitions",
        gcp_conn_id=gcp_conn_var,
        source_project_dataset_tables= f"{project_name}.{gcp_schema_initial}.{bq_initial_tblname}${partition_value}",
        destination_project_dataset_table= f"{project_name}.{gcp_schema_target}.{bq_target_tblname}${partition_value}",
        write_disposition= write_disposition,
        create_disposition = create_disposition,
        dag=dag
    )


def gcp_bq_to_bq_copy_entire_table(exec_order_task, gcp_conn_var, project_name, gcp_schema_initial, bq_initial_tblname
                                , gcp_schema_target, bq_target_tblname, dag):
    return BigQueryToBigQueryOperator(
        task_id = exec_order_task + "_" + bq_target_tblname + '_' + "gcp_BQToBQCopyPartitions",
        gcp_conn_id=gcp_conn_var,
        source_project_dataset_tables= project_name + "." + gcp_schema_initial + "." + bq_initial_tblname,
        destination_project_dataset_table= project_name + "." + gcp_schema_target + "." + bq_target_tblname,
        write_disposition="WRITE_TRUNCATE",
        create_disposition = "CREATE_IF_NEEDED",
        dag=dag
    )


    
    
   
def gcsToBqStgSqlTaskv2_Rev(objectName, GCP_CONN, projectname, gcp_schema_initial, ext_view_name,
                gcp_schema_intermediate, stg_table_name, partitionedCols, clusterFields, 
                dag, write_disposition="WRITE_TRUNCATE", create_disposition="CREATE_IF_NEEDED"):
    task_id = objectName + '_' + "gcsToBqStgSql_task"
    
    if(clusterFields == None):
        cluster_by = None
    else:
        cluster_by = {"fields": clusterFields}

    return BigQueryInsertJobOperator(
        task_id= task_id,
        configuration={
            "query": {
                "query" : f"select * from {projectname}.{gcp_schema_initial}.{ext_view_name}",
                "useLegacySql": False,
                "destinationTable": {
                    "projectId": projectname,
                    "datasetId": gcp_schema_intermediate,
                    "tableId": stg_table_name
                },
                "clustering": cluster_by,
                "timePartitioning": partitionedCols,
                "createDisposition": create_disposition,
                "writeDisposition": write_disposition,
                "allowLargeResults": True
            }
        },
        gcp_conn_id = GCP_CONN,
        force_rerun = True,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag=dag
        # location=location,
    )
        
    
def bqToBqStgToFinalDTask(objectName, GCP_CONN, project_name, stg_schema_name, stg_table_name,
                          final_schema_name, final_table_name,dag,write_disposition="WRITE_TRUNCATE"):
    task_id = objectName + '_' + "bqToBqStgToFinal_task"
    return BigQueryToBigQueryOperator(
        task_id=task_id,
        gcp_conn_id=GCP_CONN,
        source_project_dataset_tables= f"{project_name}.{stg_schema_name}.{stg_table_name}", 
        destination_project_dataset_table= f"{project_name}.{final_schema_name}.{final_table_name}",
        write_disposition=write_disposition,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag=dag
    )
    
def bqToBqBkpToPassiveTask_Rev(objectName, GCP_CONN, project_name, final_schema_name, final_table_name,
                            passive_schema_name, passive_table_name,dag ,write_disposition="WRITE_TRUNCATE"):
    task_id = objectName + '_' + "bqToBqBkpToPassive_task"
    return BigQueryToBigQueryOperator(
        task_id=task_id,
        gcp_conn_id=GCP_CONN,
        source_project_dataset_tables= f"{project_name}.{final_schema_name}.{final_table_name}", 
        destination_project_dataset_table= f"{project_name}.{passive_schema_name}.{passive_table_name}", 
        write_disposition=write_disposition,
        retries=1,
        retry_delay=timedelta(seconds=10),
        dag=dag
    )


def gcsCleanupTask(objectName, GCP_CONN, gcp_sa_bucket, obj_bucket_path, subdag):
    task_id = objectName + '_' + "gcsCleanup_task"
    return GCSDeleteObjectsOperator(
        task_id= task_id,
        gcp_conn_id= GCP_CONN,
        bucket_name= gcp_sa_bucket,
        prefix= obj_bucket_path,
        dag=subdag,
        retries=1,
        retry_delay=timedelta(seconds=10)
    )
    
    
def distcpTask(objectName, source_path, destination_path, distcp_params, subdag):
    task_id = objectName + '_' + "distcp_task"
    cmd = "hadoop distcp {0} {1} {2}".format(distcp_params, source_path,destination_path)
    return BashOperator(
        task_id = task_id,
        bash_command=cmd,
        dag=subdag
    )

