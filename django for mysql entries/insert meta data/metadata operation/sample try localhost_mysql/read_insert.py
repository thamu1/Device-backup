
from datetime import datetime,timedelta
from airflow import DAG
from airflow.providers.mysql.operators.mysql import MySqlOperator
from airflow.operators.bash import BashOperator
import pandas as pd
import json
from airflow.operators.python import PythonOperator
from airflow.providers.mysql.hooks.mysql import MySqlHook
import mysql.connector 

# conn = mysql.connector.connect(
#     host='127.0.0.1',
#     user='root',
#     password='Mysql.08',
#     database='world'
# )

# cursor = conn.cursor()
# sql_query = f'select * from city where ID=1;'
# cursor.execute(sql_query)
# result = cursor.fetchall()


# file = open(f'//wsl.localhost/Ubuntu/home/thamu/airflow/dags/json/j.json')
# jfile = json.loads(file.read())
# print(jfile['value']['0'])

# dic = {"value":results}
# df = pd.DataFrame(dic)
# df.to_json(f'/home/thamu/airflow/dags/json_file/j.json')
# print(df)



class world_city():
    def __init__(self,path):
        
        self.conn = mysql.connector.connect(
            host='127.0.0.1',
            user='root',
            password='Mysql.08',
            database='world'
        )

        self.cursor = self.conn.cursor()
        
        self.path = path
        
        self.db = 'world'
        self.tab = 'city' 
        # self.conn_id = 'withMysql'
        
        self.ID = 0
        self.Name = "" 
        self.CountryCode =""
        self.District = "Theni"
        self.Population =0
        
    def read_json(self):
        # global ID , Name,CountryCode,District,Population
        # file = open('/home/thamu/airflow/json_file/gcp_scheduler.json')
        file = open(self.path)
        jfile = json.loads(file.read())
        for i in jfile['city']:
            print(i)
        
        # values = (jfile['city']['ID'],jfile['city']['Name'],
        #           jfile['city']['CountryCode'],self.District,
        #           jfile['city']['Population'])
        
    def insert(self):
        values = self.read_json()
        # sql = f"insert into {self.db}.{self.tab} values{values};"
        sql = f"select CountryCode from {self.db}.{self.tab} where ID =1;"
        self.cursor.execute(sql)
        result= self.cursor.fetchall()
        print(result)
        # self.conn.commit()
        
path = 'D:/gcp/python class/metadata operation/localhost_mysql/city.json'

wc = world_city(path)

wc.read_json()







