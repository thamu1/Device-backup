"""
1. get details of the compute

call mapr_bigdata_uat_metahub.sp_gcp_get_scheduler_details('13') -- '{parent_group_binding_id}'


2. get details from vw_gcp_ingestion_details

select project_name, case when fail_targetdir_drop = 'NA' then fail_targetdir_drop 
else substr(fail_targetdir_drop,instr(substr(fail_targetdir_drop,6), "/") + 6) 
end fail_targetdir_drop, case when fail_targetdir_drop = 'NA' 
then fail_targetdir_drop else substr(fail_targetdir_drop,6,
instr(substr(fail_targetdir_drop,6), "/") - 1) end bucket_name 
from vw_gcp_ingestion_details where parent_binding_id = 128 -- {parent_group_binding_id}


"""





"""

#######################################
# Code Author         : Prashant Basa #
# Code developed date : 2021-08-23   #
# Code modified date  : 2023-12-01    #
#######################################

This is the main trigger script for the GCP Ingestion Framework for all data-sources.

Arguments to be passed:
Argument1: parent_group_binding_id
Argument2: python_exec_property_loc

If the parent_group_binding_id is connected to other trigger components, even that will be also triggered.

file located in spark-cluster: 
/mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "13" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json"

"""





import mysql.connector
import datetime
import os
import subprocess
import sys
import json
import smtplib
from email.message import EmailMessage
from google.cloud import storage

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


