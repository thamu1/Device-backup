import datetime

from airflow import models
from airflow.contrib.kubernetes import secret
from airflow.contrib.operators import kubernetes_pod_operator
from airflow.operators.dummy_operator import DummyOperator
# If you are running Airflow in more than one time zone
# see https://airflow.apache.org/docs/apache-airflow/stable/timezone.html
# for best practices
YESTERDAY = datetime.datetime.now() - datetime.timedelta(days=1)

# If a Pod fails to launch, or has an error occur in the container, Airflow
# will show the task as failed, as well as contain all of the task logs
# required to debug.
with models.DAG(
        dag_id='composer_sample_kubernetes_pod3',
        schedule_interval=datetime.timedelta(days=1),
        start_date=YESTERDAY) as dag:

    # start
    start = DummyOperator(
            task_id="start",
        )

        # Run CSV transform within kubernetes pod
    transform_xlsx_or_sas = kubernetes_pod_operator.KubernetesPodOperator(
            task_id="transform_xls_or_sas",
            startup_timeout_seconds=2400,
            name="custom_kpod_convert_csvorsas",
            namespace='default',
            #service_account_name="datasets",
            image_pull_policy="Always",
            image="us-east1-docker.pkg.dev/dev-analytics-datasci/dev-analytics-datasci-dockerrepo/custom-kpod-image:tag2",
            env_vars={
                "SOURCE_URLS": '["gs://bkt_dev_cmpgn_inbound/model_b/selection_file/selection_file.sas7bdat"]',
                "SOURCE_FILES": '["files/data1.sas7bdat"]',
                "TARGET_FILE": "files/selection_file.csv",
                "TARGET_GCS_BUCKET": "bkt_dev_cmpgn_inbound",
                "TARGET_GCS_PATH": "model_b/selection_file/selection_file.csv",
                "PIPELINE_NAME": "custom_kpod",
                "SHEET_NAME_TO_READ": "B_Model",
                "FILE_TYPE": "sas",
                "CSV_HEADERS":'["CUSTID","MAILID","SUFFIX","DASH_BOARD_IND"]',
            },
            resources={
                "request_memory": "5G",
                "request_cpu": "1.5",
                "request_ephemeral_storage": "3G",
            },
            affinity={
                'nodeAffinity': {
                    # requiredDuringSchedulingIgnoredDuringExecution means in order
                    # for a pod to be scheduled on a node, the node must have the
                    # specified labels. However, if labels on a node change at
                    # runtime such that the affinity rules on a pod are no longer
                    # met, the pod will still continue to run on the node.
                    'requiredDuringSchedulingIgnoredDuringExecution': {
                        'nodeSelectorTerms': [{
                            'matchExpressions': [{
                                # When nodepools are created in Google Kubernetes
                                # Engine, the nodes inside of that nodepool are
                                # automatically assigned the label
                                # 'cloud.google.com/gke-nodepool' with the value of
                                # the nodepool's name.
                                'key': 'cloud.google.com/gke-nodepool',
                                'operator': 'In',
                                # The label key's value that pods can be scheduled
                                # on.
                                'values': [
                                    'custom-mm'
                                ]
                            }]
                        }]
                    }
                }
            }
    )


    end = DummyOperator(
            task_id="end",
        )
    
start >> transform_xlsx_or_sas >> end


