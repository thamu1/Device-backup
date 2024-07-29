from datetime import datetime,timedelta
from airflow import DAG
from airflow.providers.mysql.operators.mysql import MySqlOperator
from airflow.operators.bash import BashOperator
import pandas as pd
import json
from airflow.operators.python import PythonOperator
from airflow.providers.mysql.hooks.mysql import MySqlHook
from datetime import datetime 

comments_sql = "select subjectarea_name from subjectarea\
            where subjectarea_id = self.subjectarea_id;"
gro_bin_id = "select group_binding_id from gcp_scheduler \
    where comments = comments_sql;" # 2 , 5

        
class ingestion_source():
    def __init__(self,path,subjectarea_id):
        self.path = path
        self.subjectarea_id = subjectarea_id
        
        self.db = 'mapr_bigdata_uat_metahub'
        self.tab = 'gcp_ingestion_sources' 
        self.conn_id = 'withMysql'

        self.sourceid = "" 
        self.classification_id = 2  # ingestion part every time 2
        self.subjectarea_id = self.subjectarea_id    # nedd to get from user
        self.credential_id = ""    # access from user
        self.data_type_id = ""     # from user 
        self.application = "spark" # from ingestion side used spark 
        self.sourcedb = ""       # from user
        self.tablebase = ""      # from user
        self.hdl_loadtype = "" # from user
        self.hdl_subtype = "" # from user
        self.frequency = ""  # from user
        self.idcolumn = ""   # from user
        self.datecolumn =  ""    # from user
        self.columnlist = "" # from user
        self.sa_db = ""  # from user
        self.satablename =  ""   # from user
        self.staging1_db =  "NA"
        self.staging1name =  "NA"
        self.staging2_db =  "NA"
        self.staging2name =  "NA"
        self.serverip = ""   # from user
        self.status_flag = ""    # from user
            
         
    def select(self):
        global sourceid
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        sql_query = f"SELECT sourceid FROM {self.db}.{self.tab} order by sourceid desc limit 1;"
        srcid = mysql_hook.run(sql=sql_query)
        self.sourceid = srcid+1 
        
    def read_json(self):
        self.select()
        ing_sour =""
        file = open(self.path)
        # file = open('D:/gcp/python class/metadata operation/ingestion_source.json')
        ing_sour = json.loads(file.read())
        result = (self.sourceid,ing_sour["ingestion_source"]["classification_id"],\
                self.subjectarea_id,ing_sour["ingestion_source"]["credential_id"],
                ing_sour["ingestion_source"]["data_type_id"],ing_sour["ingestion_source"]["sourcedb"],ing_sour["ingestion_source"]["tablebase"]
                ,ing_sour["ingestion_source"]["hdl_loadtype"],ing_sour["ingestion_source"]["hdl_subtype"],ing_sour["ingestion_source"]["frequency"],
                ing_sour["ingestion_source"]["idcolumn"],ing_sour["ingestion_source"]["datecolumn"],ing_sour["ingestion_source"]["columnlist"],
                ing_sour["ingestion_source"]["sa_db"],ing_sour["ingestion_source"]["satablename"],self.staging1_db,self.staging1name,
                self.staging2_db,self.staging2name,ing_sour["ingestion_source"]["serverip"],ing_sour["ingestion_source"]["status_flag"])
        return result
    
    def insert(self):
        values = self.read_json()
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        sql_query = f"insert into {self.db}.{self.tab} values{values};"
        insert_run = mysql_hook.run(sql=sql_query)
        print(insert_run)


