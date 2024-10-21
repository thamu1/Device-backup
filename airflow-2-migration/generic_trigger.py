"""
Code Author: Prashant Basa
Code Developed Date: 2021-08-10
Code Modified Date : 2023-11-14

This util will be triggering the DAGS in sequence connected to the group binding id.

Arguments to pass:
Argument1: group_binding_id
Argument2: the gcp_etl_generic_properties.json file
"""

# Main Module Imports
####################
import sys
import time

# Arguments to be passed to execute the util dynamically
#######################################################
group_binding_id = ""
gcp_etl_properties_json = ""
if len(sys.argv) == 3:
    group_binding_id = sys.argv[1]
    gcp_etl_properties_json = sys.argv[2]
    insufficient_arguments = False
else:
    insufficient_arguments = True
    print("""Insufficient arguments passed for executing the python util.
    Two arguments to be passed:
    1. Group_Binding_ID
    2. The GCP ETL Generic Properties JSON file""")

if not insufficient_arguments:

    # Running Module Imports
    #######################
    import json
    import mysql.connector
    from datetime import datetime
    import subprocess
    import os


    # Custom Functions
    #################
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


    # Main Logic
    ############

    # Reading the values from the json properties file
    with open(gcp_etl_properties_json) as datafile:
        data = json.loads(datafile.read())

    # 1. To check if the group_binding_id is in process or not

    query = f"select exec_flag from gcp_scheduler where group_binding_id = {group_binding_id}"
    result_list = mysql_select_exec(query, data["gcp_etl_mysql_hostname"], data["gcp_etl_mysql_username"]
                                    , data["gcp_etl_mysql_password"], data["gcp_etl_mysql_dbname"])

    if result_list:
        for result in result_list:
            if result[0] == "NotInProcess":

                # Updating the status to InProcess for the associated group_binding_id
                query = f"update gcp_scheduler set exec_flag = 'InProcess'" \
                        f", modified_ts = current_timestamp where group_binding_id = {group_binding_id}"
                output = mysql_update_insert_exec(query, data["gcp_etl_mysql_hostname"], data["gcp_etl_mysql_username"]
                                                  , data["gcp_etl_mysql_password"], data["gcp_etl_mysql_dbname"])

                # Updating the status of airflow_binding_id's associated with the group_binding_id to NotInProcess
                # forcibly in case it missed updating in the previous step
                query = f"update gcp_airflow_scheduler set exec_flag = 'NotInProcess'" \
                        f", modified_ts = current_timestamp " \
                        f"where group_binding_id = {group_binding_id}"
                output = mysql_update_insert_exec(query, data["gcp_etl_mysql_hostname"], data["gcp_etl_mysql_username"]
                                                  , data["gcp_etl_mysql_password"], data["gcp_etl_mysql_dbname"])

                # Gather the details connecting to the group_binding_id
                query = f"select airflow_binding_id, dag_name, parent_bash_script, trigger_bash_script" \
                        f", json_file_loc, exec_flag, GROUP_CONCAT(object_id),exec_order from " \
                        f"(select ref.airflow_binding_id, ref.dag_name,ref.parent_bash_script" \
                        f", ref.trigger_bash_script, ref.params, ref.json_file_loc, ref.exec_flag" \
                        f", ref1.object_id,ref.exec_order from gcp_scheduler drv inner join gcp_airflow_scheduler ref " \
                        f"on (drv.group_binding_id = ref.group_binding_id) " \
                        f"inner join gcp_airflow_configobjs_mapping ref1 " \
                        f"on (ref.airflow_binding_id = ref1.airflow_binding_id and ref1.skip_flag = 0) " \
                        f"inner join gcp_config_objects ref2 " \
                        f"on (ref1.object_id = ref2.object_id) " \
                        f"where ref.status_flag = 1 and drv.group_binding_id = {group_binding_id}" \
                        f" and ref2.status_flag = 1 " \
                        f"order by ref.exec_order,ref1.exec_order) final group by airflow_binding_id, " \
                        f"dag_name, parent_bash_script, trigger_bash_script, json_file_loc, exec_flag,exec_order " \
                        f"order by exec_order"
                result_list1 = mysql_select_exec(query, data["gcp_etl_mysql_hostname"], data["gcp_etl_mysql_username"]
                                                 , data["gcp_etl_mysql_password"], data["gcp_etl_mysql_dbname"])

                if result_list1:
                    for result1 in result_list1:
                        # Creating the JSON directory if not exists
                        if not os.path.exists(f"{result1[4]}"):
                            os.makedirs(f"{result1[4]}")

                        # Update the status to InProcess for the airflow_binding_id
                        query = f"update gcp_airflow_scheduler set exec_flag = 'InProcess'" \
                                f", modified_ts = current_timestamp " \
                                f"where airflow_binding_id = {result1[0]}"
                        output = mysql_update_insert_exec(query, data["gcp_etl_mysql_hostname"]
                                                          , data["gcp_etl_mysql_username"]
                                                          , data["gcp_etl_mysql_password"]
                                                          , data["gcp_etl_mysql_dbname"])

                        # Forcefully updating the status to NoByPass for all objects associated to the airflow_binding_id
                        query = f"update gcp_airflow_configobjs_mapping " \
                                f"set airflow_control_flag = 'NoByPass' " \
                                f"where airflow_binding_id = {result1[0]}"
                        output = mysql_update_insert_exec(query, data["gcp_etl_mysql_hostname"]
                                                          , data["gcp_etl_mysql_username"]
                                                          , data["gcp_etl_mysql_password"]
                                                          , data["gcp_etl_mysql_dbname"])

                        # Executing the Stored Procedure `sp_gcp_set_objs_bypass_inchck_with_ing`
                        query = f"call sp_gcp_set_objs_bypass_inchck_with_ing('{result1[6]}')"
                        output = mysql_update_insert_exec(query, data["gcp_etl_mysql_hostname"],
                                                          data["gcp_etl_mysql_username"],
                                                          data["gcp_etl_mysql_password"],
                                                          data["gcp_etl_mysql_dbname"])

                        # Executing the Stored Procedure `sp_gcp_set_objs_bypass_inchck_with_comp`
                        query = f"call sp_gcp_set_objs_bypass_inchck_with_comp_depdncy('{result1[6]}')"
                        output = mysql_update_insert_exec(query, data["gcp_etl_mysql_hostname"],
                                                          data["gcp_etl_mysql_username"],
                                                          data["gcp_etl_mysql_password"],
                                                          data["gcp_etl_mysql_dbname"])

                        # Executing the Stored Procedure `sp_gcp_set_objs_bypass_inchck_with_comp`
                        query = f"call sp_gcp_set_objs_bypass_inchck_with_comp_freq('{result1[6]}')"
                        output = mysql_update_insert_exec(query, data["gcp_etl_mysql_hostname"],
                                                          data["gcp_etl_mysql_username"],
                                                          data["gcp_etl_mysql_password"],
                                                          data["gcp_etl_mysql_dbname"])

                        # Metadata capture process into a JSON file for the airflow_binding_id related objects
                        ######################################################################################
                        # Creating a JSON file if not existing or cleaning the file if exists
                        operations_on_file(f"{result1[4]}/json_{result1[0]}.json", "w", "NA", "NA")

                        # Creating the root tags
                        json_data = {'airflow_binding_id': [], 'object_list_sorted': str(result1[6]).split(",")}

                        query = f"select * from vw_gcp_compute_basic_details where find_in_set(object_id,'{result1[6]}')"
                        result_list2 = mysql_select_exec(query, data["gcp_etl_mysql_hostname"]
                                                         , data["gcp_etl_mysql_username"]
                                                         , data["gcp_etl_mysql_password"]
                                                         , data["gcp_etl_mysql_dbname"])

                        main_dict_var = {}
                        for result2 in result_list2:
                            # time.sleep(5)
                            sub_dict_var = {}
                            sub_dict_var['object_id'] = result2[0]
                            sub_dict_var['object_name'] = result2[1]
                            sub_dict_var['airflow_mapping_id'] = result2[2]
                            sub_dict_var['exec_order'] = result2[3]
                            sub_dict_var['project_name'] = result2[4]
                            sub_dict_var['gcp_conn_var'] = result2[5]
                            sub_dict_var['gcp_svc_json_path_var'] = result2[6]
                            sub_dict_var['gcp_conn_bigdata_etl_metadata'] = result2[7]
                            sub_dict_var['gcp_schema_initial'] = result2[8]
                            sub_dict_var['gcp_schema_intermediate'] = result2[9]
                            sub_dict_var['gcp_schema_final'] = result2[10]
                            sub_dict_var['obj_gcs_path'] = result2[11]

                            gcp_partitioned_cols = {}
                            val = result2[12].split("@")
                            if val[0] != 'NA':
                                gcp_partitioned_cols['field'] = val[0]
                                gcp_partitioned_cols['type'] = val[1]
                                sub_dict_var['gcp_partition_cols'] = gcp_partitioned_cols
                            else:
                                sub_dict_var['gcp_partition_cols'] = None

                            val = result2[13].split("@")
                            if val[0] != 'NA':
                                sub_dict_var['gcp_cluster_cols'] = val
                            else:
                                sub_dict_var['gcp_cluster_cols'] = None

                            sub_dict_var['load_type'] = result2[14]
                            sub_dict_var['airflow_control_flag'] = result2[15]
                            sub_dict_var['vw_sql_except_columns'] = result2[16]
                            sub_dict_var['vw_sql_loc'] = result2[17]
                            sub_dict_var['obj_gcs_final_alter_name'] = result2[18]
                            sub_dict_var['obj_gcs_stg_to_final_split_flag'] = result2[19]
                            sub_dict_var['recon_start_limit'] = result2[20]
                            sub_dict_var['recon_end_limit'] = result2[21]
                            sub_dict_var['frequency'] = result2[22]
                            sub_dict_var['subjectarea_name'] = result2[23]
                            sub_dict_var['gcp_schema_sas_final'] = result2[24]

                            main_dict_var[f'{result2[0]}'] = sub_dict_var

                        json_data['airflow_binding_id'].append(main_dict_var)

                        with open(f"{result1[4]}/json_{result1[0]}.json", "a") as json_file:
                            json.dump(json_data, json_file)

                        filepath = f"{result1[4]}/json_{result1[0]}.json"
                        hostname_for_remote_conn = "p_bd_ms_etl_svc@JMAPREDGE4.classic.pchad.com"
                        remote_path = f"{result1[4]}/"

                        subprocess.call(['scp', filepath, ':'.join([hostname_for_remote_conn, remote_path])])
                        time.sleep(5)

                        # Creating the Running Script for the airflow_binding_id
                        operations_on_file(f"{result1[3]}", "w", "NA", "NA")
                        backfill_ts = str(datetime.now()).replace(" ", "T")
                        txt_to_append = f"sh -x {result1[2]} {result1[1]} {backfill_ts}"
                        operations_on_file(f"{result1[3]}", "a", txt_to_append, 'Y')
                        session = subprocess.Popen(["sh", f"{result1[3]}"], stderr=subprocess.STDOUT,
                                                   stdout=subprocess.PIPE)
                        stdout, stderr = session.communicate()

                        # Update the status to NotInProcess for the airflow_binding_id
                        query = f"update gcp_airflow_scheduler set exec_flag = 'NotInProcess'" \
                                f", modified_ts = current_timestamp " \
                                f"where airflow_binding_id = {result1[0]}"
                        output = mysql_update_insert_exec(query, data["gcp_etl_mysql_hostname"]
                                                          , data["gcp_etl_mysql_username"]
                                                          , data["gcp_etl_mysql_password"]
                                                          , data["gcp_etl_mysql_dbname"])

            # Updating the status to NotInProcess for the associated group_binding_id
            query = f"update gcp_scheduler set exec_flag = 'NotInProcess'" \
                    f", modified_ts = current_timestamp where group_binding_id = {group_binding_id}"
            output = mysql_update_insert_exec(query, data["gcp_etl_mysql_hostname"]
                                              , data["gcp_etl_mysql_username"]
                                              , data["gcp_etl_mysql_password"]
                                              , data["gcp_etl_mysql_dbname"])
