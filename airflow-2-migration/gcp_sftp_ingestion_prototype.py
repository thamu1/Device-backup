
# spark-submit --jars /mnt/data/codebase/bigdata/prod/ingestion/online/lib/gcp_sftp_spark_ingestion/spark-filetransfer_2.12-0.3.0.jar /mnt/data/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/bin/gcp_sftp_spark_ingestion/gcp_sftp_ingestion_prototype.py "140" "20240910193236,20240910073148" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json"


import paramiko
from pyspark.sql.functions import lit
import mysql
import mysql.connector
import json
from pyspark.sql import SparkSession
from datetime import datetime, date
import sys
import os


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
        
def sftpDataPush(host, username, password, remote_path, local_path,  port=22):
    # host = "PWSFTP01.classic.pchad.com"
    # username = "experianp"
    # password = "$pring2015!"
    # port = 22
    
    transport = paramiko.Transport((host, port))
    transport.connect(username=username, password=password)
    sftp = paramiko.SFTPClient.from_transport(transport)
    
    remote_file = sftp.file(remote_path, 'rb')
    
    print(f"file path ::: {local_path}")
    
    local_file = open(local_path, 'wb')
    while True:
        data = remote_file.read(5 * 1024 * 1024) 
        if not data:
            break
        local_file.write(data)
    
    remote_file.close()
    sftp.close()
    transport.close()
    

if len(sys.argv) == 4:
    sourceid = str(sys.argv[1])
    sftp_fileIdList = str(sys.argv[2])
    database_prop_file = str(sys.argv[3])
    insufficient_arguments = False
    
else:
    insufficient_arguments = True
    print("""Insufficient arguments passed for executing the python util.
    Two arguments to be passed:
    1. Group_Binding_ID
    2. The GCP ETL Generic Properties JSON file""")

if not insufficient_arguments:

    mysql_con_var = json.load(open(database_prop_file))

    host = mysql_con_var["gcp_etl_mysql_hostname"]
    db_name = mysql_con_var["gcp_etl_mysql_dbname"]
    username = mysql_con_var["gcp_etl_mysql_username"]
    password = mysql_con_var["gcp_etl_mysql_password"]

    spark = (
        SparkSession.builder
        .config("spark.jars", "/mnt/data/codebase/bigdata/prod/ingestion/online/lib/gcp_spark_ingestion/gcs-connector-latest-hadoop2.jar")
        .config("spark.hadoop.google.cloud.auth.service.account.json.keyfile", "/mnt/keys/gcs_key.json")
        .appName("gcp_ingestion_fraemework")
        .getOrCreate()
    )

    spark.conf.set("spark.sql.sources.partitionOverwriteMode","dynamic")

    query = f"""select mapping_id, batch_id, jdbc_url, user_name,
        cast(aes_decrypt(password,'bigdataetl_ingestion') as char charset utf8) as  password,
        numberofmappers, columnlist, min_value, max_value, targetdir, tableloadinprocessflag 
        from mapr_bigdata_uat_metahub.vw_gcp_ingestion_details
        where sourceid = {sourceid}
        """
        
    vw_gcp_ingestion_details_result =  mysql_select_exec(
            query= query
            , host_name= host
            , usr= username
            , pwd= password
            , db_name= db_name
        )
    
    for mysql_sourceid_metadata in vw_gcp_ingestion_details_result:

        if (mysql_sourceid_metadata[10] == "NotInProcess"):
            
            query = f"update gcp_ingestion_controller set tableloadinprocessflag='InProcess' where sourceid = {sourceid}"
            
            mysql_update_insert_exec(
                query= query
                , host_name= host
                , usr= username
                , pwd= password
                , db_name= db_name
            )
            
            mysql_columnlist  = mysql_sourceid_metadata[6].split(",")
            
            for fileId in sftp_fileIdList.split(","):
                
                try:
                    jobStartTime = datetime.now()
                    
                    local_path = f"/mnt/data/codebase/bigdata/prod/application_logs/gcp_etl_ingestion_compute/sftp_file_landing_temp_location/{mysql_sourceid_metadata[2].split('@')[2]}_{fileId}.txt"
                    
                    sftpDataPush(
                            host= mysql_sourceid_metadata[2].split("@")[0]
                            , username = mysql_sourceid_metadata[3]
                            , password = mysql_sourceid_metadata[4]
                            , remote_path = mysql_sourceid_metadata[2].split("@")[1] + mysql_sourceid_metadata[2].split("@")[2] + "_" + fileId + ".txt"
                            , local_path = local_path
                        )
                    
                    df = spark.read.csv(path = local_path, sep="\t" , header=True, inferSchema=True)
                    df = df.withColumn("file_event_dt", lit(f"{fileId[0:4]}-{fileId[4:6]}-{fileId[6:8]}"))
                    df = df.withColumn("file_id", lit(fileId))
                    df = df.selectExpr(mysql_columnlist)
                    df = df.coalesce(1)
                    
                    df.write.partitionBy("file_event_dt","file_id").mode("overwrite").parquet(mysql_sourceid_metadata[9])                    
                    df_cnt = str(df.count())
                    
                    jobEndTime = datetime.now()
                    jobRunDt = date.today()
                    
                    query = f"""insert into gcp_ingestion_lastrun(mapping_id,batch_id,jobid,jobstatus,totalrecordcount,upperboundvalue,lastboundvalue,jobstarttime,jobendtime,lastrundate,jarname,jobruntime,logfilelocation) values("{mysql_sourceid_metadata[0]}", "{mysql_sourceid_metadata[1]}", "{fileId}", "Success", "{df_cnt}", "{mysql_sourceid_metadata[7]}", "{mysql_sourceid_metadata[8]}", "{jobStartTime}", "{jobEndTime}", "{jobRunDt}", "NA" , "NA" , "NA")"""
                    
                    mysql_update_insert_exec(
                        query= query
                        , host_name= host
                        , usr= username
                        , pwd= password
                        , db_name= db_name
                    )
                    
                    if(os.path.exists(path= local_path)):
                        os.remove(path= local_path)
                        
                        print("The local path is removed")
                    
                except Exception as e:
                    jobStartTime = datetime.now()
                    jobEndTime = datetime.now()
                    jobRunDt = date.today()
                    
                    query = f"""insert into gcp_ingestion_lastrun(mapping_id,batch_id,jobid,jobstatus,totalrecordcount,upperboundvalue,lastboundvalue,jobstarttime,jobendtime,lastrundate,jarname,jobruntime,logfilelocation) values("{mysql_sourceid_metadata[0]}", "{mysql_sourceid_metadata[1]}", "{fileId}", "Failed", "0", "{mysql_sourceid_metadata[7]}", "{mysql_sourceid_metadata[8]}", "{jobStartTime}", "{jobEndTime}", "{jobRunDt}", "NA" , "NA" , "NA")"""
                    
                    mysql_update_insert_exec(
                        query= query
                        , host_name= host
                        , usr= username
                        , pwd= password
                        , db_name= db_name
                    )
                    
                    print(e)
                    
            
                    
        else:
            print("The previous job is in process for the sourceid: " + sourceid)
            
    spark.stop()                 
            
else:
    
    print("insufficient Argument were passed...")            
            
            
            
            