class ingestion_controller():
    def __init__(self,path):
        
        self.path = path
        
        
        self.db = 'mapr_bigdata_uat_metahub'
        self.tab = 'gcp_ingestion_controller' 
        self.conn_id = 'withMysql'
        
        self.controller_id = 0
        self.sourceid = 0
        self.fileformat = "PARQUET"
        self.appendmode = "NA"     #  need to change full 'NA'  append 'Y'
        self.sqlquery = "NA"
        self.boundaryquery = "NA"
        self.numberofmappers =  0
        self.splitbycolumn = "NA"
        self.targetdir = " "
        self.warehousedir = "/user/hive/warehouse/"
        self.nullstring = "NA"
        self.fieldsterminater = "NA"
        self.linesterminater = "NA"
        self.logfilelocation = "NA"
        self.reloaddatefrom = "NA"
        self.staging1dir = "NA"
        self.staging2dir = "NA"
        self.tableloadinprocessflag = "NotInProcess"
        self.etl_reloadlist = 'NA'
        self.etl_reloadfrom = "NA"
        self.cdcbacktracedays = "NA"
        self.endtracedays = "NA"
        self.whereclause = "NA"
        self.threshold_for_upperlmt = 0

    def select(self):
        global controller_id, sourceid
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)  

        # Execute a SQL query
        sql_query = f"SELECT controller_id, sourceid FROM {self.db}.{self.tab}\
            order by controller_id desc limit 1;"
        # results = mysql_hook.get_records(sql_query)
        results = mysql_hook.run(sql=sql_query)
        print(results)
        self.controller_id = results[0][0] + 1
        self.sourceid = results[0][1] + 1
        
    def read_json(self):
        self.select()
        global numberofmappers , targetdir
        # file = open('/home/thamu/airflow/json_file/ingestion_controller.json')
        file = open(self.path)
        jfile = json.loads(file.read())
        print(jfile['value'])

        self.numberofmappers = jfile['value']['numberofmappers']
        self.targetdir = jfile['value']['targetdir']

    def insert(self):
        self.read_json()
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)  
        # Execute a SQL query
        sql_query = f"insert into {self.db}.{self.tab} values({self.controller_id},\
            {self.sourceid},{self.fileformat},{self.appendmode},\
            {self.sqlquery},{self.boundaryquery},{self.numberofmappers},\
            {self.splitbycolumn},{self.targetdir},{self.warehousedir},{self.nullstring},\
            {self.fieldsterminater},{self.linesterminater},{self.logfilelocation},\
            {self.reloaddatefrom},{self.staging1dir},{self.staging2dir},{self.tableloadinprocessflag},\
            {self.etl_reloadlist},{self.etl_reloadfrom},{self.cdcbacktracedays},\
            {self.endtracedays},{self.whereclause},{self.threshold_for_upperlmt});"
        
    
        results = mysql_hook.run(sql=sql_query)
        print(f"row updated {results}")
        



class gcp_scheduler():
    def __init__(self,path,subjectarea_id):
        
        self.path = path
        self.subjectarea_id = subjectarea_id
        
        self.db = 'mapr_bigdata_uat_metahub'
        self.tab = 'gcp_scheduler' 
        self.conn_id = 'withMysql'
        
        self.group_binding_id = ""
        self.classification_id = ""
        self.trigger_script = ""
        self.params = "NA"
        self.target = "gcs"
        self.base_trigger_type = "python"
        self.status_flag = 1
        self.exec_flag = "NotInProcess"
        self.developed_by = "bigdata_team"
        self.comments = ""
        
    def select(self):
        global comments,group_binding_id
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        sql_query = f"select subjectarea_name from {self.db}.gcp_subjectarea\
        where subjectarea_id ={self.subjectarea_id} and \
        classification_id = 2;"
        com = mysql_hook.run(sql=sql_query)
        self.comments = com[0][0]
        
        gri_sql = f'select group_binding_id from {self.db}.gcp_scheduler\
            where comments={self.comments} and classification_id = 2;'
        gbi = mysql_hook.run(sql = gri_sql)
        self.group_binding_id = gbi[0][0]
        
        
    def read_json(self):
        # global group_binding_id , classification_id,trigger_script,comments
        # file = open('/home/thamu/airflow/json_file/gcp_scheduler.json')
        self.select()
        file = open(self.path)
        jfile = json.loads(file.read())
        values = (self.group_binding_id,jfile['scheduler']['classification_id'],
                  jfile['scheduler']['trigger_script'],self.params,self.target,
                  self.base_trigger_type,self.status_flag,self.exec_flag,
                  self.developed_by,self.comments )
        print(jfile['scheduler'])
        
    def insert(self):
        values = self.read_json()
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        sql_query = f"insert into {self.db}.{self.tab} values{values};"
        insert_run = mysql_hook.run(sql=sql_query)
        print(insert_run)
 
 
 