def delete_blob(bucket_name, blob_name, gcp_json_path):
    storage_client = storage.Client.from_service_account_json(json_credentials_path=gcp_json_path)
    bucket = storage_client.get_bucket(bucket_name)
    blobs = bucket.list_blobs(prefix=blob_name)
    for blob in blobs:
        try:
            if str(blob.name).__contains__('ing_batch_id=-1') or str(blob.name) == blob_name:
                pass
            else:
                blob.delete()
        except NotFound:
            pass
        except:
            terminate = True


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
        curr_sec = curr_dttime[11:]

        # Inital declaration of the variable                                
        gcp_ingestion_log_loc = f"""{data["ingestion_log_loc"]}parent_binding_id_{str(parent_group_binding_id)}/{curr_dt}/{curr_dt}_{curr_sec}"""

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
            logging_func(f"gcp_ingestion_log_loc = {gcp_ingestion_log_loc}")
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
            result_list1 = mysql_select_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username,
                                             gcp_etl_mysql_password, gcp_etl_mysql_dbname)

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
                        query = "update gcp_scheduler set exec_flag = 'InProcess'" \
                                ", modified_ts = current_timestamp where group_binding_id = " \
                                + parent_group_binding_id
                        logging_func(query)
                        logging_func("")
                        output = mysql_update_insert_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username,
                                                          gcp_etl_mysql_password, gcp_etl_mysql_dbname)

                        logging_func("")
                        logging_func("Now dropping the directories in the GCS bucket if defined "
                                     "for the group_binding_id and even checking if there is any records to process"
                                     "or not")
                        logging_func("Getting the above details by executing the view vw_gcp_ingestion_details")
                        query = "select project_name, case when fail_targetdir_drop = 'NA' then fail_targetdir_drop " \
                                "else substr(fail_targetdir_drop,instr(substr(fail_targetdir_drop,6), \"/\") + 6) " \
                                "end fail_targetdir_drop, case when fail_targetdir_drop = 'NA' " \
                                "then fail_targetdir_drop else substr(fail_targetdir_drop,6," \
                                "instr(substr(fail_targetdir_drop,6), \"/\") - 1) end bucket_name " \
                                "from vw_gcp_ingestion_details where parent_binding_id = " + parent_group_binding_id
                        
                        logging_func(query)

                        result_list2 = mysql_select_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username,
                                                         gcp_etl_mysql_password, gcp_etl_mysql_dbname)

                        if len(result_list2) > 0:
                            for result2 in result_list2:
                                if result2[1] != "NA":
                                    logging_func(
                                        f"Dropping the directory: {result2[1]} under bucket: {result2[2]} "
                                        f"defined in the project: {result2[0]}")
                                    gcp_json_path = data[result2[0]]
                                    bucket_name = result2[2]
                                    delete_blob(bucket_name, result2[1], gcp_json_path)

                            if terminate != True:
                                # Now creating the trigger script under the location where the log file is created
                                logging_func("")
                                logging_func("Appending the below to a trigger script which will be triggered")
                                logging_func("---------------------------------------------------------------")
                                operations_on_file(f"{gcp_ingestion_log_loc}/trigger_script.sh", "w", "NA", "NA")
                                command = f"sh -x {spark_ingestion_trigger_script}"
                                operations_on_file(f"{gcp_ingestion_log_loc}/trigger_script.sh", "a", command, "Y")
                                logging_func(command)
                                logging_func("Executing the Ingestion Job first prior the compute DAGs trigger")

                                # Executing the Ingestion Job first prior the compute DAGs trigger
                                session1 = subprocess.Popen(["sh", f"{gcp_ingestion_log_loc}/trigger_script.sh"],
                                                            stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
                                stdout, stderr = session1.communicate()
                                if stderr:
                                    logging_func("The ingestion was unsuccessful")
                                    if email_trigger:
                                        send_mail(email_to, f"Ingestion was unsuccessful @ parent_binding_id="
                                                            f"{parent_group_binding_id}",
                                                  "The ingestion was unsuccessful",
                                                  email_server, email_from)

                                # Cleaning up the trigger script
                                logging_func("As the ingestion is done, triggering the compute DAGs")
                        else:
                            logging_func("There is no data to process. Hence the ingestion process is terminated.")

                        # Compute Code Trigger
                        if parent_binding_connctd_binding_id_list != "NA":
                            for iter1 in parent_binding_connctd_binding_id_list.split("@"):
                                logging_func("")
                                logging_func("Cleaning up the trigger script")
                                operations_on_file(f"{gcp_ingestion_log_loc}/trigger_script.sh", "w", "NA"
                                                   , "NA")

                                logging_func(f"Triggering the dags connecting to the config_ids: {str(iter1)}")
                                base_counter = len(str(iter1).split(","))
                                running_counter = 0
                                time_sleep_counter = 5
                                for iter2 in str(iter1).split(","):
                                    running_counter += 1
                                    # Creating a bash file for the airflow dag execution
                                    operations_on_file(f"{gcp_ingestion_log_loc}/dag_exec_{str(iter2)}.sh"
                                                       , "w", "NA", "NA")
                                    python_command = f"python3 " \
                                                     f"{parent_binding_connctd_binding_id_trigger_script} " \
                                                     f"\"{str(iter2)}\" \"{python_exec_property_loc}\""
                                    operations_on_file(f"{gcp_ingestion_log_loc}/dag_exec_{str(iter2)}.sh", "a",
                                                       f"sleep {time_sleep_counter}", "Y")
                                    operations_on_file(f"{gcp_ingestion_log_loc}/dag_exec_{str(iter2)}.sh", "a",
                                                       python_command, "N")
                                    if running_counter == base_counter:
                                        command = f"sh -x {gcp_ingestion_log_loc}/dag_exec_{str(iter2)}.sh"
                                    else:
                                        command = f"sh -x {gcp_ingestion_log_loc}/dag_exec_{str(iter2)}.sh &"
                                    operations_on_file(f"{gcp_ingestion_log_loc}/trigger_script.sh", "a",
                                                       command, "Y")
                                    logging_func(command)
                                    time_sleep_counter += 5

                                session2 = subprocess.Popen(["sh", f"{gcp_ingestion_log_loc}"
                                                                   f"/trigger_script.sh"],
                                                            stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
                                stdout, stderr = session2.communicate()
                                if stderr:
                                    logging_func(f"The compute was unsuccessful for config ids: {str(iter2)}")
                                    if email_trigger:
                                        send_mail(email_to, f"Compute was unsuccessful @ parent_binding_id="
                                                            f"{parent_group_binding_id}",
                                                  f"The compute was unsuccessful for config ids: "
                                                  f"{str(iter2)}",
                                                  email_server, email_from)

                        logging_func("")
                        logging_func("Updating the tableloadinprocessflag to NotInProcess for the parent_binding_id"
                                     " in case failed to update")
                        query = f"update gcp_ingestion_controller set tableloadinprocessflag='NotInProcess' " \
                                f"where find_in_set(sourceid,'{parent_binding_src_id_list}')"
                        logging_func(query)
                        logging_func("")
                        output = mysql_update_insert_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username,
                                                          gcp_etl_mysql_password, gcp_etl_mysql_dbname)

                        logging_func("")
                        logging_func("Updating the exec_flag to NotInProcess for the group_binding_id of compute DAGs"
                                     " in case failed to update")
                        parent_binding_connctd_binding_id_list_rev = str(parent_binding_connctd_binding_id_list) \
                            .replace("@", ",")
                        query = f"update gcp_scheduler set exec_flag='NotInProcess'" \
                                f", modified_ts = current_timestamp " \
                                f"where find_in_set(group_binding_id,'{parent_binding_connctd_binding_id_list_rev}')"
                        logging_func(query)
                        logging_func("")
                        output = mysql_update_insert_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username,
                                                          gcp_etl_mysql_password, gcp_etl_mysql_dbname)

                        logging_func("")
                        logging_func("Updating the exec flag to NotInProcess")
                        query = "update gcp_scheduler set exec_flag = 'NotInProcess'" \
                                ", modified_ts = current_timestamp where group_binding_id = " \
                                + parent_group_binding_id
                        logging_func(query)
                        logging_func("")
                        output = mysql_update_insert_exec(query, gcp_etl_mysql_hostname, gcp_etl_mysql_username,
                                                          gcp_etl_mysql_password, gcp_etl_mysql_dbname)

                        logging_func("")
                        logging_func("Process completed fully.")
                    else:
                        logging_func("Previous Job in process. Hence the process is terminated.")
