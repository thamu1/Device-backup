from datetime import datetime,timedelta
from airflow import DAG
from airflow.providers.mysql.operators.mysql import MySqlOperator
from airflow.operators.bash import BashOperator
import pandas as pd
import json
from airflow.operators.python import PythonOperator
from airflow.providers.mysql.hooks.mysql import MySqlHook
import mysql.connector
from tables import ingestion_controller,gcp_scueduler,ingestion_source



# conn = mysql.connector.connect(
#     host='127.0.0.1',
#     user='root',
#     password='Mysql.08',
#     database='world'
# )



path = 'D:/gcp/python class/metadata operation/'


    
def insert_into_ingestion_source():
    isr = ingestion_source()
    isr.insert()
    
def insert_into_ingestion_controller():
    ic = ingestion_controller()
    ic.insert()
def insert_into_gcp_scheduler():
    gs = gcp_scueduler()
    gs.insert()
    

    
    
    





args = {
    'owner': 'thamu',  
    # 'retries' : 1,  
    # 'start_date': airflow.utils.dates.days_ago(2),
    # 'end_date': datetime(),
    # 'depends_on_past': True,
    # 'email': ['test@example.com'],
    #'email_on_failure': False,
    #'email_on_retry': False,
    # If a task fails, retry it once after waiting
    # at least 5 minutes
    #'retries': 1,
    'retry_delay': timedelta(seconds=5),
    }



dag = DAG(
    dag_id='airflow_write_test',
    default_args=args,
    schedule_interval='@once',
    start_date=datetime(2023,6,4),
    dagrun_timeout=timedelta(minutes=60),
    description='use to insert values in uat',
)

start = BashOperator(
    task_id='start',
    bash_command=f'echo "start"',
    dag=dag
)

ing_src = PythonOperator(
    task_id = 'select',
    python_callable=insert_into_ingestion_source,
    dag=dag
)

ing_con = PythonOperator(
    task_id = 'insert',
    python_callable=insert_into_ingestion_controller,
    dag=dag
)

ing_sche = PythonOperator(
    task_id = 'insert',
    python_callable=insert_into_gcp_scheduler,
    dag=dag
)


stop = BashOperator(
    task_id='stop',
    bash_command='echo "end"',
    dag=dag
)

start >> ing_src >> ing_con >> ing_sche >> stop