class gcp_airflow_scheduler():
    def __init__(self,path,subjectarea_id):
        
        self.db = 'mapr_bigdata_uat_metahub'
        self.tab = 'gcp_airflow_scheduler' 
        self.conn_id = 'withMysql'
        
        self.path = path
        self.subjectarea_id = subjectarea_id
        
        self.airflow_binding_id = 0
        self.group_binding_id = 0
        self.dag_name = ""
        self.parent_bash_script = "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/bash/generic/generic_trigger.sh"
        self.trigger_bash_script = ""
        self.params = "NA"
        self.json_file_loc = ""
        self.status_flag = 1
        self.exec_order = 0
        self.exec_flag = "NotInProcess"
        self.developed_by = "bigdata_team"
        self.comments = ""
        
    def select(self):
        global group_binding_id,dag_name,json_file_loc,comments,airflow_binding_id,trigger_bash_script
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        
        abi_sql = f"select airflow_binding_id from {self.db}.{self.tab} \
            order by airflow_binding_id desc limit 1"
        abi = mysql_hook.run(sql=abi_sql)
        self.airflow_binding_id = abi[0][0]+1
        self.trigger_bash_script = f'/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/dev/gcp/gold_core/config/bigdata/bash/running/airflow_binding_id_{abi[0][0]}.sh'
        
        
        sql_query = f"select subjectarea_name from {self.db}.gcp_subjectarea\
        where subjectarea_id ={self.subjectarea_id};"
        com = mysql_hook.run(sql=sql_query)
        self.dag_name = 'goldCore_'+com[0][0]
        self.comments = com[0][0]
        
        gri_sql = f'select group_binding_id from {self.db}.gcp_scheduler\
            where comments={self.comments} and classification_id = 5;'
        gbi = mysql_hook.run(sql = gri_sql)
        self.group_binding_id = gbi[0][0]
        self.json_file_loc = f'/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/variables/group_binding_id_{self.group_binding_id}'
        
        
    def read_json(self):
        self.select()
        file = open(self.path)
        jfile = json.loads(file.read())
        values = (
            self.airflow_binding_id , self.group_binding_id , self.dag_name , 
            self.parent_bash_script , self.trigger_bash_script , self.params , 
            self.json_file_loc , jfile['gcp_airflow_scheduler']['status_flag'] , jfile['gcp_airflow_scheduler']['exec_order'] , 
            self.exec_flag , self.developed_by , self.comments )
        return values 
    def insert(self):
        values = self.read_json()
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        sql_query = f"insert into {self.db}.{self.tab} values{values};"
        insert_run = mysql_hook.run(sql=sql_query)
        print(insert_run)
     
         
     
class gcp_config_object():           
    def __init__(self,path,subjectarea_id):
        
        self.path = path
        self.subjectarea_id = subjectarea_id
        
        self.db = 'mapr_bigdata_uat_metahub'
        self.tab = 'gcp_config_object' 
        self.conn_id = 'withMysql'
        
        self.object_id = "" 
        self.classification_id =""
        self.subjectarea_id = self.subjectarea_id 
        self.data_type_id =""
        self.object_name = "" 
        self.sourcename = "gcp" 
        self.application = "airflow" 
        self.datset_name = "" 
        self.object_desc = "" 
        self.loadtype = "" 
        self.recon_start_limit ="" 
        self.recon_end_limit ="" 
        self.status_flag =""
        self.bypass_recon_start_limit_hrly_loads = "" 
        self.control_flag = "NotInProcess" 
        self.partition_flag = "" 
        self.frequency = ""  
        self.development_by = "bigdata_team" 
        self.development_date = datetime.now().strftime("%Y-%m-%d")
        self.updated_by = "bigdata_team" 
        self.update_date = datetime.now().strftime("%Y-%m-%d")
                
    def select(self):
        global object_id
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        obj_sql = f"select object_id from {self.db}.{self.tab}\
            order by object_id desc limit 1"
        obj_id = mysql_hook.run(sql=obj_sql)
        self.object_id = obj_id[0][0]+1
        
    def read_json(self):
        self.select()
        li = []
        file = open(self.path)
        jfile = json.loads(file.read())
        for i in jfile['config_object']:
            li.append(jfile['config_object'][i])
        li.insert(2,self.subjectarea_id)
        li.insert(5,self.sourcename )
        li.insert(6,self.application)
        li.insert(14,self.control_flag)
        li.insert(17,self.development_by)
        li.insert(18,self.development_date)
        li.insert(19,self.updated_by )
        li.insert(20,self.update_date)
        return tuple(li)

    def insert(self):
        values = self.read_json()
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        sql_query = f"insert into {self.db}.{self.tab} values{values};"
        insert_run = mysql_hook.run(sql=sql_query)
        print(insert_run)



