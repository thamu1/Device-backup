### Please use the Job Classification and input into specific section and provide the comments about the job###
### NODE--pmapredge02.pchoso.com
### SVN LOC-https://svn.dev.pch.com/svn/BigData/trunk/etl/conf/crontab
### FILENAME :- edge2-crontab.txt
##################################START-Minute Level Job Schdules #####################################################

#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Incremental Load for Batch2 tables from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 1,15,30,45 minute> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#1 0,1,2 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/incremental_load_processinitiation.sh batch2 >/tmp/ProdUberMiniBatch2Incremental.out 2>&1

#1,15,30,45 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/incremental_load_processinitiation.sh batch2 >/tmp/ProdUberMiniBatch2Incremental1.out 2>&1
#[PROCESS]- <IncAppend> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<IncrAppndLoadFrmSrcToSA> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 10th min of 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23> [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<11/07/2019> [ENTRY UPDT]--<11/07/2019>
#0,10,20,30,40,50 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/incremental_load_processinitiation_append.sh batch6 >/tmp/incrementalload_append_batch6.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Importing the FrontPage Video Data from MySQL to SA> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 15th min of the hour starting from morning 8AM EST Hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/01/2020> [ENTRY UPDT]--<05/01/2020>
#0,15,30,45 8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/frontpage_ingestion/config/video_log_trigger_script.sh >/tmp/frontpagevideoetl.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Importing the FrontPage Story Data from MySQL to SA> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 15th min of the hour starting from morning 8AM EST Hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/01/2020> [ENTRY UPDT]--<05/01/2020>
#0,15,30,45 8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/frontpage_ingestion/config/story_log_trigger_script.sh >/tmp/frontpagestoryetl.out 2>&1

#[PROCESS]- <ETL> [JOBTYPE]-<Monitoring>-[JOBPURPOSE]-<YARN Rrunning apps in HDL> [CONSUMERS]-<HDL> [FREQUENCY]-<every 5 mins> [ENTRYBY]-<RJ> [ENTRY CRDT]--<7/3/2019> [ENTRY UPDT]--<7/3/2019>
#*/5 * * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/modelling/bigdata/dev/getlistpfappsrunning.sh >/tmp/getlistpfappsrunning.out 2>&1

#[PROCESS]- <ETLMetadataUpdate> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<ScoresMetadataUpdate> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 9:05,9:15,9:30> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/01/2019> [ENTRY UPDT]--<12/01/2019>
#5,15,30 9 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/auxiliary_workflow/scripts/bash/online_score/ptp/im_obj_partition_rebld_edge2_edge1.sh >/tmp/scoringmetadataupdate.out 2>&1

#GCP Ingestion and Compute
##########################
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@CDAAdhocREq> [CONSUMERS]-<CDA> [FREQUENCY]-<Every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/17/2021> [ENTRY UPDT]--<12/17/2021>
#1 * * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "3" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_3.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP PCH EmailActivity Inbound Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 3AM till 10PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>

#0,15,30,45 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "42" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_42.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP PCH EmailActivity Outbound Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 3AM till 10PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>

#5,20,35,50 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "40" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_40.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP WOM EmailActivity Inbound Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 3AM till 10PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>

#10,25,40,55 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "38" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_38.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP WOM EmailActivity Outbound Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 3AM till 10PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>

#12,27,42,57 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "36" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_36.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP IWE And Token Bank Objects> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 12AM till 10PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-31> [ENTRY UPDT]--<2022-01-31>

#5,20,35,50 4,5,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "13" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_13.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP EDP Outbound Objects> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 12AM till 11PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-06-29> [ENTRY UPDT]--<2022-06-29>

#5 5,9,12,15,18,21,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "57" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_57.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP EDP Inbound Objects> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 12AM till 11PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-06-29> [ENTRY UPDT]--<2022-06-29>

#10 5,9,12,15,18,21,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "58" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_58.out 2>&1

#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@EDPCampaignMetadata> [CONSUMERS]-<BigData, CDA> [FREQUENCY]-<Every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2022> [ENTRY UPDT]--<10/27/2022>
#16 5,9,12,15,18,21,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "70" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_70.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@EmailCampaignResults_PCHClassic> [CONSUMERS]-<BigData> [FREQUENCY]-<Every 30 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<04/04/2023> [ENTRY UPDT]--<04/04/2023>
#25,45 1,2,3,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "89" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_89.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP subscribersubscriptionsummary build> [CONSUMERS]-<Bigdata@OMNI> [FREQUENCY]-<Four times in a hour> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-12-01> [ENTRY UPDT]--<2022-12-01>
#5,15,30,45 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "76" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_76.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Nextgen EDP Outbound Objects> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 12AM till 11PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2023-11-06> [ENTRY UPDT]--<2023-11-06>
#5 0,1,2,3,4,6,8,11,14,17,20,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script_rev.py "106" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_106.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Nextgen EDP Inbound Objects> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every 15mins starting from 12AM till 11PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2023-11-06> [ENTRY UPDT]--<2023-11-06>
#10 0,1,2,3,4,6,8,11,14,17,20,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script_rev.py "107" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_107.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@NextgenEDPCampaignMetadata> [CONSUMERS]-<BigData, CDA> [FREQUENCY]-<Every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2023-11-06> [ENTRY UPDT]--<2023-11-06>
#16 0,1,2,3,4,6,7,8,10,11,13,14,16,17,19,20,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script_rev.py "108" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_108.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@Marigold> [CONSUMERS]-<BigData, CDA> [FREQUENCY]-<Every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2024-06-11> [ENTRY UPDT]--<2024-06-11>

#5,20,35,50 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "121" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_121.out 2>&1

#0,15,30,45 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "123" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_123.out 2>&1

#3,12,25,40 3,4,5,6,9,11,12,14,15,17,18,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "122" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_122.out 2>&1


#GCP Health Check Recon
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<ETL_Health_Check@GCP> [CONSUMERS]-<BigData> [FREQUENCY]-<Every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2024-04-01> [ENTRY UPDT]--<2024-04-01>
#0,15,30,45 * * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/etl_health_chck.py "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_health_recon_sp.out 2>&1

##################################END-Minute Level Schdules ###########################################################

##################################START-Hourly Job Schdules ###########################################################
#[PROCESS]- <ET> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<AWS Sync to HDL> [CONSUMERS]-<HDL> [FREQUENCY]-<Every hour @15 minute> [ENTRYBY]-<Viral> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#15 0,3,6,9,12,15,18,22 * * * /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/et_continueevents_ingestion/config/parent_level/continue_aws_sync_parent.sh > /dev/null 2>&1

#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Full Load for Batch2 tables from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 2 hours  @2 minute> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#2 0 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/full_load_processinitiation.sh batch2 >/tmp/ProdTrackingTokensBatch2Full.out 2>&1
#30 9,11,13,15,17,19 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/full_load_processinitiation.sh batch2 >/tmp/ProdTrackingTokensBatch2Full1.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Incremental Load for Batch1 tables from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 2 hours  @2 minute> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#2 0,4,6,8,10,12,14,16,18,20,22 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/incremental_load_processinitiation.sh batch1 >/tmp/ProdRegActivityBatch1Incremental.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Importing the Outbound Files from FTP to SA> [CONSUMERS]-<HDL> [FREQUENCY]-<Hourly @ 3,6,9,12,15,18,21> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/08/2018> [ENTRY UPDT]--<02/08/2018>
#2 2,3,9,12,15,18,21 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/email_activity_ingestion/config/outbound/emailactivityoutbound.sh >/tmp/EmailActivityOutboundFTPPull.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Importing the Inbound Files from FTP to SA> [CONSUMERS]-<HDL> [FREQUENCY]-<Hourly @ 3,6,9,12,15,18,21> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/08/2018> [ENTRY UPDT]--<02/08/2018>
#10 2,3,9,12,15,18,21 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/email_activity_ingestion/config/inbound/emailactivityinbound.sh >/tmp/EmailActivityInboundFTPPull.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Importing the CampaignMetadata Files from FTP to SA and SA to IM processing> [CONSUMERS]-<HDL> [FREQUENCY]-<Hourly @ 9,12,15,18> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<04/18/2018> [ENTRY UPDT]--<04/18/2018>
#30 2,3,9,12,15,18 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/email_activity_ingestion/config/campaignmetadata/trigger_script.sh >/tmp/EmailActCampMetadataFTPPull.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Incremental append from MYSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 2 hours  @2 minute> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<7/21/2020> [ENTRY UPDT]--<10/27/2017>
#2 1,2,3 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/incremental_load_processinitiation_append_mysql.sh batch7 >/tmp/incremental_append_mssql_batch7.out 2>&1



