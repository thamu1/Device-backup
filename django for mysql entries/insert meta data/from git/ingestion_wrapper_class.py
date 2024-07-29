import mysql.connector
import datetime
import os
import subprocess
import sys
import json
import smtplib
from email.message import EmailMessage
import pymssql
from google.cloud import storage
from google.cloud import bigquery

# Arguments to be passed to execute the util dynamically
########################################################
parent_group_binding_id = ""
python_exec_property_loc = ""
if len(sys.argv) == 3:
    parent_group_binding_id = sys.argv[1]
    python_exec_property_loc = sys.argv[2]
    insufficient_arguments = False
else:
    insufficient_arguments = True
    print("Insufficient arguments passed for executing the python util.")

# Static Control Variables
#################
terminate = False
email_trigger = True

# Defining some functions
########################
def logging_func(txt):
    with open(f"{gcp_ingestion_log_loc}/execution.log", "a") as logfile:
        logfile.write(str(datetime.datetime.now()) + f": {txt}\n")


def operations_on_file(file_name, operation, txt_to_append, newline_character_flag):
    if operation == "w":
        with open(f"{file_name}", f"{operation}") as myFile:
            pass
    else:
        if newline_character_flag == "Y":
            with open(f"{file_name}", f"{operation}") as myFile:
                myFile.write(txt_to_append + "\n")
        else:
            with open(f"{file_name}", f"{operation}") as myFile:
                myFile.write(txt_to_append)


def mssql_select_exec(query, host_name, usr, pwd, db_name):
    try:
        con = pymssql.connect(server=str(host_name), user=str(usr), password=str(pwd), database=str(db_name))
        cursor = con.cursor()
    except mysql.connector.Error as err:
        logging_func("")
        logging_func("Connection unsuccessful, so the further process is terminated")
        terminate = True
    else:
        logging_func("Connection to MyDB Successful")
        query = cursor.execute(f"{query}")
        return cursor.fetchall()
    finally:
        cursor.close()
        con.close()


def mysql_select_exec(query, host_name, usr, pwd, db_name):
    try:
        con = mysql.connector.connect(user=str(usr), password=str(pwd), host=host_name, database=str(db_name))
        cursor = con.cursor()
    except mysql.connector.Error as err:
        logging_func("")
        logging_func("Connection unsuccessful, so the further process is terminated")
        terminate = True
    else:
        logging_func("Connection to MyDB Successful")
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
        logging_func("")
        logging_func("Connection unsuccessful, so the further process is terminated")
        terminate = True
        return 0
    else:
        logging_func("Connection to MyDB Successful")
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


def upload_blob(bucket_name, source_file_name, destination_blob_name, gcp_json_conn_path):
    try:
        storage_client = storage.Client.from_service_account_json(json_credentials_path=gcp_json_conn_path)
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(destination_blob_name)
        blob.upload_from_filename(source_file_name)
        return True
    except:
        return False

def if_tbl_exists(client, table_ref):
    try:
        client.get_table(table_ref)
        return True
    except:
        return False

# Actual Code Execution logic begins
####################################
if insufficient_arguments:
    print("Insufficient Arguments. Two arguments to be passed: a) parent_group_binding_id b) python_exec_property_loc")
