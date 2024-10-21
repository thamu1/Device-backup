"""
Note:
    Before coding need to check the following things:
        - console.cloud.google.com -> "apis & services" -> library -> enable ga4(google analytic data and google analytic report ) api
        - we need to create a service account.
        - download the private key json (service account details). 
        - in analytic UI add your service id (follow the below).
            => https://analytics.google.com/analytics/web/#/p331273219/reports/intelligenthome
            => home -> admin -> account access management -> add = (your service account mail id) -> set as viewer (enough)
            => Very the following link for dimension and matrics "https://ga-dev-tools.google/ga4/dimensions-metrics-explorer/"
        - call this file link the below:
            python3 /python_file_loc/test2.py "group_binding_id" "service_id_json_location"
            
        - store place : /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/staging_temp/bigdata/prod/online_pyprocess/ga_wom_api/ga4/

"""

# types of report can get, use below  link
# https://developers.google.com/analytics/devguides/reporting/data/v1

import os
import shutil
from datetime import datetime, timedelta, date
from typing import List
from google.analytics.data_v1beta import BetaAnalyticsDataClient, FilterExpression, FilterExpressionList, Filter 
from google.analytics.data_v1beta.types import (Dimension, Metric, DateRange, Metric, OrderBy, FilterExpression, RunReportRequest)
from google.oauth2 import service_account
import pandas as pd
import time
import sys
from subprocess import Popen, PIPE
import configparser
import smtplib
from email.message import EmailMessage
import subprocess
import mysql.connector
import pandas
import numpy as np
import json

group_binding_id = "" # 101
etl_generic_prototype_file_loc = ""  # "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/staging_temp/bigdata/prod/test/thamo/python/ga4/gcp_json_file.json"


# python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_ga4_wom_api/ga4 daily/ga4_dailly.py "101" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_ga4_wom_api/ga4 daily/gcp_json_file.json"

if len(sys.argv) >= 2:
    group_binding_id = sys.argv[1]
    etl_generic_prototype_file_loc = sys.argv[2]
    insufficient_arguments = False
else:
    insufficient_arguments = True
    print("Insufficient arguments passed for executing the python util.")
    