#[PROCESS]- <INGESTION@SPARK> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Ingestion of Fusion/Spectrum logcopy data from S3 to HDL SA layer> [CONSUMERS]-<HDL> [FREQUENCY]-<Every two hours 10,12,16,18,20,22> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<11/30/2018> [ENTRY UPDT]--<11/30/2018>
#1 9,12,13,16,18,20,22 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/fusion_spectrum_ingestion/config/trigger_script.sh >/tmp/FusionSpectrumLogCopySpark.out 2>&1
#[PROCESS]- <INGESTION@SPARK> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Ingestion of Lotto data from S3 to HDL SA layer> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 30th min of 10,11,12,13,15,17,19,21> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<01/08/2020> [ENTRY UPDT]--<01/08/2020>
#30 10,11,12,13,15,17,19,21 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/lotto_gameplay_ingestion/config/trigger_script.sh >/tmp/LottoSADataPullSpark.out 2>&1
#[PROCESS]- <INGESTION@SPARK> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Ingestion of Search data from S3 to HDL SA layer> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 0 min of 11,12,13,15,17,19,21> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<03/16/2020> [ENTRY UPDT]--<03/16/2020>
#0 11,12,13,15,17,19,21 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/search_activity_ingestion/config/trigger_script.sh >/tmp/SearchSADataPullSpark.out 2>&1

#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<HDL Refresh for EmailActivityComplete @ IM_STDArchive volume> [CONSUMERS]-<SAS,TABLEAU> [FREQUENCY]-<Every 4 hours  @30 minute> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/26/2018> [ENTRY UPDT]--<10/26/2018>
#30 5,7,10,14,16,22 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/email_activity_workflow/config/complete/email_activity_complete.sh >/tmp/emailactivitycompletehourly.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<HDL Refresh for Ecomm_Score,Tracking_Token_Attributes,Continue_Events @ CM,IM volume> [CONSUMERS]-<SAS,TABLEAU> [FREQUENCY]-<Every 2 hours  @30 minute> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#0 7,10,12,14,16,18,20 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_workflow/config/hourly_onl_objs_and_acq_stats.sh >/tmp/OnlineScoresHourly.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<EcommCart> [CONSUMERS]-<HDL> [FREQUENCY]-<HourlyRefresh excluding 12-5am> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/23/2018> [ENTRY UPDT]--<10/01/2019>
#10 6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/ecommerce_workflow/config/cron_cartitem.sh >/tmp/EcommCartIMLoad.out 2>&1


#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<EmailActivity Checks> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 3 hours i.e. 9,12,15,18,21> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<04/01/2020> [ENTRY UPDT]--<04/01/2020>
#0 9,12,15,18,21 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/email_activity_workflow/config/emailactivitydataloadcheck/email_activity_utility_v1.sh >/tmp/etlutilsemailactivity.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<EmailActivity Checks for WOM> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 3 hours i.e. 9,12,15,18,21> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<09/06/2022> [ENTRY UPDT]--<09/06/2022>
#0 9,12,15,18,21 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/wom_workflow/config/wom_emailactivitydataloadcheck/wom_emailactivitydataloadcheck.sh >/tmp/wom_etlutilsemailactivity.out 2>&1


#[PROCESS]- <ETLSnapshot> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<HDLSnapshots> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 15th mins of 9,10,11,12,13,14> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<06/20/2019> [ENTRY UPDT]--<06/20/2019>
#0,15,30,45 9,10,11,12,13,14,15,16 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/daily_snapshot/main_etl_triggerscript.sh >/tmp/mainetlsnapshot.out 2>&1


#[PROCESS]- <EPS> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<AWS Sync to HDL> [CONSUMERS]-<PCHMEDIA> [FREQUENCY]-<Every 4 hours  @10 minute> [ENTRYBY]-<Tejas> [ENTRY CRDT]--<04/22/2019> [ENTRY UPDT]--<04/22/2019>

#[PROCESS]- <EPS> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<AWS Sync to HDL> [CONSUMERS]-<PCHMEDIA> [FREQUENCY]-<Every 4 hours  @05 minute> [ENTRYBY]-<Tejas> [ENTRY CRDT]--<04/22/2019> [ENTRY UPDT]--<04/22/2019>


#Tableau Online DataSource Refresh
##################################
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<Reporting@AcqStats> [CONSUMERS]-<HDL, Tableau> [FREQUENCY]-<Execution hourly> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<04/07/2021> [ENTRY UPDT]--<04/07/2021>
0,5,10,15,20,25,30,35,40,45,50,55 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/tableau_online_generic_scripts/generic_obj_refresh_hourly_trigger_datasource.py "1" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/reporting/etl_generic_prototype/acquisition_uber_stats_workflow/config/acq_stats_tableau_online_datasource_refresh.sh" >/tmp/tbl_ds_acq_stats.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<Reporting@UberStats> [CONSUMERS]-<HDL, Tableau> [FREQUENCY]-<Execution hourly> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<04/07/2021> [ENTRY UPDT]--<04/07/2021>
0,5,10,15,20,25,30,35,40,45,50,55 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/tableau_online_generic_scripts/generic_obj_refresh_hourly_trigger_datasource.py "2" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/reporting/etl_generic_prototype/acquisition_uber_stats_workflow/config/uber_stats_tableau_online_datasource_refresh.sh" >/tmp/tbl_ds_uber_stat.out 2>&1


#GCP Ingestion and Compute
##########################
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Main Online Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting from 5AM till 10PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>
#0 3,4,8,9,10,14,15,16,17,18,19,20,21 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "1" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_1.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP PCH EmailActivity CampaignMetadata Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting from 5AM till 10PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>
#0 5,6,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "48" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_48.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP WOM EmailActivity CampaignMetadata Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting from 5AM till 10PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>
#5 5,6,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "47" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_47.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Session Manager Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-04-05> [ENTRY UPDT]--<2022-04-05>
#10 * * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "52" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_52.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Fusion_Spectrum Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting 3AM EST Hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-05-01> [ENTRY UPDT]--<2022-05-01>
#0,15,30,45 1,2,3,4,5,6,7,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "9" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_bindingid_9.out 2>&1
#0 3,4,5,6,7,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "34" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_34.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Hubs Driver> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every hourly full day> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-06-30> [ENTRY UPDT]--<2022-06-30>
#10 * * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "53" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_53.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP Hubs Framework> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting 7:30AM till 5PM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-07-07> [ENTRY UPDT]--<2022-07-07>
#30,45 7 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "62" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_62.out 2>&1
#0,15,30,45 8,9,10,11,13,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "62" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_62_1.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Online Entries> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every hourly> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-07-27> [ENTRY UPDT]--<2022-07-27>
#20 0,1,4,5,7,10,11,13,14,15,16,17,18,19,20,21 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "5" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_5.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Online_Offline_Account_ID_Xref> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Every hourly @ six times a day> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-07-27> [ENTRY UPDT]--<2022-07-27>
#30 0,3,5,11,21 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "64" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_64.out 2>&1

#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark, Compute-Airflow>-[JOBPURPOSE]-<Continue Events> [CONSUMERS]-<BigData> [FREQUENCY]-<hourly excluding the 0th, 23rd> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-10-16> [ENTRY UPDT]--<2022-10-16>
25 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "56" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_56.out 2>&1

#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@edp_usersendmoduledistributiondata> [CONSUMERS]-<BigData/Theresa> [FREQUENCY]-<Every 1 hour> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<11/20/2022> [ENTRY UPDT]--<11/20/2022>
#10 3,6,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "71" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_71.out 2>&1

