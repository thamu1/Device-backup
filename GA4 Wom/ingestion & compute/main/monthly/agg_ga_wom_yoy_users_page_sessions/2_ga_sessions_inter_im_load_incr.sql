create or replace procedure ` `(st date, en date)
begin

declare st_date date;
declare end_date date;

declare min_st int64;
declare max_dt int64;

set st_date = st;
set end_date = en;

create temp table "temp"
as (
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
 where equivalent_dt < format_Date("%Y%m%d",date_sub(current_date(), interval (date_diff(end_date, st_date, day)) day)) 
);
 


set min_dt  = (SELECT min(`equivalent_dt`) FROM `temp`);
set max_dt  = (SELECT max(`equivalent_dt`) FROM `temp`);


delete from  `uat-gold-core.it_sa_onl_ing_cdc_ext.ga4_overall` 
where `equivalent_dt` between  min_dt and max_dt;

insert into `uat-gold-core.it_sa_onl_ing_cdc_ext.ga4_overall`
(
  select * from `temp_table`
);

drop table `temp_table`;

end;