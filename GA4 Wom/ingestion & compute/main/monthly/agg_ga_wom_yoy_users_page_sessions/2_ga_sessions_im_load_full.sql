
create or replace table " "
as 
(
 select
 'Overall' as `report`,
 drv.`rolling_dt` as `rolling_dt`,
 'Overall' as `domain`,
 ref.`sessions`,
 ref.`users`,
 ref.`pageviews`,
 drv.`equivalent_dt` as `equivalent_dt`,
 drv.`yr_indicator` as `yr_indicator`
 from ${hivevar:cm_stg_adhoc_db}.ga_sessns_date_driver drv --> 
 join ${hivevar:im_adhoc_db}.ga_wom_web_activity_rpt ref --> 
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
 from ${hivevar:cm_stg_adhoc_db}.ga_sessns_date_driver drv -->
 join ${hivevar:im_adhoc_db}.ga_wom_web_activity_core_domains_rpt ref  -->
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
 from ${hivevar:cm_stg_adhoc_db}.ga_sessns_date_driver drv  -->
 join ${hivevar:im_adhoc_db}.ga_wom_web_activity_other_domains_rpt ref -->
 on (drv.`rolling_dt` = ref.`event_dt`)
 ) final group by `report`, `rolling_dt`, `domain`,
 `equivalent_dt`, `yr_indicator`
)