#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@sa_gmt_profile_attributes> [CONSUMERS]-<CDA> [FREQUENCY]-<Every 1 hour> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<11/20/2022> [ENTRY UPDT]--<11/20/2022>
#5 3,4,5,9,10,11,12,13,14,15,16,17,18,19,20,21 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "74" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_74.out 2>&1

#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@acq_uber> [CONSUMERS]-<BigData/Reporting> [FREQUENCY]-<Every 1 hour> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<11/20/2022> [ENTRY UPDT]--<11/20/2022>
#30,35,40,45 3,4,8,10,16,18 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "68" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_68.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python/Airflow>-[JOBPURPOSE]-<GCP Email_Activity_Complete> [CONSUMERS]-<BigData> [FREQUENCY]-<Every 1 hour> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<01/18/2023> [ENTRY UPDT]--<01/18/2023>
#8 7,10,13,16,19 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "78" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_78.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Coin Transaction> [CONSUMERS]-<BigData> [FREQUENCY]-<Every 1 hour> [ENTRYBY]-<Zahid> [ENTRY CRDT]--<02/17/2023> [ENTRY UPDT]--<02/17/2023>
#10 0,2,3,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "83" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_83.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Ecomm Cart Item Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting from 3AM till 8PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2023-04-04> [ENTRY UPDT]--<2023-04-04>
#3 3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "7" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_7.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@edp_emailcampaign_conversion> [CONSUMERS]-<BigData> [FREQUENCY]-<Every hour> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/25/2023> [ENTRY UPDT]--<05/25/2023>
#10 1,2,3,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_sftp_spark_ingestion/generic_sftp_to_gcs_ingestion_trigger_script.py "93" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_93.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GA4_Ecomm_Aggregates> [CONSUMERS]-<Analytics> [FREQUENCY]-<Hourly @ checks enabled through out the day> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<09/25/2023> [ENTRY UPDT]--<09/25/2023>
#10 * * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "97" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_97.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<email_hubs_mvs_check> [CONSUMERS]-<BigData> [FREQUENCY]-<Hourly @ checks enabled starting 8AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/25/2023> [ENTRY UPDT]--<10/25/2023>
#0,15,30,45 8,9,10,11,12,13,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "102" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_102.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<TableauOnlineRefresh>-[JOBPURPOSE]-<email_hubs_1@hourly> [CONSUMERS]-<Reporting> [FREQUENCY]-<Two times in a day @ checks enabled starting 8:30AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/26/2023> [ENTRY UPDT]--<10/26/2023>
30,45 8,9,10,11,12,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_tableau_trigger.py "4" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/tableau_bindingid_4.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<TableauOnlineRefresh>-[JOBPURPOSE]-<email_hubs_2@hourly> [CONSUMERS]-<Reporting> [FREQUENCY]-<Two times in a day @ checks enabled starting 8:30AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/26/2023> [ENTRY UPDT]--<10/26/2023>
30,45 8,9,10,11,12,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_tableau_trigger.py "5" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/tableau_bindingid_5.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<TableauOnlineRefresh>-[JOBPURPOSE]-<email_hubs_3@hourly> [CONSUMERS]-<Reporting> [FREQUENCY]-<Two times in a day @ checks enabled starting 8:30AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/26/2023> [ENTRY UPDT]--<10/26/2023>
30,45 8,9,10,11,12,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_tableau_trigger.py "6" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/tableau_bindingid_6.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<Guest GMT Subject Area> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Hourly starting from 3AM till 9PM as the last refresh trigger> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2023-12-08> [ENTRY UPDT]--<2023-12-08>
#0 3,4,5,8,9,10,11,14,18,20,21 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "113" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_113.out 2>&1


#GCP_Tracking_Jobs
##################
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<gcp_etl_jobs_tracker> [CONSUMERS]-<BigData> [FREQUENCY]-<Every 1 hour> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<11/22/2022> [ENTRY UPDT]--<11/22/2022>
#1 6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_jobs_tracking/gcp_jobs_tracking.py "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_etl_jobs_tracker.out 2>&1
##################################END-Hourly Job Schdules #############################################################


##################################START-Daily Job Schdules ############################################################

#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Full Load for Batch1 tables from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 00:05> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#5 0 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/full_load_processinitiation.sh batch1 >/tmp/ProdRegActivityBatch1Full.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Full Load for Batch5 tables from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 00:20> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#20 0 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/full_load_processinitiation.sh batch5 >/tmp/ProdRegActivityBatch5Full.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Full Load for Batch6 tables from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 01:30> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#30 1 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/full_load_processinitiation.sh batch6 >/tmp/ProdFusionBatch6Full.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Full Load for Batch7 table from MSSQL to HDL(SA)> [CONSUMERS]-<HDL,TOM2> [FREQUENCY]-<Everyday @ 02:00> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#0 2 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/full_load_processinitiation.sh batch7 >/tmp/TOM2Batch7Full.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Full Load for Batch3 table from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 12:00> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#0 12 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/full_load_processinitiation.sh batch3 >/tmp/TECPRODSQLBatch3Full.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Incremental Load for Batch3 table vw_GMTInfo_sqoop from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Once a day> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<11/08/2017> [ENTRY UPDT]--<11/08/2017>
#15 0 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/incremental_load_processinitiation.sh batch3 >/tmp/ProdGMTInfoBatch3Incremental.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Full Load for Batch9 tables from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 03:20> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<07/20/2018> [ENTRY UPDT]--<07/20/2018>
#20 3 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/full_load_processinitiation.sh batch9 >/tmp/ProdPAWSBatch9Full.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Incremental Load for Batch4 table vw_pchbuy_repository_sqoop from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Once a day @ 6AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<07/02/2019> [ENTRY UPDT]--<07/02/2019>
#0 6 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/incremental_load_processinitiation.sh batch4 >/tmp/ProdRepoScoresBatch4Incremental.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Incremental Load for Batch5 table vw_repository_onlinescores_sqoop from MSSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Once a day @ 6AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<08/17/2019> [ENTRY UPDT]--<08/17/2019>
#30 5 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/incremental_load_processinitiation.sh batch5 >/tmp/ProdRepoScoresBatch5Incremental.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<ful lload from MYSQL view_token_transaction to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<once a day @ 1am EST> [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<07/28/2020> [ENTRY UPDT]--<07/28/2020>
#0 1 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/full_load_processinitiation_mysql.sh batch12 >/tmp/fullload_processinitiation_mysql_batch12.out 2>&1
#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<ful lload from MSSQL Segmentation metadata from Source to SA> [CONSUMERS]-<HDL> [FREQUENCY]-<once a day @ 1am EST> [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<07/28/2020> [ENTRY UPDT]--<07/28/2020>
#0 1 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/parent_script/full_load_processinitiation.sh batch11 >/tmp/fullload_processinitiation_mssql_batch11.out 2>&1

#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<PAWS EMAIL METADATA> [CONSUMERS]-<HDL> [FREQUENCY]-<Daily @ 4.15 am > [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<07/31/2018> [ENTRY UPDT]--<04/16/2021>
#15 4 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/email_activity_workflow/config/paws_metadata/paws_metadata_trigger_script.sh >/tmp/emailpawsmetadata.out 2>&1



