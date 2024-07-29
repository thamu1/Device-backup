
insert into major_final_table 
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
    `uat-gold-core.it_sa_onl_ing_cdc_ext.ga4_wom_major` )
WHERE
  rnk = 1