if(not insufficient_arguments):

    def mysql_select_exec(query,host_name,usr,pwd,db_name):
        try:
            con = mysql.connector.connect(user = str(usr),password = str(pwd),host = host_name,database = str(db_name))
            cursor = con.cursor()
        except mysql.connector.Error as err:
            raise Exception("MySQL connection failure")
        else:
            query = cursor.execute(f"{query}")
            return cursor.fetchall()
        finally:
            cursor.close()
            con.close()

    def mysql_update_insert_exec(query,host_name,usr,pwd,db_name):
        try:
            con = mysql.connector.connect(user = str(usr),password = str(pwd),host = host_name,database = str(db_name))
            cursor = con.cursor()
        except mysql.connector.Error as err:
            return 0
        else:
            query = cursor.execute(f"{query}")
            con.commit()
            return cursor.rowcount
        finally:
            cursor.close()
            con.close()

    def send_mail(to_email, subject, message, server, from_email):
        msg = EmailMessage()
        msg['Subject'] = subject
        msg['From'] = from_email
        msg['To'] = ', '.join(to_email)
        msg.set_content(message)
        server = smtplib.SMTP(server)
        server.send_message(msg)
        server.quit()

    def log(text):
        
        text = f"{datetime.now()} : {text} \n"
        
        log_file = open(LogFile_Loc, "a+")
        log_file.write(text)
        

    def hdl_to_gcs(hdl, gs):
        cmd = f"hadoop distcp -D 'HADOOP_OPTS=-Xmx12g' -D "\
            f"HADOOP_CLIENT_OPTS='-Xmx12g -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70 "\
            f"-XX:+CMSParallelRemarkEnabled' -D 'mapreduce.map.memory.mb=12288' -D 'mapreduce.map.java.opts=-Xmx10g' -D "\
            f"'mapreduce.reduce.memory.mb=12288' -D 'mapreduce.reduce.java.opts=-Xmx10g' -overwrite -m 20 "\
            f"{hdl} "\
            f"{gs} "
            
        process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,text=True)
        stdout, stderr = process.communicate()

        if process.returncode == 0:
            print("Execution successful!")
            print("Output:")
            print(stdout)
        else:
            print("Execution failed!")
            print("Error message:")
            print(stderr)


        """
        This dfmaker will give the DataFrame from the GA4 response.
        """
    def dfmaker(res, mode):
        
        def name_change(name:str):
            
            # Map the sessionSource into their group
            name = name.lower()
            if("facebook" in name):
                return "Facebook"
            elif(("google" or "bing" or "yahoo" or "duckduckgo" or "yandex" or "search") in name):
                return "Search"
            elif(("news") in name):
                return "News aggregator"
            elif(("email") in name):
                return "Email"
            else:
                return "Direct/Other"
                    
        dim_head = res.dimension_headers
        mat_head = res.metric_headers
        rows = res.rows

        header = [i.name for i in dim_head] + [i.name for i in mat_head]

        row_value = []
        for row in (rows):
            row_flag = []
            for dv in (row.dimension_values):
                row_flag.append(dv.value)
                
            for mv in (row.metric_values):
                row_flag.append(mv.value)
            
            row_value.append(row_flag)
            
        df = pd.DataFrame(data = row_value, columns= header)
        
            
        after_con = map(name_change, df['sessionSource'])

        df['sessionSource'] = list(after_con)
        
        df.columns = ["Date", "Hostname", "Source Group", "Users", "Pageview", "Sessions"]
        
        if(mode == "overall"):
            df["Hostname"] = "*"
            df["Source Group"] = "*"
        elif(mode in ["major", "minor"]):
            df["Source Group"] = "*"
            
        return(df)


    """
    This report Function will give the GA4 report as a response.
    """
    def report(recon_st_limit:int, recon_end_limit:int,mode:str, off:int, property_id:str, credentials_path:str, hostnames:list , dimensions: List[str], metrics: List[str]):

        st_date = str(date.today() - timedelta(days=recon_st_limit))
        en_date = str(date.today() - timedelta(days=recon_end_limit))
        
        countrynames = ['United States']
        groupnames = ['Partner']
        
        # from google.oauth2 import service_account
        # credentials = service_account.Credentials.from_service_account_file(filename=credentials_path,)
        # client = BetaAnalyticsDataClient(credentials=credentials)
        
        os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path
        client = BetaAnalyticsDataClient() 
        

        dimension_list = [Dimension(name=dim) for dim in dimensions]
        metrics_list = [Metric(name=m) for m in metrics]
                
        if(mode in ["minor", "overall", "overall_sg"]):
            request = RunReportRequest(
                    property=f"properties/{property_id}",
                    ignore_unknown_fields= True,
                    dimensions=dimension_list,
                    metrics=metrics_list,
                    date_ranges=[DateRange(start_date=st_date, end_date=en_date)],
                    limit = 250000,
                    offset = off,
                    order_bys = [OrderBy(dimension = OrderBy.DimensionOrderBy(dimension_name = "date") , desc = True)],
                    dimension_filter=FilterExpression(
                        and_group=FilterExpressionList(
                            expressions=[
                                FilterExpression(
                                    filter=Filter(field_name="country", in_list_filter = Filter.InListFilter(values = countrynames, case_sensitive = True)),
                                ),
                                FilterExpression(
                                    not_expression=FilterExpression( filter = Filter(field_name="sessionDefaultChannelGroup", in_list_filter = Filter.InListFilter(values = groupnames, case_sensitive = True))),
                                ),
                                FilterExpression(
                                    not_expression=FilterExpression(filter=Filter(field_name="hostName", in_list_filter = Filter.InListFilter(values = hostnames, case_sensitive = True))),
                                ),
                            ]
                        ),
                    ), 
                )
        
        elif(mode == "major"):
            request = RunReportRequest(
                    property=f"properties/{property_id}",
                    ignore_unknown_fields= True,
                    dimensions=dimension_list,
                    metrics=metrics_list,
                    date_ranges=[DateRange(start_date=st_date, end_date=en_date)],
                    limit = 250000,
                    offset = off,
                    order_bys = [OrderBy(dimension = OrderBy.DimensionOrderBy(dimension_name = "date") , desc = True)],
                    dimension_filter=FilterExpression(
                        and_group=FilterExpressionList(
                            expressions=[
                                FilterExpression(
                                    filter=Filter(field_name="hostName", in_list_filter = Filter.InListFilter(values = hostnames, case_sensitive = True)),
                                ),
                                FilterExpression(
                                    filter=Filter(field_name="country", in_list_filter = Filter.InListFilter(values = countrynames, case_sensitive = True)),
                                ),
                                FilterExpression(
                                    not_expression=FilterExpression(filter = Filter(field_name="sessionDefaultChannelGroup", in_list_filter = Filter.InListFilter(values = groupnames, case_sensitive = True))),
                                ),
                            ]
                        ),
                    ), 
                )
            
        
        
        response = client.run_report(request)
        
        return(response)


    def get_report(hdl_loc:str,gs_loc:str, mode:str, property_id:str, credential:str, recon_st_limit:int=8, recon_end_limit:int=1 ):
        
        print(mode)
        
        if(mode == "minor"):
        
            hostName = [
                'www.wideopenroads.com',
                'fanbuzz.com',
                'altdriver.com',
                'www.wideopenspaces.com',
                'www.wideopeneats.com',
                'www.wideopenpets.com',
                'www.wideopencountry.com',
            ]
        
        elif(mode == "major"):
            hostName = [
                'www.wideopenroads.com',
                'fanbuzz.com',
                'altdriver.com',
                'www.wideopenspaces.com',
                'www.wideopeneats.com',
                'www.wideopenpets.com',
                'www.wideopencountry.com',
            ]

        elif(mode == "overall"):
            hostName = [
                'www.thetruthaboutknives.com',
                'www.thetruthaboutguns.com',
                'rare.us',
            ]

        elif(mode == "overall_sg"):
            hostName = [
                'www.thetruthaboutknives.com',
                'www.thetruthaboutguns.com',
                'rare.us',
            ]
        
        log(f"currently executing the {mode}")
        
        if(mode in ['minor', 'major', 'overall','overall_sg']): 
            
            dim = ["date", "hostName","sessionSource"]
            met = ["totalUsers","screenPageViews", "sessions"]
                    
            off = 0
            
            df_concat = pd.DataFrame()
            
            rm_file = f"{hdl_loc}{mode}/" # src_ing_stg={date.today()-timedelta(days=1)}"
            st_file = f"{hdl_loc}{mode}/src_ing_dt={date.today()}"

            
            if(os.path.exists(rm_file)):
                for i in list(os.walk(rm_file))[0][1]:
                    pa = f"{rm_file}{i}"
                    if(os.path.isdir(pa)):
                        shutil.rmtree(f"{pa}")
                log(f"yesterday file has deleted successfully..")
                               
            if(os.path.exists(st_file)):
                shutil.rmtree(f"{st_file}")
                os.mkdir(st_file)
                log("today's file was replaced")
                
            else:
                os.mkdir(st_file)
                
            log(f"today's folder created successfully as {st_file}")
                
            for i in range(2):
                res = report(
                    property_id=property_id,
                    credentials_path = credential,
                    recon_st_limit=recon_st_limit,
                    recon_end_limit = recon_end_limit,
                    mode = mode,
                    off = off,
                    hostnames = hostName,
                    dimensions=dim, # ga:hostname, ga:country, ga:channelGrouping
                    metrics=met, # ga:users, ga:pageviews, ga:sessions
                )
                
                off += 250000
                
                df = dfmaker(res=res, mode = mode)
                
                df_concat = pd.concat([df_concat, df])

            df_concat.drop_duplicates(inplace=True)
                        
            df_concat["Users"] = df_concat["Users"].astype(dtype= "int64")
            df_concat["Pageview"] = df_concat["Pageview"].astype(dtype= "int64")
            df_concat["Sessions"] = df_concat["Sessions"].astype(dtype= "int64")
                        
            df_concat = df_concat.groupby(["Date", "Hostname", "Source Group"]).sum()
            # print(df_concat.head(5))
            file = f"{st_file}/{mode}_report.csv"   
            df_concat.to_csv(file)
            
            log(f"The CSV file has been successfully stored into {file}")
                
            log(f"The report for mode '{mode}' has been successfully generated.")
            
            hdl_to_gcs(hdl = f"{st_file}/", gs = f"{gs_loc}src_ing_dt={date.today()}")
            
            log(f"The CSV file for mode '{mode}' has been successfully stored in Google Cloud Storage (GCS)")
            
            
    def main(sourceid:int, mapping_id:int ,recon_st_limit:int, recon_end_limit:int, hdl_loc:str, gs_loc:str , mode:str, property_id:str):
        
        log(f"{sourceid} has start process.")
        
        query = f"select sim.sourceid from gcp_ingestion_lastrun as il "\
            f"join gcp_scheduler_ingestion_mapping as sim on il.mapping_id=sim.mapping_id "\
            f"where sim.group_binding_id = {group_binding_id} "\
            f"and il.lastrundate = current_date() - interval 0 day "\
            f"and jobstatus = 'Success'"
        
        success_source_id = mysql_select_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)
        last_run_source_id = np.array(success_source_id).flatten()
        
        log(f"Check if {sourceid} has been successful today or not.")
        
        if(sourceid not in last_run_source_id):

            query = f"update mapr_bigdata_uat_metahub.gcp_ingestion_controller set tableloadinprocessflag = 'InProcess' where sourceid = {sourceid}"
            flag = mysql_update_insert_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)
            
            log(f"The control flag for '{sourceid}' has been updated to 'InProcess'.")
            
            try:   
                get_report(recon_st_limit = int(recon_st_limit), recon_end_limit = int(recon_end_limit), 
                    hdl_loc = str(hdl_loc),gs_loc = gs_loc, mode=str(mode), property_id = property_id, 
                    credential = service_account_loc)
                
                status = "Success"
                log(f"{sourceid} achieved success for the day.")
                
            except:
                status = "Failed"
                log(f"{sourceid} encountered a failure for the day.")
                failure_capture.append([sourceid,mapping_id, recon_st_limit, recon_end_limit, hdl_loc, gs_loc, mode, property_id])
                
            end_time = str(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
                
            try:
                col = "(mapping_id, batch_id, jobid, jobstatus,totalrecordcount, upperboundvalue,lastboundvalue,jobstarttime, jobendtime, lastrundate, jarname, jobruntime, logfilelocation)"
                val = f"({mapping_id}, 0 , 'NA','{status}','0', '0', '0', '{st_time}', '{end_time}', '{today}', 'NA', 'NA', 'NA')"        
                query = f"insert into mapr_bigdata_uat_metahub.gcp_ingestion_lastrun{col} values{val}"
                flag =  mysql_update_insert_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)
                
            except:
                failure_capture.append([sourceid,mapping_id, recon_st_limit, recon_end_limit, hdl_loc, mode, property_id])
            
            query = f"update mapr_bigdata_uat_metahub.gcp_ingestion_controller set tableloadinprocessflag = 'NotInProcess' where sourceid = {sourceid}" 
            flag =  mysql_update_insert_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)
        else:
            log(f"The source with ID : '{sourceid}' has already achieved success for the day.")
            print(f"source id: {sourceid} already success for the day")
        

     
    # ============================= Code start Here  ============================= #
    try:
        # Read the Json property
        jpath = open(etl_generic_prototype_file_loc, "r+")
        j = json.load(jpath)
        
        # mysql
        host_name = j["host_name"]
        usr = j["usr"]
        pwd = j["pwd"]
        db_name = j["db_name"]

        # Log File
        LogFile_Loc = j["LogFile_Loc"]
        LogFile_Loc = f"{LogFile_Loc}GA4_wom_log_{date.today()}.txt"
        if(os.path.exists(LogFile_Loc)):
            os.remove(LogFile_Loc)
            
        
        log(f"============================= {date.today()} =============================")
        
        log(f"The JSON file was successfully read from {etl_generic_prototype_file_loc}")

        # Email Property
        email_sendmail = j["email_sendmail"]
        email_server = j["email_server"]
        email_from = j["email_from"]
        email_to = j["email_to"]

        # Ga4 Property
        property_id = j["property_id"] # 331273219
        service_account_loc = j["service_account_loc"]
        Object_List = j["Object_List"]
        # gs_loc = j["gs_loc"]

        # Retry
        retry = j["retry"]

        today = str(date.today())

        hdl_to_gs_loc_capture = dict()
        failure_capture = []

        # process start here
        query = f"SELECT status_flag, exec_flag FROM mapr_bigdata_uat_metahub.gcp_scheduler where group_binding_id = {group_binding_id}" # NotInProcess
        scheduler_flag_check = mysql_select_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)

        log(f"gcp_scheduler checking it's in NotInProcess for group binding id : {group_binding_id}")

        if(str(scheduler_flag_check[0][0]) == "1"):
            
            if(str(scheduler_flag_check[0][1]) == "NotInProcess"):
            
                query = f"update mapr_bigdata_uat_metahub.gcp_scheduler set exec_flag = 'InProcess' where group_binding_id = {group_binding_id}"
                mysql_update_insert_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)
                
                log(f"gcp_scheduler is NotInProcess for group binding id : {group_binding_id} so it changed to InProcess")

                for i in Object_List:
                    for j in i:
                        st_time = str(datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
                        
                        try:
                        
                            query = f"SELECT sourceid , tablebase, min_value, "\
                                f"max_value, targetdir FROM mapr_bigdata_uat_metahub.vw_gcp_ingestion_details "\
                                f"where parent_binding_id = {group_binding_id} and sourceid = {i[j]['sourceid']}"
                            res = mysql_select_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name) 
                        
                            sourceid = i[j]["sourceid"]
                            hdl_location = i[j]["hdl_location"]
                            start_limit = res[0][2]
                            end_limit = res[0][3]
                            gs_loc = res[0][4]
                            mapping_id = i[j]["mapping_id"]
                                                        
                            main(
                                sourceid= sourceid,
                                mapping_id = mapping_id,
                                recon_st_limit = start_limit,
                                recon_end_limit = end_limit,
                                hdl_loc= hdl_location,
                                gs_loc = gs_loc,
                                mode = j,
                                property_id = property_id
                            )
                            
                        except:   
                            log(f" {i[j]['sourceid']} not in the vw_ingestion_details")
                            print(f" {i[j]['sourceid']} not in the vw_ingestion_details")
                            query = f"update mapr_bigdata_uat_metahub.gcp_scheduler set exec_flag = 'NotInProcess' where group_binding_id = {group_binding_id}"
                            mysql_update_insert_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)

                        
                query = f"update mapr_bigdata_uat_metahub.gcp_scheduler set exec_flag = 'NotInProcess' where group_binding_id = {group_binding_id}"
                mysql_update_insert_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)
                
                log(f"report job successfully taken care for group binding id : {group_binding_id}")
            else:
                
                log(f"gcp_scheduler {group_binding_id} is  InProcess")
                query = f"update mapr_bigdata_uat_metahub.gcp_scheduler set exec_flag = 'NotInProcess' where group_binding_id = {group_binding_id}"
                mysql_update_insert_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)

        else:
            log(f"gcp_scheduler {group_binding_id} flag is 0")

    except:
        log(f"The JSON file was Failed to read from {etl_generic_prototype_file_loc}")


    unique_failure_capture = []
    unique_failure_capture = failure_capture.copy()
            
    print("your failure data: ", unique_failure_capture)

    if(len(unique_failure_capture) > 0):
        
        query = f"update mapr_bigdata_uat_metahub.gcp_scheduler set exec_flag = 'NotInProcess' where group_binding_id = {group_binding_id}"
        mysql_update_insert_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)

        while(retry > 0):
            for id in unique_failure_capture:
                
                log(f"group binding id:{id[0]} filed so, the subject area again changed to Not in process")
                
                query = f"update mapr_bigdata_uat_metahub.gcp_ingestion_controller set tableloadinprocessflag = 'NotInProcess' where sourceid = {id[0]}" 
                flag =  mysql_update_insert_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)
                
                log(f"An error occurred for ID: {id[0]}, prompting it to be triggered again for the day.")

                main(
                    sourceid = id[0],
                    mapping_id = id[1],
                    recon_st_limit = id[2],
                    recon_end_limit = id[3],
                    hdl_loc = id[4],
                    gs_loc = gs_loc[5],
                    mode = id[6],
                    property_id = id[7]
                )
            retry -= 1
        
        query = f"update mapr_bigdata_uat_metahub.gcp_scheduler set exec_flag = 'NotInProcess' where group_binding_id = {group_binding_id}"
        mysql_update_insert_exec(query=query, host_name=host_name, usr=usr, pwd=pwd, db_name=db_name)
            
    else:
        log(f"No failures occurred; the daily report was successfully generated and stored.")

else:
    print("insufficient parameter passed..")






 