#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<DMS Offline Refresh> [CONSUMERS]-<SAS> [FREQUENCY]-<Weekdays @ 4:00> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#0 4 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/offline/dms_workflow/config/main_offline_etl.sh >/tmp/ETLOfflineDailyRefresh.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<CUST_ID_CURRENT, CUST_ID_HISTORY Build @ HDL> [CONSUMERS]-<SAS> [FREQUENCY]-<Everyday @ 23:30> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#30 23 * * * /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/offline/dms_workflow/config/cust_id_current.sh >/tmp/CustIDCurrentDailyRefresh.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<PTOAndPTE> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 07:01> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<09/27/2018> [ENTRY UPDT]--<08/05/2019>
#1 7 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/auxiliary_workflow/config/cron_pto_and_pte.sh >/tmp/PTOAndPTEOld_ETLExec.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<PTP> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 05:01> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<08/05/2019> [ENTRY UPDT]--<08/05/2019>
#1 5 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/auxiliary_workflow/config/cron_ptp.sh >/tmp/PTPOld_ETLExec.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<OnlineTables Reconciliation in HDL @ CM, IM volume> [CONSUMERS]-<SAS,TABLEAU> [FREQUENCY]-<Everyday @ 1:15> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#0 1 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_workflow/config/one_time_exec_onl_objs.sh >/tmp/OnlineDataOneTimeExec.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<Device Details refresh in HDL> [CONSUMERS]-<SAS,TABLEAU> [FREQUENCY]-<Everyday @ 14:01> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<10/27/2017>
#1 13 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/auxiliary_workflow/config/cron_device_details.sh >/tmp/DeviceDetailsDaily.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<ONLINE_OFFLINE_ACCOUNT_ID_XREF in HDL @ CM, IM volume> [CONSUMERS]-<SAS,TABLEAU> [FREQUENCY]-<Everyday @ 5:30> [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<06/04/2018> [ENTRY UPDT]--<04/28/2021>
#30 5 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/crossref_workflow/config/onl_off_accnt_id_xref.sh >/tmp/OnlineOfflineAccountIDXref.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<GMTAttributesPhase3> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 06:30> [ENTRYBY] <Veeresh> [ENTRY CRDT]--<09/27/2018> [ENTRY UPDT]--<04/29/2021>
#30 6 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/auxiliary_workflow/config/cron_gmt_attributes.sh >/tmp/GMTAttributesPhase3.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<ordersBatch1> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 06:15> [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<10/12/2019> [ENTRY UPDT]--<10/12/2019>
#0 3 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/ecommerce_workflow/config/cron_orderitems_onlineoffers_batch1.sh >/tmp/OnlOrdAndOffrsETL_batch1.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<ordersBatch2> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 03:01> [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<10/12/2019> [ENTRY UPDT]--<10/12/2019>
#15 6 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/ecommerce_workflow/config/cron_orderitems_onlineoffers_batch2.sh >/tmp/OnlOrdAndOffrsETL_batch2.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<HDLAggOrdersScores> [CONSUMERS]-<HDL,Tableau> [FREQUENCY]-<Everyday @ 5:45> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/19/2019> [ENTRY UPDT]--<10/19/2019>
#45 5 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/reporting/hdl_aggregates_workflow/config/agg_placed_onlineorder_scores.sh >/tmp/HDLAggOrdersScores.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<Sku_Classification_Xref> [CONSUMERS]-<HDL,SAS> [FREQUENCY]-<Everyday @ 07:00> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/08/2019> [ENTRY UPDT]--<05/08/2019>
#0 7 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/offline/dms_workflow/config/sku_classification_xref.sh >/tmp/SkuClassificationXref.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<FusSpecAndAggObjects> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 11:00> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/19/2018> [ENTRY UPDT]--<05/06/2020>
#0 11 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/fusion_spectrum_workflow/config/agg_objects_fuspec_raw_objects.sh >/tmp/LogCopy_FusSpecAndAggObjs.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<AggRep2PMCutOff> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 08:00> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/19/2018> [ENTRY UPDT]--<12/19/2018>
#0 8 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/fusion_spectrum_workflow/config/aggviews_cutoff_etlrefresh.sh >/tmp/LogCopy_Agg2PM.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<IntermediateTDMNONOAndTDMORDRWorkflowForUberStats> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 22:30> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<09/14/2018> [ENTRY UPDT]--<09/14/2018>
#0 22 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/reporting/acquisition_uber_stats_workflow/config/tdmnono_tdmordr_extrct_hdrseq.sh >/tmp/TDMNONO_TDMORDR_CustIDRecon.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<TOTORITObjectBuild> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 5:15> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/12/2019> [ENTRY UPDT]--<05/12/2019>
#15 5 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/offline/dms_workflow/config/totorit.sh >/tmp/ETLTOTORIT.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<OnlineEntries-Contest_Metadata> [CONSUMERS]-<HDL> [FREQUENCY]-<Daily @ 5.00 am > [ENTRYBY]-<PK> [ENTRY CRDT]--<11/08/2019> [ENTRY UPDT]--<11/08/2019>
#0 5 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/online_entries_workflow/config/contest_metadata.sh >/tmp/etlcontestmetadata.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<LottoSAToIM> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 14:10> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<01/08/2020> [ENTRY UPDT]--<01/08/2020>
#10 14 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/lotto_gameplay_workflow/config/tigger_script.sh >/tmp/LottoSAToIMETL.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<SearchSAToIM> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 14:30> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<03/16/2020> [ENTRY UPDT]--<03/16/2020>
#30 14 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/search_activity_workflow/config/trigger_script.sh >/tmp/SearchSAToIMETL.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<SweepstakesAggObj> [CONSUMERS]-<DIServices> [FREQUENCY]-<Everyday @ 21:00> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<04/27/2020> [ENTRY UPDT]--<04/27/2020>
#0 21 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/online_entries_workflow/config/triggerscript_agg_sweepstake_user_entry.sh >/tmp/SweepStakesAggObj.out 2>&1
#[PROCESS]-<ETL>  [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<segmentationmetadata_SAtoIM> [CONSUMERS]-<HDL> [FREQUENCY]-<Once in a day @4pm EST> [ENTRYBY]-<Veeresh>  [ENTRY CRDT]--<7/27/2020> [ENTRY UPDT]--<7/27/2020>
#30 3 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/segmentation_workflow/config/segment_metadata/trigger_script.sh >/tmp/segmentationmetadata.out 2>&1
#[PROCESS]-<ETL>  [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<segmentationhistory_SAtoIM> [CONSUMERS]-<HDL> [FREQUENCY]-<Once in a day @3AM EST> [ENTRYBY]-<Veeresh>  [ENTRY CRDT]--<7/28/2020> [ENTRY UPDT]--<7/28/2020>
#0 3 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/segmentation_workflow/config/segmentation_history/trigger_script.sh >/tmp/segmentationhistory.out 2>&1
#[PROCESS]-<ETL>  [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<tnpmlis_stg_for_gcp_hybrid> [CONSUMERS]-<HDL> [FREQUENCY]-<Once in a day @7_30AM EST> [ENTRYBY]-<Veeresh>  [ENTRY CRDT]--<3/12/2023> [ENTRY UPDT]--<3/12/2023>
#30 7 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/offline/dms_workflow/config/tnpmlis.sh >/tmp/tnpmlis_stg.out 2>&1


#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<S3 to SA missing counts> [CONSUMERS]-<HDL> [FREQUENCY]-<Every day once at 21 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<04/01/2020> [ENTRY UPDT]--<04/01/2020>
#0 21 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/s3_missing_counts/s3_data_recon_utility.sh >/tmp/etlutilss3datarecon.out 2>&1


#[PROCESS]- <FTP@SPARK> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Posting Aggviews_Reporting data to MIMS Team in their FTP location> [CONSUMERS]-<MIMS> [FREQUENCY]-<Everyday @ 9:30> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<06/04/2018> [ENTRY UPDT]--<06/04/2018>
#30 10 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/bq_to_sftp_push/spectrum_mims_product_views/trigger_script.sh >/tmp/AggRepFTPExport.out 2>&1
#[PROCESS]- <FTP@SPARK> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Posting OrdersScoringAgg data to MIMS Team in their FTP location> [CONSUMERS]-<MIMS> [FREQUENCY]-<Everyday @ 10:25> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<03/03/2020> [ENTRY UPDT]--<03/03/2020>
#25 10 * * 1,2,3,4,5 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/bq_to_sftp_push/placed_onlineorders_with_scoresinfo/trigger_script.sh >/tmp/AggOrdsScrFTPExport.out 2>&1
#[PROCESS]- <S3@SPARK> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Posting Topix Data to Topix team in their S3 location> [CONSUMERS]-<Topix> [FREQUENCY]-<Everyday @ 9:00> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/18/2019> [ENTRY UPDT]--<10/18/2019>
#0 9 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/bin/spark_generic/trigger_script.sh >/tmp/TopixDataS3Push.out 2>&1