class gcp_configobjs_ingestion_mapping():
    def __init__(self):
        self.db = 'mapr_bigdata_uat_metahub'
        self.tab = 'gcp_configobjs_ingestion_mapping' 
        self.conn_id = 'withMysql'
        
        self.mapping_id = " " 
        self.object_id =""
        self.sourceid =""
        self.skip_flag = 0
                
    def select(self):
        global mapping_id,object_id,sourceid
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        
        map_id_sql = f"select mapping_id from {self.db}.{self.tab}\
            order by mapping_id desc limit 1;"
        map_id = mysql_hook.run(sql=map_id_sql)
        self.mapping_id = map_id[0][0]
        
        obj_id_sql = f"select object_id from {self.db}.gcp_config_objects\
            order by object_id desc limit 1"  
        obj_id = mysql_hook.run(sql=obj_id_sql) 
        self.object_id = obj_id[0][0]
        
        src_id_sql = f"select source_id from {self.db}.gcp_ingestion_sources\
            order by source_id desc limit 1"  
        src_id = mysql_hook.run(sql=src_id_sql)  
        self.sourceid = src_id[0][0]
        return (self.mapping_id,self.object_id,self.sourceid,self.skip_flag)
        
    def insert(self):
        values = self.select()
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        sql_query = f"insert into {self.db}.{self.tab} values{values};"
        insert_run = mysql_hook.run(sql=sql_query)
         

class gcp_airflow_configobjs_mapping:
    def __init__(self,path,subjectarea_id):
        self.db = 'mapr_bigdata_uat_metahub'
        self.tab = 'gcp_airflow_configobjs_mapping' 
        self.conn_id = 'withMysql'
        
        self.path = path
        self.subjectarea_id = subjectarea_id
        
        self.airflow_mapping_id =""
        self.airflow_binding_id =""
        self.exec_order = 1
        self.object_id ="" 
        self.skip_flag = 0 
        self.airflow_control_flag =""
        self.gcp_schema_initial ="" 
        self.gcp_schema_intermmediate=""
        self.gcp_schema_final ="" 
        self.gcp_schema_sas_final ="NA" 
        self.gcp_partition_cols ="" 
        self.gcp_cluster_cols ="" 
        self.obj_gcs_path =""
        self.obj_gcs_final_alter_name ="NA" 
        self.obj_gcs_stg_to_final_split_flag="" 
        self.vw_sql_except_columns ="NA"
        self.vw_sql_loc =""
        self.comments ="NA"
    def select(self):
        global airflow_mapping_id ,airflow_binding_id,object_id
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        
        map_sql = f"select airflow_mapping_id from {self.db}.{self.tab}\
            order by airflow_mapping_id desc limit 1;"
        air_map_id = mysql_hook.run(sql=map_sql)
        self.airflow_binding_id = air_map_id[0][0]
        self.object_id = air_map_id[0][0]
        
        comments_sql = f"select subjectarea_name from {self.db}.gcp_subjectarea\
            where subjectarea_id={self.subjectarea_id};"
        comments = mysql_hook.run(sql=comments_sql)
        
        air_bin_sql = f"select airflow_binding_id from gcp_airflow_scheduler\
            where comments ={comments[0][0]} "
        air_bin_id = mysql_hook.run(sql=air_bin_sql)
        self.airflow_binding_id = air_bin_id[0][0]
    
    def read_json(self):
        self.select()
        li = []
        file = open(self.path)
        jfile = json.loads(file.read())
        for i in jfile['gcp_airflow_configobjs_mapping']:
            li.append(jfile['gcp_airflow_configobjs_mapping'][i])
        li.insert(0,self.airflow_mapping_id)
        li.insert(1,self.airflow_binding_id)
        li.insert(2,self.exec_order)
        li.insert(3,self.object_id)
        li.insert(4,self.skip_flag)
        li.insert(9,self.gcp_schema_sas_final)
        li.insert(13,self.obj_gcs_final_alter_name)
        li.insert(15,self.vw_sql_except_columns)
        li.insert(17,self.comments)
        
        return tuple(li)
    def insert(self):
        values = self.read_json()
        mysql_hook = MySqlHook(mysql_conn_id=self.conn_id)
        sql_query = f"insert into {self.db}.{self.tab} values{values};"
        insert_run = mysql_hook.run(sql=sql_query)
        print(insert_run)
    


# path = 'D:/gcp/python class/metadata operation/gcp_airflow_configobjs_mapping.json'
# s = gcp_airflow_configobjs_mapping(path,'fghj')
# print(s.read_json())          









            
                