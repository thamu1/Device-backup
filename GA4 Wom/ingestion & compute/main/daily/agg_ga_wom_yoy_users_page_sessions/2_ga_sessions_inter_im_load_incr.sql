SET hive.mapred.mode=nonstrict ;
set hive.exec.parallel=true;
set hive.exec.parallel.thread.number=20;
set hive.auto.convert.join=true;
set hive.exec.compress.output=true;
set hive.exec.compress.intermediate=true; 
set mapred.job.name=agg_ga_wom_yoy_inter_im;
set mapreduce.map.memory.mb=8192;
set mapreduce.reduce.memory.mb=8192;
set mapreduce.map.java.opts=-Xmx3072m;
set mapreduce.reduce.java.opts=-Xmx6144m;
set mapreduce.job.user.classpath.first=true;
set hive.groupby.skewindata=true;


insert overwrite table ${hivevar:cm_stg_adhoc_db}.agg_ga_wom_yoy_inter_im
 select
 'Overall' as `report`,
 drv.`rolling_dt` as `rolling_dt`,
 'Overall' as `domain`,
 ref.`sessions`,
 ref.`users`,
 ref.`pageviews`,
 drv.`equivalent_dt` as `equivalent_dt`,
 drv.`yr_indicator` as `yr_indicator`
 from ${hivevar:cm_stg_adhoc_db}.ga_sessns_date_driver drv
 join ${hivevar:im_adhoc_db}.  ref
 on (drv.`rolling_dt` = ref.`event_dt`)
 UNION
 select
 'ByDomain' as `report`,
 drv.`rolling_dt` as `rolling_dt`,
 ref.`hostname` as `domain`,
 ref.`sessions`,
 ref.`users`,
 ref.`pageviews`,
 drv.`equivalent_dt` as `equivalent_dt`,
 drv.`yr_indicator` as `yr_indicator`
 from ${hivevar:cm_stg_adhoc_db}.ga_sessns_date_driver drv
 join ${hivevar:im_adhoc_db}.ga_wom_web_activity_core_domains_rpt ref
 on (drv.`rolling_dt` = ref.`event_dt`)
 UNION
 select `report`, `rolling_dt`, `domain`, SUM(`sessions`) as `sessions`,
 SUM(`users`) as `users`, SUM(`pageviews`) as `pageviews`,
 `equivalent_dt`, `yr_indicator`
 from
 (
 select
 'ByDomain' as `report`,
 drv.`rolling_dt` as `rolling_dt`,
 'Other' as `domain`,
 ref.`sessions`,
 ref.`users`,
 ref.`pageviews`,
 drv.`equivalent_dt` as `equivalent_dt`,
 drv.`yr_indicator` as `yr_indicator`
 from ${hivevar:cm_stg_adhoc_db}.ga_sessns_date_driver drv
 join ${hivevar:im_adhoc_db}.ga_wom_web_activity_other_domains_rpt ref
 on (drv.`rolling_dt` = ref.`event_dt`)
 ) final group by `report`, `rolling_dt`, `domain`,
 `equivalent_dt`, `yr_indicator`
 UNION
 select
 report,
 rolling_dt,
 domain,
 sessions,
 users,
 pageviews,
 equivalent_dt,
 yr_indicator
 from ${hivevar:im_hdl_agg_db}.ga_wom_web_activity_yoy_agg
 where equivalent_dt < format_Date("%Y%m%d",date_sub(current_date(), interval ${hivevar:reconbacktrace}))
 ;