#[PROCESS]- <RTD@Offline> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<RTD CustID insert into TDMCONS> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 18:30> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<03/03/2020> [ENTRY UPDT]--<03/03/2020>
#30 18 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/offline/dms_workflow/config/rtd_triggerscript/child_objects_triggerscript/tdmcons_triggerscript.sh >/tmp/RtdTdmconsInsert.out 2>&1


#[PROCESS]- <SweepstakesUtil> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Sweepstakes Count Util connecting to SA UserEntries and UserEntriesSourceTracking and then triggering the CM Spark Util and then followed with IM Sweepstakes pipeline trigger> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 18:00 EST HOURS> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/07/2020> [ENTRY UPDT]--<02/07/2020>
#0 18 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/online_entries_workflow/config/cm_load_utility.sh >/tmp/SweepstakesUtilExec.out 2>&1

#[PROCESS]- <HiveExec> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<TOM2SubRegInfoObject> [CONSUMERS]-<TOM2> [FREQUENCY]-<Everyday @ 9:00> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<06/20/2019> [ENTRY UPDT]--<06/20/2019>
#0 9 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/tom2_subreginfo/tom2_subreginfo.sh >/tmp/tom2_subreginfo.out 2>&1

#[PROCESS]- <ETLSnapshot> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<CustomerorigindateSnapshot> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 8:05> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<06/20/2019> [ENTRY UPDT]--<06/20/2019>
#5 8 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/daily_snapshot/customerorigindate_triggerscript.sh >/tmp/customerorigindatesnapshot.out 2>&1

#[PROCESS]- <ETLSnapshot> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<SADMSCustomerSnapshot> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 8:10> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<06/20/2019> [ENTRY UPDT]--<06/20/2019>
#10 8 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/daily_snapshot/sa_dms_customer.sh >/tmp/sadmscustomersnapshot.out 2>&1

#[PROCESS]- <ETLSnapshot> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<DeviceDetailsSnapshot> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 14:00> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<06/20/2019> [ENTRY UPDT]--<06/20/2019>
#0 14 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/daily_snapshot/device_details.sh >/tmp/devicedetailssnapshot.out 2>&1

#[PROCESS]- <ETLSnapshot> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<ReportingVolume> [CONSUMERS]-<HDL> [FREQUENCY]-<Everyday @ 8:50> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/01/2019> [ENTRY UPDT]--<12/01/2019>
#50 8 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/daily_snapshot/reporting.sh >/tmp/reportingsnapshot.out 2>&1


#[PROCESS]- <EPS> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<GMT merging small files in HDL with compressio> [CONSUMERS]-<PCHMEDIA> [FREQUENCY]-<EveryDay @22:30> [ENTRYBY]-<Tejas> [ENTRY CRDT]--<04/24/2019> [ENTRY UPDT]--<04/24/2019>

#[PROCESS]- <EPS> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<MAID merging small files in HDL with compression> [CONSUMERS]-<PCHMEDIA> [FREQUENCY]-<EveryDay @22:40> [ENTRYBY]-<Tejas> [ENTRY CRDT]--<04/24/2019> [ENTRY UPDT]--<04/24/2019>

#[PROCESS]- <EPS> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<maid_cm_pivot_segments job> [CONSUMERS]-<SEG> [FREQUENCY]-<EveryDay @5:05> [ENTRYBY]-<Tejas> [ENTRY CRDT]--<04/24/2019> [ENTRY UPDT]--<04/24/2019>

#[PROCESS]- <Segmentation> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<UAT ENV Segmentation Daily Export_High_Value_Customers_Detail_TO_Segmentation job> [CONSUMERS]-<HDL,Segmentation> [FREQUENCY]-<EveryDay @15:00> [ENTRYBY]-<Tejas> [ENTRY CRDT]--<12/15/2020> [ENTRY UPDT]--<12/15/2020>
#00 15 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/segmentation_workflow/config/high_value_customers_se_import/export_high_value_customers_detail_to_segmentation.sh >/tmp/export_high_value_customers_detail_to_segmentation.out 2>&1


#[PROCESS]- <Merkle_Crossref> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<Merkle_Crossref job> [CONSUMERS]-<SEG,offline,analytics,pchmedia> [FREQUENCY]-<EveryDay @6:30> [ENTRYBY]-<Tejas> [ENTRY CRDT]--<05/04/2019> [ENTRY UPDT]--<05/04/2019>
#30 6 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/merkle_workflow/config/merkle_crossref/merkle_xref_automation_parent.sh>/tmp/merkle_xref_automation_parent.out 2>&1

#[PROCESS]- <Segmentation> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<UAT ENV Segmentation Daily Export_CreditCard_Order_Details_To_Segmentaion job> [CONSUMERS]-<HDL,Segmentation> [FREQUENCY]-<EveryDay @12:30> [ENTRYBY]-<Tejas> [ENTRY CRDT]--< 05/14/2019> [ENTRY UPDT]--< 05/14/2019>
#30 12 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/segmentation_workflow/config/creditcard_order_detail_se_import/Export_creditcard_order_detail_To_Segmentaion.sh >/tmp/Segment_CreditCard.out 2>&1
#[PROCESS]- <Segmentation> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Segmentation Job> [CONSUMERS]-<Segmentation,HDL> [Frequency]--EveryDay @[19:00] [AppName]—EXPORT_OFFLINE_ENTRY_THANKYOU_TO_SE [EntryBy]-ManishV [Entry CrDt]-- 05/14/2019 [Entry UpDt]-- 05/14/2019
#0 19 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/segmentation_workflow/config/offline_entry_thankyou_se_import/Export_OfflineEntryThnakyou_Details_To_Segmentaion.sh >/tmp/ExpOffEntryThnkDet.out 2>&1
#[PROCESS]- <Segmentation> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<UAT ENV Segmentation Daily Export_Product_Details_To_Segmentaion job> [CONSUMERS]-<HDL,Segmentation> [FREQUENCY]-<EveryDay @12:00> [ENTRYBY]-<Tejas> [ENTRY CRDT]--< 05/14/2019> [ENTRY UPDT]--< 05/14/2019>
#0 12 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/segmentation_workflow/config/product_affinity_se_import/Export_Product_Details_To_Segmentaion.sh > /dev/null 2>&1
#[PROCESS]- <Segmentation> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<UAT ENV Segmentation Daily Export_Product_Details_To_Segmentaion job> [CONSUMERS]-<HDL,Segmentation> [FREQUENCY]-<EveryDay @15:30> [ENTRYBY]-<Tejas> [ENTRY CRDT]--<05/15/2019> [ENTRY UPDT]--<05/15/2019>
#30 15 * * * /bin/sh  /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/segmentation_workflow/config/online_offline_orders_se_import/Export_Online_Offline_Orders_To_Segmentaion.sh >/tmp/Segment_OnlineOfflineOrders.out 2>&1
#[PROCESS]- <Segmentation> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<UAT ENV Segmentation Daily Export_Offline_Entry_Last_7_Days_To_Segmentaion job> [CONSUMERS]-<HDL,Segmentation> [FREQUENCY]-<EveryDay @11:00> [ENTRYBY]-<Tejas> [ENTRY CRDT]--<06/26/2019> [ENTRY UPDT]--<06/26/2019>
#0 11 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/segmentation_workflow/config/offline_entry_last_7_days_se_import/export_offlineEntry_last_7_days_to_segmentation.sh >/tmp/export_offlineEntry_last_7_days_to_segmentation.out 2>&1


#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<SA to Im data reconcilation for iwe and tokenbank> [CONSUMERS]-<HDL> [FREQUENCY]-<once a day @ 6am EST> [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<09/07/2020> [ENTRY UPDT]--<09/07/2020>
#30 6 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "5" "workflow" >/tmp/grpbinding_5_workflow.out 2>&1


