from airflow.operators.python_operator import BranchPythonOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.bash_operator import BashOperator

from airflow.contrib.operators.ssh_operator import SSHOperator
from airflow.contrib.operators.gcs_to_bq import GoogleCloudStorageToBigQueryOperator
from airflow.contrib.operators.bigquery_to_bigquery import BigQueryToBigQueryOperator
from airflow.contrib.operators.gcs_to_gcs import GoogleCloudStorageToGoogleCloudStorageOperator

from airflow.exceptions import AirflowException
from airflow.models import Variable

from bigdata_plugins.operators import BigDataCountCheckOperator
from bigdata_plugins.operators import BigDataCountFailureOperator


def bqToBqBkpToPassiveTask(objectName, GCP_CONN, final_table_name, passive_table_name,write_disposition="WRITE_TRUNCATE" ):
    task_id = objectName + '_' + "bqToBqBkpToPassive_task"
    return BigQueryToBigQueryOperator(
        task_id=task_id,
        bigquery_conn_id=GCP_CONN,
        source_project_dataset_tables=final_table_name,
        destination_project_dataset_table=passive_table_name,
        write_disposition=write_disposition
    )

def gcsToBqStgTask(objectName, objectGcsPath, GCP_CONN, gcp_sa_bucket,projectname,stg_table_name,schema_object,write_disposition="WRITE_TRUNCATE"):
    task_id = objectName + '_' + "gcsToBqStg_task"
    return GoogleCloudStorageToBigQueryOperator(
        task_id=task_id,
        google_cloud_storage_conn_id=GCP_CONN,
        bigquery_conn_id=GCP_CONN,
        bucket=gcp_sa_bucket,
        source_objects=objectGcsPath,
        destination_project_dataset_table= projectname + ':' + stg_table_name,
        source_format="PARQUET",
        schema_object=schema_object,
        write_disposition=write_disposition
    )

def bqStgCountCheckTask(objectName,GCP_SVC_ACCOUNT_JSON_PATH,stg_table_name ):
    task_id = objectName + '_' + "bqStgCountCheck_task"
    return BigDataCountCheckOperator(
        task_id=task_id,
        svc_account_json_path=Variable.get(GCP_SVC_ACCOUNT_JSON_PATH),
        dataset_table_name= stg_table_name
    )

def verifyStgCount(*op_args, **context):
    objectName = op_args[0]
    count_task_name = objectName + '_' + "bqStgCountCheck_task"
    success_task_name = objectName + '_' + "bqToBqStgToFinal_task"
    failure_task_name = objectName + '_' + "bqToBqRollback_task"
    task_instance = context['task_instance']
    if task_instance.xcom_pull(task_ids=count_task_name) == 'SUCCESS':
        return success_task_name
    elif task_instance.xcom_pull(task_ids=count_task_name) == 'FAILURE':
        return failure_task_name
    else:
        raise AirflowException("count_task_name return value is invalid")

def verifyStgTask(objectName):
    task_id = objectName + '_' + "verifyStgTask"
    return BranchPythonOperator(
        task_id=task_id,
        provide_context=True,
        python_callable=verifyStgCount,
        op_args=[objectName]
    )

def bqToBqStgToFinalTask(objectName,GCP_CONN, stg_table_name, final_table_name,write_disposition="WRITE_TRUNCATE"):
    task_id = objectName + '_' + "bqToBqStgToFinal_task"
    return BigQueryToBigQueryOperator(
        task_id=task_id,
        bigquery_conn_id=GCP_CONN,
        source_project_dataset_tables=stg_table_name,
        destination_project_dataset_table=final_table_name,
        write_disposition=write_disposition
    )

def bqToBqRollbackTask(objectName,GCP_CONN, passive_table_name, final_table_name,write_disposition="WRITE_TRUNCATE"):
    task_id = objectName + '_' + "bqToBqRollback_task"
    return BigQueryToBigQueryOperator(
        task_id=task_id,
        bigquery_conn_id=GCP_CONN,
        source_project_dataset_tables=passive_table_name,
        destination_project_dataset_table=final_table_name,
        write_disposition=write_disposition
    )

def bqStgCountFailureTask(objectName,stg_table_name):
    task_id=objectName + '_' + "bqStgCountFailure_task"
    return BigDataCountFailureOperator(
        task_id=task_id,
        dataset_table_name=stg_table_name
    )

def refreshSuccessTask(objectName):
    task_id = objectName + '_' + "refreshSuccess_task"
    return DummyOperator(
        task_id=task_id,
        trigger_rule='none_failed'
    )

def gcsArchiveTask(objectName,GCP_CONN,gcp_sa_bucket,gcp_ar_bucket,obj_bucket_path,execution_date):
    task_id = objectName + '_' + "gcsArchive_task"
    return GoogleCloudStorageToGoogleCloudStorageOperator(
        task_id=task_id,
        google_cloud_storage_conn_id=GCP_CONN,
        source_bucket=gcp_sa_bucket,
		destination_bucket=gcp_ar_bucket,
        source_object=''.join([obj_bucket_path,'*']),
        destination_object=obj_bucket_path+str(execution_date)+'/',
        move_object=False
    )

def startTask():
    return DummyOperator(
        task_id="start_task"
    )

def endTask():
    return DummyOperator(
        task_id="end_task"
    )

def cleanupGcsTask():
    return DummyOperator(
        task_id="cleanup_gcs_task"
    )

def distcpHdpToGcpFromEdge02(EDGE02_SSH_CONN, DISTCP_HDPGCS_SCRIPT_PATH):
    task_id = "distcpHdpToGcpFromEdge02_task"
    return SSHOperator(
        task_id=task_id,
        ssh_conn_id=EDGE02_SSH_CONN,
        command=DISTCP_HDPGCS_SCRIPT_PATH
    )

def distcpHdpToGcp(DISTCP_HDPGCS_SCRIPT_PATH):
    task_id = "distcpHdpToGcp_task"
    return BashOperator(
        task_id = task_id,
        bash_command=DISTCP_HDPGCS_SCRIPT_PATH,
        xcom_push=False
    )
