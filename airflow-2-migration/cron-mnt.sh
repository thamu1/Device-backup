p_bd_ms_etl_svc@jldcdjob08:~$ crontab -l
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
#
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command

# Daily Jobs
# ##########
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Device Details Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily once starting 2PM EST Hours, Refresh check for every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>
0,15,30,45 17,18,19,20,21,22 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "6" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >>/tmp/gcp_ing_comp_bindingid_6.out 2>&1

#Airflow2 -Compute
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow2>-[JOBPURPOSE]-<placed_online_orderitem_complete> [CONSUMERS]-<Analytics> [FREQUENCY]-<Daily @ checks enabled starting 9AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/26/2023> [ENTRY UPDT]--<07/17/2024>
0,15,30,45 9,10,11,12,13,14,15,16,17 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "115" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_115.out 2>&1


#[PROCESS]- <Compute> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@agg_ecomm_order_revenue> [CONSUMERS]-<BigData/Reporting> [FREQUENCY]-<Daily, checks enabled from 7AM till 12AM EST hours> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<22/08/2024> [ENTRY UPDT]--<22/08/2024>
0,15,30,45 7,8,9,10,11 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "80" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_80.out 2>&1


#[PROCESS]- <Compute> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@pch entry events for Entries Dashboard> [CONSUMERS]-<BigData/Reporting> [FREQUENCY]-<Daily, checks enabled from 6:45 AM till 3:45 PM EST hours> [ENTRYBY]-<Krishna> [ENTRY CRDT]--<2028-08-29> [ENTRY UPDT]--<2028-08-29>
45 6,7,8,9,10,11,12,13,14,15 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "130" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_130.out 2>&1




# ##########


# Minute Level Jobs
# #################
#admin
* * * * * date >>/tmp/date_cron_log.txt 2>&1

# #################

# Hourly Jobs
# ###########
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Main Online Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting from 5AM till 10PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>
0 3,4,8,9,10,14,15,16,17,18,19,20,21 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "1" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_1.out 2>&1

#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP Acq_Uber Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 1 hour> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2024-06-11> [ENTRY UPDT]--<2024-06-11>
30,35,40,45 3,4,8,10,16,18 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "68" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_68.out 2>&1

#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP Hubs Framework> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting 7:30AM till 5PM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2024-06-14> [ENTRY UPDT]--<2024-06-14>
#0 7 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "62" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_62.out 2>&1
#0 30 8,9,10,11,13,14,15,16,17 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "62" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_62_1.out 2>&1


#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP Hubs Framework> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting 7:30AM till 5PM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2024-06-14> [ENTRY UPDT]--<2024-08-19>
30 7 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "127" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_127.out 2>&1
0,30 8,9,10,11,13,14,15,16,17 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "127" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_127_1.out 2>&1


#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP Ecomm888 KPI Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily once starting 9AM EST Hours, Refresh check for every 15 mins> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-10-07> [ENTRY UPDT]--<2024-10-07>
0,15,30,45 9,10,11,12,13,14,15,16,17,18,19,20 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "32" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_32.out 2>&1

#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@VIP> [CONSUMERS]-<BigData> [FREQUENCY]-<Daily at 8:30AM EST hours> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-10-07> [ENTRY UPDT]--<2024-10-07>
30 8 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "118" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_118.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Online Entries> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every hourly> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-07-27> [ENTRY UPDT]--<2024-07-18>
20 0,1,4,5,7,10,11,13,14,15,16,17,18,19,20,21 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "5" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_5.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP IWE And Token Bank Objects> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 12AM till 10PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-31> [ENTRY UPDT]--<2024-07-19>
5,20,35,50 4,5,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "13" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_13.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Online_Offline_Account_ID_Xref> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every hourly @ six times a day> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-12> [ENTRY UPDT]--<2024-09-12>
30 0,3,5,11,21 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "64" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_64.out 2>&1

#[PROCESS]- <ETLUtils> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Coin Transaction> [CONSUMERS]-<BigData> [FREQUENCY]-<Every 1 hour> [ENTRYBY]-<Zahid> [ENTRY CRDT]--<02/17/2023> [ENTRY UPDT]--<07/19/2024>
10 0,2,3,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "83" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_83.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Session Manager Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-04-05> [ENTRY UPDT]--<2024-07-22>
10 * * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "52" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_52.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<SegmentMembershipHistory> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily @ checks enabled starting 5AM till 11AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/20/2022> [ENTRY UPDT]--<07/23/2024>
0 5,6,7,8,9,10,11 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "14" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_14.out 2>&1

#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP Search Activity Agg> [CONSUMERS]-<PCHMedia> [FREQUENCY]-<Daily at 10AM, however check ebld for hourly to refresh if missed till 5PM> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-08-19> [ENTRY UPDT]--<2024-08-19>
0 10,11,12,13,14,15,16,17 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "63" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_63.out 2>&1
5,15,30,45 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "76" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_76.out 2>&1

#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<Acq_New_Mailables_Rpt_Req> [CONSUMERS]-<Analytics> [FREQUENCY]-<Daily @ checks enabled starting 8AM> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<21/08/2024> [ENTRY UPDT]--<21/08/2024>
0,15,30,45 8,9,10,11,12,13,14,15,16,17 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "95" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_95.out 2>&1