#Airflow Jobs
#############
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@UserEntries> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#0 5 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/python/generic_trigger_partitioned_objects.py "4" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" >/tmp/airflow_user_entries_daily.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@EmailActivity> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#0 7,13 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/python/generic_trigger_partitioned_objects.py "3" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" >/tmp/airflow_email_activity_daily.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@DMSCustomer> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger for 4 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#0,15,30,45 9,10,11,12 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_dms_customer.sh >/tmp/airflow_dms_customer.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@DMSCustomer2> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger for 4 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#0,15,30,45 9,10,11,12 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_dms_customer_2.sh >/tmp/airflow_dms_customer2.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@DMSProspect> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger for 4 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#0,15,30,45 9,10,11,12 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_dms_prospect.sh >/tmp/airflow_dms_prospect.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@RegSub> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#0 9,10 * * 1,2,3,4,5,6 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_registration_subscription_daily.sh >/tmp/airflow_reg_sub_daily.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@Auxiliary> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger for 4 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#30 9,10,11,12 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_online_auxiliary.sh >/tmp/airflow_auxiliary.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@Auxiliary_2> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger for 4 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#30 9,10,11,12 * * 1,2,3,4,5,6 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_online_auxiliary_2_daily.sh >/tmp/airflow_auxiliary_2_daily.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@Instant_Win_2> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger for 2 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#45 9,10 * * 1,2,3,4,5,6 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_instant_win_2_daily.sh >/tmp/airflow_instant_win_2_daily.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@Instant_Win_Ref> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger for 2 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#45 9,10 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_instant_win_ref.sh >/tmp/airflow_instant_win_ref.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<AirflowBindingID@1> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger check for every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/16/2021> [ENTRY UPDT]--<05/16/2021>
#0,15,30,45 7,8,9,10,11,12,13 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/python/generic_trigger_non_partitioned_objects.py "1" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/general/core/prod/central_logging/logfile/central_logging.csv" >/tmp/airflow_binding_id_1.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<AirflowBindingID@5> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once @ 9AM, however trigger check for every 3 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/16/2021> [ENTRY UPDT]--<05/16/2021>
#0 9,12,15 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/python/generic_trigger_non_partitioned_objects.py "5" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/general/core/prod/central_logging/logfile/central_logging.csv" >/tmp/airflow_binding_id_5.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<AirflowBindingID@6> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger check for every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/16/2021> [ENTRY UPDT]--<05/16/2021>
#0,15,30,45 6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/python/generic_trigger_non_partitioned_objects.py "6" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/general/core/prod/central_logging/logfile/central_logging.csv" >/tmp/airflow_binding_id_6.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<AirflowBindingID@7> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger check for every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/16/2021> [ENTRY UPDT]--<05/16/2021>
#0,15,30,45 8,9,10,11,12,13 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/python/generic_trigger_non_partitioned_objects.py "7" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/general/core/prod/central_logging/logfile/central_logging.csv" >/tmp/airflow_binding_id_7.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<AirflowBindingID@9> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger check for every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/16/2021> [ENTRY UPDT]--<05/16/2021>
#0,15,30,45 8,9,10,11,12,13,14 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/python/generic_trigger_non_partitioned_objects.py "9" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/general/core/prod/central_logging/logfile/central_logging.csv" >/tmp/airflow_binding_id_9.out 2>&1


#Tableau Online DataSource Refresh
##################################
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<Reporting@WOMDailyKPIStats> [CONSUMERS]-<HDL, Tableau> [FREQUENCY]-<Execution only once> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<03/26/2021> [ENTRY UPDT]--<03/26/2021>
0,10,20,30,35 7 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/tableau_online_generic_scripts/generic_obj_refresh_daily_trigger_datasource.py "4" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/ga_wom_workflow/config/tableau_datasource_refresh.sh" >/tmp/tbl_ds_wom_daily_kpi_stats.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<Reporting@EcommOrderRevReport> [CONSUMERS]-<HDL, Tableau> [FREQUENCY]-<Execution only once> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<04/02/2021> [ENTRY UPDT]--<04/02/2021>
40 5 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/tableau_online_generic_scripts/generic_obj_refresh_daily_trigger_datasource.py "5" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/reporting/etl_generic_prototype/ecomm_order_revenuew_report/config/tableau_datasource_refresh.sh" >/tmp/ecomm_order_revenue_tableau_ds_refresh.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<Reporting@EcommFailureNotification> [CONSUMERS]-<HDL, Tableau> [FREQUENCY]-<Execution only once> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<05/18/2021> [ENTRY UPDT]--<05/18/2021>
30,35,40,45,50,55 8 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/tableau_online_generic_scripts/generic_ecomm_failure_notification.py "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/tableau_online_generic_scripts/ecomm_failure_notification/tableau_datasource_refresh.sh" >/tmp/ecomm_failure_notification_ds_refresh.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<Reporting@EcommGASessions> [CONSUMERS]-<HDL, Tableau> [FREQUENCY]-<Execution only once> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<09/29/2021> [ENTRY UPDT]--<09/29/2021>
10,20,30,40,50 8,9 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/tableau_online_generic_scripts/generic_obj_refresh_daily_trigger_ds_dir_check.py "7" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/resources/etl_generic_prototype/etl_generic_prototype.properties" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/im/diservices/prod/hot/analytics_gaaggregates/GAEcommDailyRollupOrderItemAgg/event_dt=@/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/im/diservices/prod/hot/analytics_gaaggregates/GAEcommDailyOrderItemAgg/event_dt=" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/reporting/etl_generic_prototype/ecomm_order_revenuew_report/config/tableau_datasource_refresh_revevue_ds.sh" >/tmp/tbl_ds_ecomm_ga_sessions.out 2>&1


#GCP Ingestion and Compute
##########################
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Device Details Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily once starting 2PM EST Hours, Refresh check for every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>
#0,15,30,45 17,18,19,20,21,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "6" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_6.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Paws Objects Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily once starting 4:30AM EST Hours, Refresh check for every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>
#30,45 4,5,6 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "8" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_8.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP Ecomm888 KPI Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily once starting 9AM EST Hours, Refresh check for every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-01-06> [ENTRY UPDT]--<2022-01-06>
#0,15,30,45 9,10,11,12,13,14,15,16,17,18,19,20 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "32" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_32.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP Repository OnlineScores Build> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily once starting 3AM EST Hours, Refresh check for every 30 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-05-01> [ENTRY UPDT]--<2022-05-01>
#0,30 9,10,11,12,13,14,15,16,17,18,19,20 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "12" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_12.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP Search Activity Agg> [CONSUMERS]-<PCHMedia> [FREQUENCY]-<Daily at 10AM, however check ebld for hourly to refresh if missed till 5PM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-07-26> [ENTRY UPDT]--<2022-07-26>
#0 10,11,12,13,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "63" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_63.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP CustID Current Hybrid Data Push> [CONSUMERS]-<BigData> [FREQUENCY]-<Daily and checks will be enabled hourly starting 3AM to be sure that daily once its executed> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-09-02> [ENTRY UPDT]--<2022-09-02>
#0 3,5,7,9,10,11,12 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "66" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_66.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<GCP WOM GA Sessions YOY Date Object> [CONSUMERS]-<PchMedia Tableau Reporting> [FREQUENCY]-<Daily and checks will be enabled hourly for additional three hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-10-16> [ENTRY UPDT]--<2022-10-16>
#15,30,45 0,1,2,3 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "69" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_69.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<GCP subscribersubscriptionsummary build> [CONSUMERS]-<Bigdata@OMNI> [FREQUENCY]-<Daily once starting 3AM EST Hours, Refresh check for every 15 mins> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2022-12-01> [ENTRY UPDT]--<2022-12-01>
#0,15,30,45 3,4,5,6,7,8,9,10 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "76" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_76.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@agg_ecomm_order_revenue> [CONSUMERS]-<BigData/Reporting> [FREQUENCY]-<Daily, checks enabled from 7AM till 12AM EST hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/20/2022> [ENTRY UPDT]--<12/20/2022>
#0,15,30,45 7,8,9,10,11 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "80" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_80.out 2>&1
#[PROCESS]- <Ingestion_And_Compute> [JOBTYPE]-<Ingestion-Spark,Compute-Airflow>-[JOBPURPOSE]-<SegmentMembershipHistory> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily @ checks enabled starting 5AM till 11AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/20/2022> [ENTRY UPDT]--<12/20/2022>
#0 5,6,7,8,9,10,11 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_spark_ingestion/generic_spark_ingestion_trigger_script.py "14" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_ing_comp_bindingid_14.out 2>&1
#[PROCESS]- <Offline Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<HDL_TO_GCP> [CONSUMERS]-<BigdataTeam> [FREQUENCY]-<Daily @ checks enabled starting 10AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<04/09/2023> [ENTRY UPDT]--<04/09/2023>
#0 10,11,12,13,14,15,16 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "90" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_90.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<Acq_New_Mailables_Rpt_Req> [CONSUMERS]-<Analytics> [FREQUENCY]-<Daily @ checks enabled starting 8AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<09/05/2023> [ENTRY UPDT]--<09/05/2023>
#0,15,30,45 8,9,10,11,12,13,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "95" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_95.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<aggviews_modeling> [CONSUMERS]-<Analytics> [FREQUENCY]-<Daily @ checks enabled starting 8AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<09/25/2023> [ENTRY UPDT]--<09/25/2023>
#0,15,30,45 8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "98" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_98.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<admargin_daily> [CONSUMERS]-<Analytics> [FREQUENCY]-<Daily @ checks enabled starting 8AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/25/2023> [ENTRY UPDT]--<10/25/2023>
#0,15,30,45 8,9,10,11,12,13,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "99" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_99.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<TableauOnlineRefresh>-[JOBPURPOSE]-<admargin_daily> [CONSUMERS]-<Reporting> [FREQUENCY]-<Daily @ checks enabled starting 9:30AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/25/2023> [ENTRY UPDT]--<10/25/2023>
30 9,10,11,12,13,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_tableau_trigger.py "2" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/tableau_bindingid_2.out 2>&1

