create or replace  table " "
as (
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
)