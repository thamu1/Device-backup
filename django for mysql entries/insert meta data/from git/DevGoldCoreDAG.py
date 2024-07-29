import os
import json
from airflow import DAG
from datetime import datetime

from bigdata.utils.factory import *

CONFIG_JSON_FILE_PATH = r"/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/calcengine/dev/bigdata/goldcore/dev/config/dev-gold-core.json"
HADOOP_DISTCP_GCS_SCRIPT_PATH="/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/shared/bigdata/uat/hdl_to_gcp/gcs_upload_uat.sh "

default_args = {
    "start_date": datetime(2020,9,1),
    "owner": "airflow"
}

def getObjectDetails(CONFIG_JSON_FILE_PATH):
    if not os.path.isfile(CONFIG_JSON_FILE_PATH):
        raise Exception("Config file path doesn't exist")
    with open(CONFIG_JSON_FILE_PATH) as configFile:
        configs = json.loads(configFile.read())
        object_details = []
        env_configs = dict((k, configs[k]) for k in configs if k != 'subjectarea')

        for subj in configs['subjectarea']:
            subj_config = dict((k, subj[k]) for k in subj if k != 'object')
            for obj in subj['object']:
                obj_config = dict()
                obj_config['projectname'] = env_configs['projectname']
                obj_config['EDGE02_SSH_CONN'] = env_configs['edge02_ssh_conn']
                obj_config['subjectareaName'] = subj_config['name']
                obj_config['objectName'] = obj['name']
                obj_config['GCP_CONN'] = env_configs['gcp_conn_var']
                obj_config['final_table_name'] = subj_config['gcpETLSchemaName_final'] + '.' + obj['name']
                obj_config['passive_table_name'] = subj_config['gcpETLSchemaName_passive'] + '.' + obj[
                    'name'] + '_passive'
                obj_config['GCP_SVC_ACCOUNT_JSON_PATH'] = env_configs['gcp_svc_json_path_var']
                obj_config['obj_bucket_path'] = env_configs['gcs_distcp_sa_root_location'].split(env_configs['gcp_sa_bucket']+'/')[1] + \
                                                subj_config['aliasForLocation'] + '/' + obj['categoryForLocation'] + '/' + obj['aliasForLocation'] + '/'
                obj_config['objectGcsPath'] = [ obj_config['obj_bucket_path'][:-1] + '/*']
                obj_config['gcp_sa_bucket'] = env_configs['gcp_sa_bucket']
                obj_config['gcp_ar_bucket'] = env_configs['gcp_ar_bucket']
                obj_config['stg_table_name'] = subj_config['gcpETLSchemaName_stg'] + '.' + obj['name']
                obj_config['schema_object'] = env_configs['schemaobjects_sa_root_location'].split(env_configs['gcp_sa_bucket']+'/')[1] + \
                                              subj_config['aliasForLocation'] + '/' + obj['name'] + '/' + obj['name'] + ".json"
                object_details.append(obj_config)
    return object_details


with DAG(dag_id="devGoldCore", schedule_interval="@daily", default_args=default_args, catchup=False, tags=["GoldCore","dev"]) as dag:
    EXEC_DATE = '{{ ds }}'
    object_details = getObjectDetails(CONFIG_JSON_FILE_PATH)

    start_task = startTask()
    cleanup_gcs_task = cleanupGcsTask()
    distcp_task = distcpHdpToGcpFromEdge02(object_details[0]['EDGE02_SSH_CONN'],HADOOP_DISTCP_GCS_SCRIPT_PATH)
    end_task = endTask()

    start_task >> cleanup_gcs_task >> distcp_task

    for i, obj in enumerate(object_details):
        bqToBqBkpToPassiveTask_i = bqToBqBkpToPassiveTask(obj['objectName'], obj['GCP_CONN'], obj['final_table_name'], obj['passive_table_name'])
        distcp_task >> bqToBqBkpToPassiveTask_i

        gcsToBqStgTask_i = gcsToBqStgTask(obj['objectName'], obj['objectGcsPath'], obj['GCP_CONN'], obj['gcp_sa_bucket'],obj['projectname'],obj['stg_table_name'], obj['schema_object'])
        bqToBqBkpToPassiveTask_i >> gcsToBqStgTask_i

        bqStgCountCheckTask_i = bqStgCountCheckTask(obj['objectName'], obj['GCP_SVC_ACCOUNT_JSON_PATH'], obj['stg_table_name'] )
        gcsToBqStgTask_i >> bqStgCountCheckTask_i

        verifyStgTask_i = verifyStgTask(obj['objectName'])
        bqStgCountCheckTask_i >> verifyStgTask_i

        bqToBqStgToFinalTask_i = bqToBqStgToFinalTask(obj['objectName'],obj['GCP_CONN'], obj['stg_table_name'], obj['final_table_name'])
        verifyStgTask_i >> bqToBqStgToFinalTask_i

        bqToBqRollbackTask_i = bqToBqRollbackTask(obj['objectName'],obj['GCP_CONN'], obj['passive_table_name'], obj['final_table_name'])
        verifyStgTask_i >> bqToBqRollbackTask_i

        object_failure_task_i = bqStgCountFailureTask(obj['objectName'],obj['stg_table_name'])
        bqToBqRollbackTask_i >> object_failure_task_i

        object_complete_task_i = refreshSuccessTask(obj['objectName'])
        object_failure_task_i >> object_complete_task_i

        bqToBqStgToFinalTask_i >> object_complete_task_i

        gcsArchiveTask_i = gcsArchiveTask(obj['objectName'], obj['GCP_CONN'],obj['gcp_sa_bucket'],obj['gcp_ar_bucket'],obj['obj_bucket_path'],EXEC_DATE)
        object_complete_task_i >> gcsArchiveTask_i
        gcsArchiveTask_i >> end_task