#[PROCESS]- <Compute> [JOBTYPE]-<Ingestion>-[JOBPURPOSE]-<ga4_wom_daily_kpi> [CONSUMERS]-<Reporting> [FREQUENCY]-<Daily @ checks enabled starting 7AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/25/2023> [ENTRY UPDT]--<10/25/2023>
#0,15,30,45 7,8,9,10,11,12,13,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_ga4_wom_api/daily/ga4_daily.py "101" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_ga4_wom_api/daily/ga4_json_property.json" >/tmp/gcp_ing_bindingid_101.out 2>&1

#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<ga4_wom_daily_kpi> [CONSUMERS]-<Reporting> [FREQUENCY]-<Daily @ checks enabled starting 7AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/25/2023> [ENTRY UPDT]--<10/25/2023>
#15,30,45 7,8,9,10,11,12,13,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "104" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_104.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<placed_online_orderitem_complete> [CONSUMERS]-<Analytics> [FREQUENCY]-<Daily @ checks enabled starting 9AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/26/2023> [ENTRY UPDT]--<12/26/2023>
#0,15,30,45 9,10,11,12,13,14,15,16,17 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "115" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_115.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@VIP> [CONSUMERS]-<BigData> [FREQUENCY]-<Daily at 8:30AM EST hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<2024-03-06> [ENTRY UPDT]--<2024-03-06>
#30 8 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "118" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_118.out 2>&1


#General Logging for Hybrid push from HDL to GCP
#[PROCESS]- <HybridPush@General_Logging> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<General Logging for tnpskaf, totrlsf> [CONSUMERS]-<GCP> [FREQUENCY@ Daily]-<Everyday at 7:30AM EST hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<09/05/2023> [ENTRY UPDT]--<09/05/2023>
#30 7 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/scripts/bash/hdl_data_push_gcp/general_logging_for_hybrid_push/tnpskaf_totrlsf.sh >/tmp/general_logging_tnpskaf_totrlsf.out 2>&1
##################################END-Daily Job Schdules ##############################################################


##################################START-Weekly Job Schdules ###########################################################
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<TDMCUSC and TDMSCON refresh in HDL> [CONSUMERS]-<SAS> [FREQUENCY]-<Weekly @ Monday @ 05:02> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/27/2017> [ENTRY UPDT]--<02/08/2018>
#2 5 * * 1 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/offline/dms_workflow/config/cardinals.sh >/tmp/ETLCardinals.out 2>&1
#[PROCESS]- <ETL> [JOBTYPE]-<Bash,Oozie>-[JOBPURPOSE]-<TDMMLOG> [CONSUMERS]-<SAS> [FREQUENCY]-<Weekly @ Wednesday @ 07:00> [ENTRYBY]-<PK> [ENTRY CRDT]--<12/01/2019> [ENTRY UPDT]--<12/01/2019>
#0 9 * * 0 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/offline/dms_workflow/config/tdmmlog.sh >/tmp/ETLTDMMLOG.out 2>&1

#Airflow Jobs
#############
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@RegSub> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#0 9,10 * * 0 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_registration_subscription.sh >/tmp/airflow_reg_sub.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@Auxiliary_2> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger for 4 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#30 9,10,11,12 * * 0 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_online_auxiliary_2.sh >/tmp/airflow_auxiliary_2.out 2>&1
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Airflow@Instant_Win_2> [CONSUMERS]-<HDL, SAS> [FREQUENCY]-<Execution only once, but trigger for 2 hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<02/22/2021> [ENTRY UPDT]--<02/22/2021>
#5 9,10 * * 0 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_instant_win_2.sh >/tmp/airflow_instant_win_2.out 2>&1
#DMS Flat Variables
#0 17 * * 0 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_dms_flat_variables.sh >/tmp/airflow_dms_flat_variables.out 2>&1


#GCP Compute Jobs
#################
#[PROCESS]- <ETLUtils> [JOBTYPE]-<Python>-[JOBPURPOSE]-<DataRefresh@tdmmlog> [CONSUMERS]-<BigData> [FREQUENCY]-<Every Sunday of the week> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<06/24/2023> [ENTRY UPDT]--<06/24/2023>
#0,15,30,45 13,14,15,16,17 * * 0 /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "81" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_grp_binding_id_81.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<admargin_weekly> [CONSUMERS]-<Analytics> [FREQUENCY]-<Weekly @ checks enabled starting 8AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/25/2023> [ENTRY UPDT]--<10/25/2023>
#0,15,30,45 8,9,10,11,12,13,14,15,16,17 * * 1 /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "100" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_100.out 2>&1
#[PROCESS]- <Compute> [JOBTYPE]-<TableauOnlineRefresh>-[JOBPURPOSE]-<admargin_weekly> [CONSUMERS]-<Reporting> [FREQUENCY]-<Weekly @ checks enabled starting 9:30AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/25/2023> [ENTRY UPDT]--<10/25/2023>
0,15,30,45 10,11,12,13,14,15,16,17 * * 1 /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_tableau_trigger.py "3" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/tableau_bindingid_3.out 2>&1


#General Logging for Hybrid push from HDL to GCP
#[PROCESS]- <HybridPush@General_Logging> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<General Logging for onlineorder_payprojections> [CONSUMERS]-<GCP> [FREQUENCY@ Every Thursday]-<at 8AM EST hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<09/05/2023> [ENTRY UPDT]--<09/05/2023>
#0 8 * * THU /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/scripts/bash/hdl_data_push_gcp/general_logging_for_hybrid_push/onlineorder_payprojections.sh >/tmp/general_logging_onlineorder_payprojections.out 2>&1
#[PROCESS]- <HybridPush@General_Logging> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<General Logging for tbsabal> [CONSUMERS]-<GCP> [FREQUENCY@ Every Sunday]-<at 8AM EST hours> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<09/05/2023> [ENTRY UPDT]--<09/05/2023>
#0 8 * * SUN /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/scripts/bash/hdl_data_push_gcp/general_logging_for_hybrid_push/tbsabal.sh >/tmp/general_logging_tbsabal.out 2>&1
##################################END-Weekly Job Schdules #############################################################


##################################START-Monthly Job Schdules ##########################################################

