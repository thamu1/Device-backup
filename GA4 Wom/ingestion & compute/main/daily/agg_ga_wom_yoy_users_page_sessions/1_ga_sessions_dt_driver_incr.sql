
with main_dt_drv as 
(
select *,

extract(year from equivalent_dt) as curr_year,
extract(year from equivalent_dt) - 1 as prev_year,
extract(year from equivalent_dt) -2 as prev_to_prev_year

 from (

WITH t AS (
  select date (current_Date() - interval {reconstarttrace} day) as StartDate,date (current_Date() - interval {reconendtrace} day) as enddate, i 
  from UNNEST(GENERATE_ARRAY(1, date_diff(date (current_Date() - interval {reconendtrace} day), date (current_Date() - interval {reconstarttrace} day), day)+1)) 
  as da with offset as i
)
select

date_add (t.StartDate,interval t.i day) as equivalent_dt,

-- -------------------------------------------------------------
 date_add(
  date_trunc(date_add(date_trunc(date_add (t.StartDate,interval i day),year),interval -2 day), year),
 
  interval 
 safe_cast(
  safe_cast(format_date('%j',date_add (t.StartDate,interval i day)) as int64) - 1 + 
 (safe_cast(format_Date('%u', date_trunc(date_add (t.StartDate,interval i day), year)) as int64)+1)
 - (safe_cast(format_Date('%u', date_trunc(date_add(date_trunc(date_add (t.StartDate,interval i day),year) ,interval -2 day), year)) as int64)+1) 
 
 as int64)
 
 day) as prev_year_dt,

 -- ------------------------------------------------------------

 date_add (
  
  date_trunc(date_add(
    
date_trunc(date_add(date_trunc(date_add(date_trunc(date_add (t.StartDate,interval t.i day), year),interval -2 day), year),

interval

safe_cast (safe_cast(format_date("%j", date_add (t.StartDate,interval t.i day)) as int64) - 1 + 
 (safe_cast(format_date("%u", date_trunc(date_add (t.StartDate,interval t.i day), year)) as int64)+1)
 - (safe_cast(format_date("%u", date_trunc(date_add(date_trunc(date_add (t.StartDate,interval t.i day), year),interval -2 day), year)) as int64)+1) as int64)
 
day

 ), year),interval -2 day), year),
 
 interval 
 
 safe_cast( safe_cast(format_date("%j", date_add(date_trunc(date_add(date_trunc(date_add (t.StartDate,interval t.i day), year),interval -2 day), year),
 
 interval
 
 safe_cast(safe_cast(format_date("%j", date_add (t.StartDate,interval t.i day)) as int64) - 1 + 
 (safe_cast(format_date("%u", date_trunc(date_add (t.StartDate,interval t.i day), year)) as int64)+1)
 - (safe_cast(format_date("%u", date_trunc(date_add(date_trunc(date_add (t.StartDate,interval t.i day), year),interval -2 day), year)) as int64)+1) as int64) 
 
 day)) as int64) - 1 + 
 ( safe_cast(format_date("%u", date_trunc(date_add(date_trunc(date_add(date_trunc(date_add (t.StartDate,interval t.i day), year),interval -2 day), year),
 
 interval
 
 safe_cast( safe_cast(format_date("%j", date_add (t.StartDate,interval t.i day)) as int64) - 1 + 
 (safe_cast(format_date("%u", date_trunc(date_add (t.StartDate,interval t.i day), year)) as int64)+1)
 - (safe_cast(format_date("%u", date_trunc(date_add(date_trunc(date_add (t.StartDate,interval t.i day), year),interval -2 day), year)) as int64)+1) as int64) 
 
 
 day), year)) as int64)+1)


 - (safe_cast(format_date("%u", date_trunc(date_add(date_trunc(date_add(date_trunc(date_add(date_trunc(date_add (t.StartDate,interval t.i day), year),interval -2 day), year),
 
interval

 safe_cast(safe_cast(format_date("%j", date_add (t.StartDate,interval t.i day)) as int64) - 1 + 
 (safe_cast(format_date("%u", date_trunc(date_add (t.StartDate,interval t.i day), year)) as int64)+1)
 - (safe_cast(format_date("%u", date_trunc(date_add(date_trunc(date_add (t.StartDate,interval t.i day), year),interval -2 day), year)) as int64)+1) as int64)

 day

 
 ), year),interval -2 day), year)) as int64)+1) as int64)
 
 day
 
 ) as prev_to_prev_year_dt,

 -- ---------------------------------------------------------------

 from t
)
)

 select format_date("%Y%m%d", equivalent_dt) as equivalent_dt, format_date("%Y%m%d", equivalent_dt) as rolling_dt, 
 curr_year as yr_indicator
 from main_dt_drv
 UNION all
 select format_date("%Y%m%d", equivalent_dt) as equivalent_dt, format_date("%Y%m%d", prev_year_dt) as rolling_dt,
  prev_year as yr_indicator
 from main_dt_drv
 UNION all
 select format_date("%Y%m%d", equivalent_dt) as equivalent_dt, format_date("%Y%m%d", prev_to_prev_year_dt) as rolling_dt, prev_to_prev_year as yr_indicator
 from main_dt_drv
 ;
