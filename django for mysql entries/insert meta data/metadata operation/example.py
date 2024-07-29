# from datetime import datetime,timedelta
# from airflow import DAG
# from airflow.providers.mysql.operators.mysql import MySqlOperator
# from airflow.operators.bash import BashOperator
# import pandas as pd
# import json
# from airflow.operators.python import PythonOperator
# from airflow.providers.mysql.hooks.mysql import MySqlHook

# db = 'mapr_bigdata_uat_metahub'
# tab = 'gcp_ingestion_controller' 
# conn_id = 'withMysql'

# # conn = mysql.connector.connect(
# #     host='127.0.0.1',
# #     user='root',
# #     password='Mysql.08',
# #     database='world'
# # )



# # df.to_json(f'//wsl.localhost/Ubuntu/home/thamu/airflow/dags/json/j.json')


# # file = open(f'//wsl.localhost/Ubuntu/home/thamu/airflow/dags/json/j.json')
# # jfile = json.loads(file.read())
# # print(jfile['value']['0'])

# class suma():
#     def __init__(self,val):
#         self.val = val
#     def re(self):
#         global val
#         self.val = 10

# class ingestion_controller():
#     def __init__(self,val):
#         self.val =val
#     def cng(self):
#         global val
#         self.val = 11
     
# s = ingestion_controller(3)
# print(s.val)
# s.cng()
# print(s.val)     
        
# s = suma(4)
# print(s.val)
# s.re()
# print(s.val)

import json
path = 'D:/gcp/python class/metadata operation/config_object.json'
file = open(path)
jfile = json.loads(file.read())
for i in jfile['config_object']:
    print(jfile['config_object'][i])




        
    
        


