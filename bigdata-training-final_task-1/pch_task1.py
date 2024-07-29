
# pip install apache-airflow-providers-google



import os
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
# from airflow.operators.bigquery_operator import BigQueryOperator
from airflow.providers.google.cloud.operators.bigquery import (BigQueryCreateEmptyDatasetOperator ,BigQueryInsertJobOperator)
from airflow.providers.google.cloud.operators.gcs import GCSCreateBucketOperator
from datetime import datetime, timedelta
from airflow.contrib.operators.bigquery_operator import BigQueryOperator
from airflow.operators.python_operator import PythonOperator
from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from google.cloud import bigquery



default_args = {
    'owner': 'thamu',
    'depends_on_past': False,
    'start_date': datetime(2023, 2 , 16),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(seconds=10),
}

dag = DAG(
    'automated_process_for_fuel_consumtion',
    default_args=default_args,
    schedule_interval='@once',
    catchup=False
)


folder_name = 'D:/thamu/gcp/Input/data/'
# csv_list = []
csv_list = ["trip_1.csv","trip_2.csv","trip_3.csv","trip_4.csv","trips.csv","trucks.csv","trip_5.csv","trip_6.csv","trip_7.csv","trip_8.csv","trip_9.csv"]


DATASET_NAME = os.environ.get("GCP_BIGQUERY_DATASET_NAME", "pchtask2")
create_dataset = BigQueryCreateEmptyDatasetOperator(
        task_id="create-dataset",
        dataset_id=DATASET_NAME,
        dag=dag
    )

 
for i in csv_list:  
    i = i.replace('.csv','')
    create_table_query_cmd = f'bq mk --table pchtask2.{i}'
    create_table = BashOperator(
        task_id=f'create_tables_{i}',
        bash_command=create_table_query_cmd,
        dag=dag
    )

# for i in csv_list:
#     i = i.replace('.csv','')
#     load_csv_query = f"LOAD DATA OVERWRITE pchtask2.{i} FROM FILES (format = 'CSV',uris = ['gs://pchtask-2/{i}.csv']"
#     load_csv_into_table = BigQueryExecuteQueryOperator(
#     task_id=f'load_csv_file_to_table_{i}',
#     sql=load_csv_query,
#     gcp_conn_id='google_cloud_default',
#     use_legacy_sql=False,
#     dag=dag
#     )


for i in csv_list:  
    i = i.replace('.csv','')
    load_csv_query = f'bq load \
    --autodetect \
    --source_format=CSV \
    pchtask2.{i} \
    gs://pchtask-2/{i}.csv'
    load_csv_into_table = BashOperator(
        task_id=f'load_csv_file_to_table_{i}',
        bash_command=load_csv_query,
        dag=dag
    )


create_alltrips_table_query_cmd = f'bq mk --table pchtask2.all_trips trip_id:string,timestamp:timestamp,fuel_level:float'
create_all_trips_table = BashOperator(
    task_id='create_unionall_trips_table',
    bash_command=create_alltrips_table_query_cmd,
    dag=dag
)




def execute_query(i,**kwargs):
    client = bigquery.Client()

    union_all =f'''insert into thamu-task-377713.pchtask2.all_trips(trip_id , timestamp , fuel_level) 
                    select trip_id,timestamp,fuel_level from pchtask2.trip_{i}'''
    query = client.query(union_all)
    query.result()

for i in range(1,len(csv_list)-1):
    load_datas_into_unionall_table = PythonOperator(
        task_id = f'insert_data_to_table_query_{i}',
        python_callable= execute_query,
        op_kwargs = {'i':i},
        dag=dag
    )


def join_query_table():
    client = bigquery.Client()
    query = '''create table pchtask2.join_query(trip_id string , truck_id string , company string ,
                per_truck float64 , per_company float64)'''
    query_result = client.query(query)
    query_result.result()

result_query_table = PythonOperator(
    task_id='join_query_table_create',
    python_callable=join_query_table,
    dag=dag
)


def join_bq():
    client = bigquery.Client()
    join_query = """ insert into pchtask2.join_query(trip_id,truck_id,company,per_truck,per_company)
            select distinct t.trip_id ,ts.string_field_0,tc.string_field_1, sum(t.usages) over(partition by ts.string_field_0) as per_truck
            , sum(t.usages) over(partition by tc.string_field_1) as per_company
            from (select alt.trip_id,max(alt.fuel_level) - min(alt.fuel_level) as usages 
            from pchtask2.all_trips as alt group by alt.trip_id) as t 
            join pchtask2.trips as ts on t.trip_id=ts.string_field_1 
            join pchtask2.trucks as tc on tc.string_field_0 = ts.string_field_0 """
    
    queryjob = client.query(join_query)
    queryjob.result()

result_join = PythonOperator(
    task_id='join_result_query',
    python_callable=join_bq,
    dag=dag
)



create_dataset >> create_table >> load_csv_into_table >> create_all_trips_table >> load_datas_into_unionall_table >>result_query_table>> result_join



