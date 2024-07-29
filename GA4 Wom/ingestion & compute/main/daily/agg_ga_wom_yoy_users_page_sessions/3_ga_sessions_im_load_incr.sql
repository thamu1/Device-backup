SET hive.mapred.mode=nonstrict ;
set hive.exec.parallel=true;
set hive.exec.parallel.thread.number=20;
set hive.auto.convert.join=true;
set hive.exec.compress.output=true;
set hive.exec.compress.intermediate=true; 
set mapred.job.name=ga_wom_web_activity_yoy_agg;
set mapreduce.map.memory.mb=8192;
set mapreduce.reduce.memory.mb=8192;
set mapreduce.map.java.opts=-Xmx3072m;
set mapreduce.reduce.java.opts=-Xmx6144m;
set mapreduce.job.user.classpath.first=true;
set hive.groupby.skewindata=true;

insert overwrite table ${hivevar:im_hdl_agg_db}.ga_wom_web_activity_yoy_agg
 select
 report,
 rolling_dt,
 domain,
 sessions,
 users,
 pageviews,
 equivalent_dt,
 yr_indicator
 from ${hivevar:cm_stg_adhoc_db}.agg_ga_wom_yoy_inter_im
 ;