#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GA4_Ecomm_Aggregates> [CONSUMERS]-<Analytics> [FREQUENCY]-<Hourly @ checks enabled through out the day> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-10-07> [ENTRY UPDT]--<2024-10-07>
10 * * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "97" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_97.out 2>&1

#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP Hubs Framework> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting 7:30AM till 10.30AM> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-08-21> [ENTRY UPDT]--<2024-08-21>
30 7,8,9,10 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "62" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_62.out 2>&1


#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<Guest GMT Subject Area> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting from 3AM till 9PM as the last refresh trigger> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-16> [ENTRY UPDT]--<2024-09-16>
0 3,4,5,8,9,10,11,14,18,20,21 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "113" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_113.out 2>&1


#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@CDAAdhocREq> [CONSUMERS]-<CDA> [FREQUENCY]-<Every 15 mins> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-17> [ENTRY UPDT]--<2024-09-17>
1 * * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "3" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_3.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Paws Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily once starting 4:30AM EST Hours, Refresh check for every 15 mins> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-24> [ENTRY UPDT]--<2024-09-24>
30,45 4,5,6 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "8" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_8.out 2>&1

#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@sa_gmt_profile_attributes> [CONSUMERS]-<CDA> [FREQUENCY]-<Every 1 hour> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-17> [ENTRY UPDT]--<2024-09-17>
5 3,4,5,9,10,11,12,13,14,15,16,17,18,19,20,21 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "74" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_74.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Repository OnlineScores Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily once starting 3AM EST Hours, Refresh check for every 30 mins> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-18> [ENTRY UPDT]--<2024-09-18>
0,30 9,10,11,12,13,14,15,16,17,18,19,20 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "12" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_12.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Hubs Driver> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every hourly full day> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-25> [ENTRY UPDT]--<2024-09-25>
10 * * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "53" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_53.out 2>&1


#Ingestion entries

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<gcp_geo_location_stats> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 12AM till 10PM as the last refresh trigger> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-08-26> [ENTRY UPDT]--<2024-08-26>

0 8,13 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "128" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_128.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<reftokens> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 12AM till 10PM as the last refresh trigger> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-08-26> [ENTRY UPDT]--<2024-08-26>

0 2,8-17/1 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_spark_ingestion_trigger_script.py "129" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_129.out 2>&1

#MariGold-Email

#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@Marigold> [CONSUMERS]-<BigData, CDA> [FREQUENCY]-<Every 15 mins> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-04> [ENTRY UPDT]--<2024-09-04>
5,20,35,50 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_sftp_to_gcs_ingestion_trigger_script.py "121" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_121.out 2>&1

0,15,30,45 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_sftp_to_gcs_ingestion_trigger_script.py "122" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_123.out 2>&1

3,12,25,40 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_sftp_to_gcs_ingestion_trigger_script.py "123" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_122.out 2>&1

# ##########

# pch-classic

# ##############

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP PCH EmailActivity Outbound Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 3AM till 10PM as the last refresh trigger> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-9-13> [ENTRY UPDT]--<2024-9-13>
5,20,35,50 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_sftp_to_gcs_ingestion_trigger_script.py "40" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_40.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP PCH EmailActivity Inbound Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 3AM till 10PM as the last refresh trigger> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-9-13> [ENTRY UPDT]--<2024-9-13>
0,15,30,45 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_sftp_to_gcs_ingestion_trigger_script.py "42" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_42.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP PCH EmailActivity CampaignMetadata Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting from 5AM till 10PM as the last refresh trigger> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-9-13> [ENTRY UPDT]--<2024-9-13>
0 5,6,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_sftp_to_gcs_ingestion_trigger_script.py "48" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_48.out 2>&1


#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@EmailCampaignResults_PCHClassic> [CONSUMERS]-<BigData> [FREQUENCY]-<Every 30 mins> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-18> [ENTRY UPDT]--<2024-09-18>
25,45 1,2,3,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * python3 /mnt/data/codebase/bigdata/prod/ingestion/online/config/generic_sftp_to_gcs_ingestion_trigger_script.py "89" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_89.out 2>&1


#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python/Airflow>-[JOBPURPOSE]-<GCP Email_Activity_Complete> [CONSUMERS]-<BigData> [FREQUENCY]-<Every 1 hour> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-25> [ENTRY UPDT]--<2024-09-25>
15,45 7,10,13,16,19 * * * python3 /mnt/data/codebase/bigdata/prod/compute/online/airflow_2_0/config/python/generic_trigger.py "78" "/mnt/data/codebase/bigdata/prod/config/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_78.out 2>&1


# ################
#### CleanUp--Misc#################
#[PROCESS]- <ETLUtils> [JOBTYPE]-<CleanTempFile>-[JOBPURPOSE]-<Cleanup SparkWork Directories> [CONSUMERS]-<BigData> [FREQUENCY]-<Every 24 hour> [ENTRYBY]-<Ravi> [ENTRY CRDT]--<2024-09-25> [ENTRY UPDT]--<2024-09-25>
0 0 * * * bash /mnt/data/codebase/bigdata/prod/ingestion/online/scripts/gcp_spark_ingestion/testing/cleanip_sparkwork_dir_files.sh >/tmp/cleanup_sparkwork_dir_files.out 2>&1

