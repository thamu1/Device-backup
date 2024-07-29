call `uat-gold-core.it_sa_onl_ing_cdc_ext.ga4_overall_proc`(st date, en date);

create or replace procedure `uat-gold-core.it_sa_onl_ing_cdc_ext.ga4_overall_proc`(st date, en date)
begin

declare st_date date;
declare end_date date;

declare min_st int64;
declare max_dt int64;

set st_date = st;
set end_date = en;


create or replace temp table `temp_table`
as(
SELECT
  * EXCEPT(rnk)
FROM (
  SELECT
    `Date` AS `date`,
    Hostname AS hostname,
    Source_Group AS source_group,
    Users AS users,
    Pageview AS pageview,
    Sessions AS sessions,
    RANK() OVER(PARTITION BY `Date` ORDER BY src_ing_dt DESC) AS rnk
  FROM
    `uat-gold-core.it_sa_onl_ing_cdc_ext.ga4_wom_overall` )
WHERE
  rnk = 1 and src_ing_dt between st_date and end_date
  );

set min_dt  = (SELECT min(`Date`) FROM `uat-gold-core.it_sa_onl_ing_cdc_ext.ga4_wom_overall`);
set max_dt  = (SELECT max(`Date`) FROM `uat-gold-core.it_sa_onl_ing_cdc_ext.ga4_wom_overall`);


delete from  `uat-gold-core.it_sa_onl_ing_cdc_ext.ga4_overall` 
where `Date` between  min_dt and max_dt;

insert into `uat-gold-core.it_sa_onl_ing_cdc_ext.ga4_overall`
(
  select * from `temp_table`
);

drop table `temp_table`;

end;