#[PROCESS]- <Compute> [JOBTYPE]-<Ingestion>-[JOBPURPOSE]-<ga4_wom_monthly_kpi> [CONSUMERS]-<Reporting> [FREQUENCY]-<Monthly @ checks enabled starting 7AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/25/2023> [ENTRY UPDT]--<10/25/2023>
#30,45 7,8,9,10,11,12,13,14,15,16,17 1,2,3,4,5,6,7,8 * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_ga4_wom_api/monthly/ga4_monthly.py "103" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/config/gcp_ga4_wom_api/monthly/gcp_json_file_monthly.json" >/tmp/gcp_ing_bindingid_103.out 2>&1


#[PROCESS]- <Compute> [JOBTYPE]-<Compute-Airflow>-[JOBPURPOSE]-<ga4_wom_monthly_kpi> [CONSUMERS]-<Reporting> [FREQUENCY]-<Monthly @ checks enabled starting 7AM> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<10/25/2023> [ENTRY UPDT]--<10/25/2023>
#0,15,30,45 7,8,9,10,11,12,13,14,15,16,17 1,2,3,4,5,6,7,8 * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/python/generic/generic_trigger.py "105" "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/bigdata/global_variables/gen_bd_etl_airflow_vars.json" >/tmp/gcp_comp_bindingid_105.out 2>&1


##################################END-Monthly Job Schdules ############################################################


##################################START-Misc Job Schdules #############################################################
#Hive Synch Process for Campaign and Analytics_exchange schemas
#0 * * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/scripts/bash/campaign_exchange_hivescheamsynch_process.sh  >/tmp/campaign_exchange_hivescheamsynch_process.out 2>&1

##################################END-Misc Job Schdules ###############################################################

##################################START-DEV/TEST Job Schdules #########################################################

#[PROCESS]- <IncAppend> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<FullLoadFrmSrcToSA> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 5th min of 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23> [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<11/06/2019> [ENTRY UPDT]--<11/06/2019>
#5,10,15,20,25,30,35,40,45,50,55,59 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/test/incremental_append_test/incrementalload_append_v4.sh >/tmp/incrementalload_append_v4.out 2>&1

#30 * * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/offline/dms_workflow/config/Test.sh >/tmp/OozieTest.out 2>&1

#RAJIVTEST EPS
#30,40,50,0 * * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/reporting/acquisition_uber_stats_workflow/config/tdmnono_tdmordr_extrct_hdrseq.sh >/tmp/tez_pbasa.out 2>&1
#prashanttest
#19 15 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/offline/dms_workflow/scripts/hive/vars_metadataupdate/test.sh >/tmp/prashanttest.out 2>&1

# [FREQUENCY]-<Every one hour @ 05 mins> [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<08/21/2019> [ENTRY UPDT]--<08/21/2019>

#5 8 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/child_script/cart_basecdcfull.sh >/tmp/EcommCartrebase.out 2>&1

#10 9,10,11,12,13,14,15,16,17,18,19,20,21,22 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/child_script/incrementalload_rebildbase_cart.sh >/tmp/EcommCartIMLoad.out 2>&1

#RepoOnlineScore_Refresh trigger
#0 8 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/auxiliary_workflow/config/onlinescores_repo_cron.sh >/tmp/RepoOnlineScores.out 2>&1

#[PROCESS]- <IncAppend> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<TempPBManualRecon> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 5th min of 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<12/06/2019> [ENTRY UPDT]--<12/06/2019>
#10,20,30,40,50 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/generic_ingestion/config/sqoop_rdbms/child_script/incrementalload_append_v1_pb_dontdelete.sh >/tmp/incr_append_pb_manualrecon.out 2>&1
#RTD Agg request from HDL
#0 14 * * * /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/modelling/bigdata/prod/process_pickrj/sparketl_rj/rtd/spark-hdltobq1.sh >/tmp/Rtd_spark.out 2>&1

#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<ful lload from MYSQL view_token_transaction to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<once a day @ 1am EST> [ENTRYBY]-<Veeresh> [ENTRY CRDT]--<07/28/2020> [ENTRY UPDT]--<07/28/2020>
#0 1 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "6" "ingestion" >/tmp/grpbinding_6_ingestion.out 2>&1

#[PROCESS]- <INGESTION@SQOOP> [JOBTYPE]-<Bash>-[JOBPURPOSE]-<Incremental append from MYSQL to HDL(SA)> [CONSUMERS]-<HDL> [FREQUENCY]-<Every 2 hours  @2 minute> [ENTRYBY]-<Prashant> [ENTRY CRDT]--<7/21/2020> [ENTRY UPDT]--<10/27/2017>
#2 1,2,3 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "7" "ingestion" >/tmp/grpbinding_7_ingestion.out 2>&1
#0,30 0,7,9,10,11,12,13,14,15,16,17,18,19,20 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "1" "ingestion_workflow" >/tmp/grpbinding_1_ingestion_workflow.out 2>&1
#30 3,5 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "10" "ingestion_workflow" >/tmp/grpbinding_10_ingestion_workflow.out 2>&1

#30 2,3,9,12,15,18,21 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "23" "ingestion_workflow" >/tmp/grpbinding_23_ingestion_wrkflw.out 2>&1

#45 2,3,9,12,15,18,21 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "24" "ingestion_workflow" >/tmp/grpbinding_24_ingestion_wrkflw.out 2>&1

#1 9,12,13,16,18,20,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "15" "ingestion" >/tmp/grpbinding_15_ingestion.out 2>&1

#30 2,3,9,12,15,18,21 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "26" "ingestion_workflow" >/tmp/grpbinding_26_ingestion_wrkflw.out 2>&1

#30 5,7,10,16,22 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "31" "workflow" >/tmp/grpbinding_31_workflow.out 2>&1

#0 11 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "16" "workflow" >/tmp/grpbinding_16_workflow.out 2>&1

#0 11,12,13,15,17,19,21 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "32" "ingestion" >/tmp/grpbinding_32_ingestion.out 2>&1

#30 14 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "33" "workflow" >/tmp/grpbinding_33_workflow.out 2>&1

#0 8 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "37" "workflow" >/tmp/grpbinding_37_workflow.out 2>&1

#0 6 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/ga_wom_workflow/config/trigger_script.py "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/ga_wom_workflow/resources/ga_wom_api.json" "38" >/tmp/grpbinding_38_ingestion_workflow.out 2>&1

#0 7 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "39" "workflow" >/tmp/grpbinding_39_workflow.out 2>&1

#0 7 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "40" "workflow" >/tmp/grpbinding_40_workflow.out 2>&1

#0 3 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "13" "ingestion_workflow" >/tmp/grpbinding_13_ingestion_workflow.out 2>&1

#0 3 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "52" "ingestion_workflow" >/tmp/grpbinding_52_ingestion_workflow.out 2>&1

#0,30 * * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/common/config/etl_generic_prototype/parent_script.py "60" "ingestion" >/tmp/grpbinding_60_ingestion.out 2>&1


#Testing on GCP_Ingestion_Framework
#0,15,30,45 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * * /usr/local/bin/python3 /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/test/pb_testing/test.py "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/etl_generic_prototype/generic_ingestion/test/pb_testing/gcp_etl_generic_properties.json" "1" >/tmp/gcp_ingestion_framework_test.out 2>&1

#credit collections team schedule
#30 12 * * 0 nohup /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/modelling/bigdata/prod/process_pickrj/sparketl_rj/basa/spark-hdltobq_cc.sh > /tmp/script.log 2>&1
#Offfline Vars upload to GCP
#30 11 * * 6 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/config/gcs_upload.sh  >/tmp/gcs_upload.out 2>&1
#0 15 * * 6 /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/gcp/gold_core/scripts/bash/process/hdptogcp_airflow_dms_flat_variables.sh >/tmp/hdptogcp_airflow_dms_flat_variables.out 2>&1
#25 0 * * Sun /bin/sh /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/modelling/bigdata/prod/gold_core/bash/copy_tdmcudq_file_from_snapshot.sh  >/tmp/copy_tdmcudq_file_from_snapshot.out 2>&1
#30 8 * * 4 nohup /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/modelling/bigdata/prod/process_pickrj/sparketl_rj/basa/spark-hdltobq_custom.sh > /tmp/script.log 2>&1
#################################END-DEV/TEST Job Schdules ###########################################################