else:
    # Reading the values from the property loc
    with open(python_exec_property_loc) as data_file:
        data = json.loads(data_file.read())

    if len(data) > 0:
        print("The data read from JSON was successful")

        # date and time variables
        curr_dttime = str(datetime.datetime.now())
        curr_dt = curr_dttime[:10].replace("-", "")
        curr_sec = curr_dttime[-6:]

        # Inital declaration of the variable
        gcp_ingestion_log_loc = data["ingestion_log_loc"] + "parent_binding_id_" + str(parent_group_binding_id) \
                                + "/" + curr_dt + "/" + curr_sec

        # Creating the log directory
        try:
            os.makedirs(gcp_ingestion_log_loc)
        except OSError:
            print("Creation of the initial directories failed")
            terminate = True
        else:
            operations_on_file(f"{gcp_ingestion_log_loc}/execution.log", "w", "NA", "NA")

        if not terminate:
            logging_func(f"The code execution started for the parent_binding_id: {parent_group_binding_id}")
            logging_func("")

            # Capturing the values from the JSON read
            # ***************************************
            logging_func("Capturing the values from the JSON read")
            logging_func("---------------------------------------")
            gcp_etl_mysql_hostname = data["gcp_etl_mysql_hostname"]
            logging_func(f"gcp_etl_mysql_hostname = {gcp_etl_mysql_hostname}")
            gcp_etl_mysql_dbname = data["gcp_etl_mysql_dbname"]
            logging_func(f"gcp_etl_mysql_dbname = {gcp_etl_mysql_dbname}")
            gcp_etl_mysql_username = data["gcp_etl_mysql_username"]
            logging_func(f"gcp_etl_mysql_username = {gcp_etl_mysql_username}")
            gcp_etl_mysql_password = data["gcp_etl_mysql_password"]
            logging_func(f"gcp_etl_mysql_password = #############")

            gcp_dw_mssql_hostname = data["gcp_dw_mssql_hostname"]
            logging_func(f"gcp_dw_mssql_hostname = {gcp_dw_mssql_hostname}")
            gcp_dw_mssql_dbname = data["gcp_dw_mssql_dbname"]
            logging_func(f"gcp_dw_mssql_dbname = {gcp_dw_mssql_dbname}")
            gcp_dw_mssql_username = data["gcp_dw_mssql_username"]
            logging_func(f"gcp_dw_mssql_username = {gcp_dw_mssql_username}")
            gcp_dw_mssql_password = data["gcp_dw_mssql_password"]
            logging_func(f"gcp_dw_mssql_password = #############")

            logging_func(f"gcp_ingestion_log_loc = {gcp_ingestion_log_loc}")
            spark_property_file = data["spark_property_file"]
            logging_func(f"spark_property_file = {spark_property_file}")
            email_sendmail = data["email_sendmail"]
            logging_func(f"email_sendmail = {email_sendmail}")
            email_server = data["email_server"]
            logging_func(f"email_server = {email_server}")
            email_from = data["email_from"]
            logging_func(f"email_from = {email_from}")
            email_to = list(data["email_to"].split(","))
            logging_func(f"email_to = {email_to}")

            # To check if the parent_binding_id is in process or not
            logging_func("")
            logging_func("Capture the details connecting to the group_binding_id")
            query = f"call sp_gcp_get_scheduler_details('{parent_group_binding_id}')"
            logging_func(query)
            result_list1 = mysql_select_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username
                                             , gcp_etl_mysql_password, gcp_etl_mysql_dbname)

            if result_list1:
                for result1 in result_list1:
                    spark_ingestion_trigger_script = result1[1]
                    parent_binding_exec_flag = result1[2]
                    parent_binding_src_id_list = result1[3]
                    parent_binding_connctd_binding_id_trigger_script = result1[4]
                    parent_binding_connctd_binding_id_list = result1[5]

                    if parent_binding_exec_flag == "NotInProcess":
                        logging_func("")
                        logging_func("As the exec flag is defined as NotInProcess, so the process continues")
                        logging_func("")
                        logging_func("Updating the exec flag to InProcess, to avoid the duplicate job posting")
                        query = "update gcp_scheduler set exec_flag = 'InProcess' where group_binding_id = " \
                                + parent_group_binding_id
                        logging_func(query)
                        logging_func("")
                        output = mysql_update_insert_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username
                                                          , gcp_etl_mysql_password, gcp_etl_mysql_dbname)

                        logging_func("")

                        logging_func("Extracting the details of the connected sourceids")
                        logging_func("-------")
                        query = f"select drv.sourceid, drv.mapping_id, drv.load_type, drv.load_subtype, drv.jdbc_url" \
                                f", drv.min_value, drv.max_value, drv.targetdir, drv.project_name" \
                                f", drv.predicate_column, ref.sa_db, ref.tablebase " \
                                f"from vw_gcp_ingestion_details drv inner join gcp_ingestion_sources ref " \
                                f"on (drv.sourceid = ref.sourceid)" \
                                f" where drv.parent_binding_id = {parent_group_binding_id}"
                        logging_func(query)

                        result_list2 = mysql_select_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username
                                                         , gcp_etl_mysql_password, gcp_etl_mysql_dbname)

                        if len(result_list2) > 0:
                            for result2 in result_list2:
                                logging_func("")
                                logging_func(f"Process begins for the sourceid: {result2[0]}")
                                logging_func("-----------------------")

                                #Creating a empty list
                                file_id_list = []

                                #Creating a rowcount variable
                                rw_cnt = 0

                                logging_func("Now extracting the file_id details from the MSSQL DW logging table")
                                query = f"SELECT REPLACE(REVERSE(SUBSTRING(REVERSE(DestFileName)" \
                                        f", 1, CHARINDEX('_', REVERSE(DestFileName), 1) - 1)),'.txt','') as file_id" \
                                        f", RecordCount FROM Logging.PP_OutputFileLog (nolock)" \
                                        f" where FTPExportDate between '{result2[5]}' and '{result2[6]}'" \
                                        f" and OutputFileId='{result2[4].split('@')[3]}' and ProcessFile = 'Y'"
                                logging_func(query)

                                result_list3 = mssql_select_exec(query, gcp_dw_mssql_hostname
                                                                 , gcp_dw_mssql_username, gcp_dw_mssql_password
                                                                 , gcp_dw_mssql_dbname)

                                if len(result_list3) > 0:
                                    for result3 in result_list3:
                                        file_id_list.append(result3[0])
                                        rw_cnt += int(result3[1])

                                logging_func("")
                                logging_func("Now going back three days to the min_value, just to see if "
                                             "file_id's which failed were processed successfully")
                                logging_func("If any failures exist, then it will be appended to the "
                                             "file_id_list variable")

                                query = f"select distinct jobid from gcp_ingestion_lastrun " \
                                        f"where id in " \
                                        f"(" \
                                        f"select max_id from " \
                                        f"(" \
                                        f"SELECT jobid, max(id) as max_id FROM gcp_ingestion_lastrun " \
                                        f"where mapping_id = {result2[1]} and upperboundvalue >= " \
                                        f"DATE_ADD('{result2[5]}', INTERVAL - 5 DAY) group by jobid) subdrv" \
                                        f") and jobstatus != 'Success' and jobid != 'dummy_insert' " \
                                        f"UNION select whereclause as jobid from gcp_ingestion_controller " \
                                        f"where sourceid = {result2[0]}"
                                logging_func(query)

                                result_list4 = mysql_select_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username
                                                                 , gcp_etl_mysql_password, gcp_etl_mysql_dbname)
                                if len(result_list4) > 0:
                                    for result4 in result_list4:
                                        if result4[0] != "NA":
                                            for iter1 in result4[0].split(","):
                                                #Appending the file_id to the list
                                                file_id_list.append(iter1)

                                                #For the same file_id, extracting the rowcount
                                                logging_func("For the same file_id, extracting the rowcount")
                                                query = f"select RecordCount from Logging.PP_OutputFileLog (nolock)" \
                                                        f"where DestFileName = '{result2[4].split('@')[2]}_{iter1}.txt'"
                                                logging_func(query)

                                                result_list5 = mssql_select_exec(query, gcp_dw_mssql_hostname
                                                                                 , gcp_dw_mssql_username
                                                                                 , gcp_dw_mssql_password
                                                                                 , gcp_dw_mssql_dbname)
                                                rw_cnt += int(result_list5[0][0])
                                logging_func("")
                                logging_func("The final file_id list is: " + ",".join(file_id_list))
                                logging_func("")
                                logging_func("The total record count connecting to this batch_id pull: " + str(rw_cnt))

                                # Now creating the trigger script under the location where the log file is created
                                logging_func("")
                                logging_func("Appending the below to a trigger script which will be triggered")
                                logging_func("---------------------------------------------------------------")
                                operations_on_file(f"{gcp_ingestion_log_loc}/{result2[0]}_trigger_script.sh", "w", "NA"
                                                   , "NA")
                                file_id_list_rev = ",".join(file_id_list)
                                command = f"sh -x {spark_ingestion_trigger_script} \"{result2[0]}\" " \
                                          f"\"{file_id_list_rev}\" \"{spark_property_file}\""
                                operations_on_file(f"{gcp_ingestion_log_loc}/{result2[0]}_trigger_script.sh"
                                                   , "a", command, "Y")
                                logging_func(command)
                                logging_func("Executing the Ingestion Job first prior the compute DAGs trigger")

                                session1 = subprocess.Popen(["sh", f"{gcp_ingestion_log_loc}"
                                                                   f"/{result2[0]}_trigger_script.sh"]
                                                            , stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
                                stdout, stderr = session1.communicate()
                                if stderr:
                                    logging_func("The ingestion was unsuccessful")
                                    if email_trigger:
                                        send_mail(email_to,
                                                  f"SFTP Ingestion was unsuccessful for the sourceid: {result2[0]}"
                                                  , "The ingestion was unsuccessful", email_server, email_from)


                                logging_func("")
                                logging_func("Post spark ingestion, just verifying the record count to the count"
                                             " that is logged in MSSQL DW logging table")
                                query = f"select coalesce(sum(totalrecordcount),0) from gcp_ingestion_lastrun where mapping_id " \
                                        f"= '{result2[1]}' and upperboundvalue = '{result2[5]}'"
                                logging_func(query)

                                result_list6 = mysql_select_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username
                                                                 , gcp_etl_mysql_password, gcp_etl_mysql_dbname)

                                if int(rw_cnt) != int(result_list6[0][0]):
                                    if email_trigger:
                                        send_mail(email_to,
                                                  f"SFTP Ingestion was unsuccessful for the sourceid: {result2[0]}"
                                                  , "The ingestion was unsuccessful, because the row counts are failing"
                                                    " for some file_id", email_server, email_from)
                                else:
                                    logging_func("The row counts between MySQL and DW logging table match")

                                logging_func("")
                                logging_func("This completes the ingestion process fully.")

                                if parent_binding_connctd_binding_id_list != "NA":
                                    logging_func("")
                                    logging_func("Now triggering the compute code from staging to final target")
                                    logging_func("---------------")
                                    logging_func("Copying the file_id's to process in the compute side")
                                    logging_func("To achieve this, we will be copying the file_id information to the "
                                                 "GCS bucket in CSV format")
                                    logging_func("And we have an external table on top of it, to be used in SQL query")

                                    logging_func("")
                                    logging_func("Creating a empty csv file with the standard name: file_id_info.csv")
                                    operations_on_file(f"{gcp_ingestion_log_loc}/file_id_info.csv", "w", "NA", "NA")

                                    logging_func("")
                                    logging_func("Now executing the query against gcp_airflow_lastrun and "
                                                 "gcp_ingestion_lastrun")
                                    query = f"select distinct jobid from gcp_ingestion_lastrun " \
                                            f"where lastboundvalue > " \
                                            f"(select coalesce(max(exec_end_ts),'1900-01-01 01:00:10.0') as max_exec_ts" \
                                            f" from gcp_ingestion_sources drv " \
                                            f"join gcp_configobjs_ingestion_mapping ref1" \
                                            f" on (drv.sourceid = ref1.sourceid) " \
                                            f"join gcp_airflow_configobjs_mapping ref2 " \
                                            f"on (ref1.object_id = ref2.object_id) " \
                                            f"left join gcp_airflow_lastrun ref3 " \
                                            f"on (ref2.airflow_mapping_id = ref3.airflow_mapping_id) " \
                                            f"where drv.sourceid = {result2[0]}) " \
                                            f"and mapping_id = {result2[1]} and jobid != 'dummy_insert'"

                                    logging_func(query)
                                    result_list7 = mysql_select_exec(query, gcp_etl_mysql_hostname
                                                                     , gcp_etl_mysql_username, gcp_etl_mysql_password
                                                                     , gcp_etl_mysql_dbname)

                                    if len(result_list7) > 0:
                                        for result7 in result_list7:
                                            file_id_dt = result7[0][0:4] + '-' + result7[0][4:6] + '-' + result7[0][6:8]
                                            file_id = result7[0]
                                            text_to_append = file_id_dt + ',' + file_id
                                            logging_func(f"Appending the text: {text_to_append} to "
                                                         f"{gcp_ingestion_log_loc}/file_id_info.csv")
                                            operations_on_file(f"{gcp_ingestion_log_loc}/file_id_info.csv", "a",
                                                               text_to_append, "Y")

                                        logging_func("")
                                        logging_func("Now uploading the file_id_info.csv to GCS bucket")
                                        upload_bucket_name = result2[7].split("//")[1].split("/")[0]
                                        upload_destination_blob = result2[7].split(upload_bucket_name+"/")[1][:-6] \
                                                                  + "temp_staging/file_id_info.csv"
                                        gcp_json_path = data[result2[8]]

                                        if upload_blob(upload_bucket_name, f"{gcp_ingestion_log_loc}/file_id_info.csv",
                                                       upload_destination_blob, gcp_json_path):
                                            logging_func(f"The file_id list connecting to sourceid: {result2[0]} "
                                                         f"has been uploaded to GCS bucket successfully")

                                            logging_func("")
                                            logging_func("Just checking whether the connecting target object "
                                                         "is splittable or not")
                                            query = f"select ref2.gcp_schema_final,ref1.object_name" \
                                                    f",ref2.obj_gcs_stg_to_final_split_flag,ref3.json_file_loc" \
                                                    f" from gcp_configobjs_ingestion_mapping drv" \
                                                    f" join gcp_config_objects ref1" \
                                                    f" on (drv.object_id = ref1.object_id)" \
                                                    f" join gcp_airflow_configobjs_mapping ref2" \
                                                    f" on (ref1.object_id = ref2.object_id)" \
                                                    f" join gcp_airflow_scheduler ref3" \
                                                    f" on (ref2.airflow_binding_id = ref3.airflow_binding_id)" \
                                                    f" where drv.sourceid = {result2[0]}"
                                            logging_func(query)
                                            result_list8 = mysql_select_exec(query, gcp_etl_mysql_hostname
                                                                             , gcp_etl_mysql_username
                                                                             , gcp_etl_mysql_password
                                                                             , gcp_etl_mysql_dbname)
                                            if str(result_list8[0][2]) == "1":
                                                logging_func("As the split flag is ON, so the event_date capturing "
                                                             "takes place")
                                                logging_func("For the above file_id's list, capturing the"
                                                             " event_date's associated")
                                                client = bigquery.Client.from_service_account_json\
                                                    (json_credentials_path=gcp_json_path)

                                                file_event_dt_list = []
                                                file_id_list = []
                                                for result9 in result_list7:
                                                    file_event_dt_list.append(f"{result9[0][0:4]}"
                                                                              f"-{result9[0][4:6]}"
                                                                              f"-{result9[0][6:8]}")
                                                    file_id_list.append(result9[0])
                                                file_event_dt_conc = "'" + "','".join(file_event_dt_list) + "'"
                                                file_id_conc = ",".join(file_id_list)

                                                logging_func(f"select distinct DATE({result2[9]}) from "
                                                             f"`{result2[10]}.vw_{result2[11]}` where file_event_dt "
                                                             f"IN ({file_event_dt_conc}) "
                                                             f"and file_id IN ({file_id_conc})")

                                                event_dt_list = client.query(f"select distinct DATE({result2[9]})"
                                                                             f" from "
                                                                             f"`{result2[10]}.vw_{result2[11]}` "
                                                                             f"where file_event_dt "
                                                                             f"IN ({file_event_dt_conc}) and "
                                                                             f"file_id IN ({file_id_conc})")

                                                logging_func("")

                                                if len(list(event_dt_list)) > 0:
                                                    logging_func("Now creating a file in the compute "
                                                                 "json file location which will capture the event_date"
                                                                 " information")

                                                    operations_on_file(f"{result_list8[0][3]}/event_date.csv",
                                                                       "w", "NA", "NA")

                                                    dataset = client.dataset(f"{result_list8[0][0]}")
                                                    table_ref = dataset.table(f"{result_list8[0][1]}")
                                                    logging_func("")

                                                    for event_dt in event_dt_list:
                                                        if if_tbl_exists(client, f"{table_ref}_{str(event_dt[0])[0:4]}"):
                                                            txt_to_append = str(event_dt[0]) + ",exist"
                                                        else:
                                                            txt_to_append = str(event_dt[0]) + ",notexist"
                                                        logging_func(f"Appending the text: {txt_to_append} to "
                                                                     f"{result_list8[0][3]}/event_date.csv")
                                                        operations_on_file(f"{result_list8[0][3]}/event_date.csv", "a",
                                                                           txt_to_append, "Y")
                                            #Now triggering the final object dag trigger to which it is scheduled for
                                            logging_func("")
                                            logging_func("Now triggering the dependent binding_id's")
                                            logging_func("---------")
                                            for iter2 in parent_binding_connctd_binding_id_list.split("@"):
                                                logging_func("")
                                                logging_func("Cleaning up the trigger script")
                                                operations_on_file(f"{gcp_ingestion_log_loc}/trigger_script.sh"
                                                                   , "w", "NA", "NA")
                                                logging_func(f"Triggering the dags connecting to the config_ids: "
                                                             f"{str(iter2)}")
                                                base_counter = len(str(iter2).split(","))
                                                running_counter = 0
                                                time_sleep_counter = 5
                                                for iter3 in str(iter2).split(","):
                                                    running_counter += 1
                                                    # Creating a bash file for the airflow dag execution
                                                    operations_on_file(
                                                        f"{gcp_ingestion_log_loc}/dag_exec_{str(iter3)}.sh"
                                                        , "w", "NA", "NA")
                                                    python_command = f"/usr/local/bin/python3 " \
                                                                     f"{parent_binding_connctd_binding_id_trigger_script} " \
                                                                     f"\"{str(iter3)}\" \"{python_exec_property_loc}\""
                                                    operations_on_file(f"{gcp_ingestion_log_loc}/dag_exec_{str(iter3)}"
                                                                       f".sh", "a", f"sleep {time_sleep_counter}", "Y")
                                                    operations_on_file(f"{gcp_ingestion_log_loc}/dag_exec_{str(iter3)}"
                                                                       f".sh", "a", python_command, "N")
                                                    if running_counter == base_counter:
                                                        command = f"sh -x {gcp_ingestion_log_loc}" \
                                                                  f"/dag_exec_{str(iter3)}.sh"
                                                    else:
                                                        command = f"sh -x {gcp_ingestion_log_loc}" \
                                                                  f"/dag_exec_{str(iter3)}.sh &"
                                                    operations_on_file(f"{gcp_ingestion_log_loc}/trigger_script.sh"
                                                                       , "a", command, "Y")
                                                    logging_func(command)
                                                    time_sleep_counter += 5

                                                session2 = subprocess.Popen(["sh", f"{gcp_ingestion_log_loc}"
                                                                                   f"/trigger_script.sh"]
                                                                            , stderr=subprocess.STDOUT
                                                                            , stdout=subprocess.PIPE)
                                                stdout, stderr = session2.communicate()
                                                if stderr:
                                                    logging_func(f"The compute was unsuccessful for config ids: "
                                                                 f"{str(iter3)}")
                                                    if email_trigger:
                                                        send_mail(email_to, f"Compute was unsuccessful @ "
                                                                            f"parent_binding_id="
                                                                            f"{parent_group_binding_id}",
                                                                  f"The compute was unsuccessful for config ids: "
                                                                  f"{str(iter3)}", email_server, email_from)
                                        else:
                                            logging_func("")
                                            logging_func(f"The file_id list connecting to the sourceid: {result2[0]}"
                                                         f" failed to upload to GCS bucket, "
                                                         f"hence the compute from staging to final is not triggered")
                                            if email_trigger:
                                                send_mail(email_to, f"The file_id list upload failed to GCS for "
                                                                    f"sourceid: {result2[0]}"
                                                          , f"The file_id list connecting to the sourceid: {result2[0]}"
                                                            f" failed to upload to GCS bucket, hence the compute from "
                                                            f"staging to final is not triggered"
                                                          , email_server, email_from)
                        logging_func("")
                        logging_func("Updating the tableloadinprocessflag to NotInProcess for the "
                                     "parent_binding_id in case failed to update")
                        query = f"update gcp_ingestion_controller set tableloadinprocessflag='NotInProcess' " \
                                f"where find_in_set(sourceid,'{parent_binding_src_id_list}')"
                        logging_func(query)
                        logging_func("")
                        output = mysql_update_insert_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username
                                                          , gcp_etl_mysql_password, gcp_etl_mysql_dbname)

                        logging_func("")
                        #Now changing the status of the scheduler to NotInProcess for the group_binding_id
                        query = "update gcp_scheduler set exec_flag = 'NotInProcess' where group_binding_id = " \
                                + parent_group_binding_id
                        logging_func(query)
                        logging_func("")
                        output = mysql_update_insert_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username
                                                          , gcp_etl_mysql_password, gcp_etl_mysql_dbname)
                    else:
                        logging_func("Previous Job in process. Hence the process is terminated.")
                        
                        
                        
