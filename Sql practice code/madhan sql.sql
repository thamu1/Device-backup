SELECT seller_id,ship_date FROM world.order
order by seller_id asc;

------------------------------------------------------------------------------------------------------------

alter table world.order modify column seller_id varchar(100);

select seller_id, date(str_to_date(substr(shipping_limit_date,1,10),'%Y-%m-%d')) from world.order;

SELECT DATE_FORMAT(STR_TO_DATE(shipping_limit_date, '%d-%m-%Y %H.%i'), '%Y-%m-%d')
from world.order;

------------------------------------------------------------------------------------------------------------


SET SQL_SAFE_UPDATES = 1;

update world.order set ship_date = DATE_FORMAT(STR_TO_DATE(shipping_limit_date, '%d-%m-%Y %H.%i'), '%Y-%m-%d') ;

select seller_id, date(str_to_date(substr(shipping_limit_date,1,10),'%Y-%m-%d')) from world.order;

alter table world.order drop column ship_date;

alter table world.order add column ship_date date;

------------------------------------------------------------------------------------------------------------

INSERT INTO world.order (ship_date)
SELECT DATE_FORMAT(STR_TO_DATE(shipping_limit_date, '%d-%m-%Y %H.%i'), '%Y-%m-%d')
FROM world.order;

------------------------------------------------------------------------------------------------------------

SELECT DISTINCT seller_id, DATEDIFF(shipping_limit_date, lag(shipping_limit_date) OVER (PARTITION BY seller_id ORDER BY PurchDt)) AS dat
FROM world.order

select seller_id,dat
from(
SELECT seller_id, dat, dense_rank() over( partition by seller_id order by dat desc) as seclar
FROM (
  SELECT DISTINCT seller_id, , SELECT DISTINCT seller_id, DATEDIFF(shipping_limit_date, lag(shipping_limit_date) OVER (PARTITION BY seller_id ORDER BY PurchDt)) AS dat
FROM world.order
) AS tb2 
) tb3 where seclar = 2

------------------------------------------------------------------------------------------------------------

SELECT email_domain, array_to_string(ARRAY_AGG(global_member_token ORDER BY global_member_token),',') AS gmt

FROM `dev-gold-core.it_online_auxiliary.gmt_attributes`

GROUP BY email_domain limit 10;

------------------------------------------------------------------------------------------------------------

-- Get the total result between the last updated --
with tar as(
select *,
lag(ordate) over() as predate,
lag(ordate) over(partition by `type` order by ordate) as prebytype,
row_number() over(partition by acid order by ordate) as rnk
from vw_task
order by id)  -- select * from tar

select *, 
case when predate<>prebytype and rnk in(max(rnk) over(partition by acid))  then datediff(predate,prebytype)
	else 0
end as coun
from tar ;



							--------- result by count (method 1)----------

create or replace view vw_coun as(
with tar as(
select *,
lag(ordate) over() as predate,
lag(ordate) over(partition by `type` order by ordate) as prebytype,
row_number() over(partition by acid order by ordate) as rnk
from vw_task
order by id)  -- select * from tar

select *,
case when coun <> '0' then type 
	else 0 
	end as filtype
from(
select *,
case when predate<>prebytype and rnk in(max(rnk) over(partition by acid))  then rnk
	else 0
end as coun,
case when predate<>prebytype and rnk in(max(rnk) over(partition by acid))  then id
	else 0
end as counid
from tar) as subtb
);



with sub3 as(
select *,
case when type in (select filtype from vw_coun where filtype <> '0') then rnk 
	else 0 end as filpretype
from vw_coun
)

select *, 
case when (filpretype - diffpre - 1) = 1 then 0
	else (filpretype - diffpre - 1)
    end as result
from(
select *,
case when filpretype = coun and filpretype <> 0  then min(rnk) over(partition by acid) 
	else 0 
    end as diffpre
from sub3
where filpretype <> 0
) sub4

						--- result by subquery  (method 2)---

-- select * from vw_coun

with `tar` as 
(select `world`.`vw_task`.`id` AS `id`,`world`.`vw_task`.`acid` AS `acid`,
`world`.`vw_task`.`type` AS `type`,`world`.`vw_task`.`ordate` AS `ordate`,
lag(`world`.`vw_task`.`ordate`) OVER ()  AS `predate`,
lag(`world`.`vw_task`.`ordate`) OVER (PARTITION BY `world`.`vw_task`.`type` ORDER BY `world`.`vw_task`.`ordate` )  AS `prebytype`,
row_number() OVER (PARTITION BY `world`.`vw_task`.`acid` ORDER BY `world`.`vw_task`.`ordate` )  AS `rnk` 
from `world`.`vw_task` order by `world`.`vw_task`.`id`) 

select `tar`.`id` AS `id`,`tar`.`acid` AS `acid`,`tar`.`type` AS `type`,`tar`.`ordate` AS `ordate`,
`tar`.`predate` AS `predate`,`tar`.`prebytype` AS `prebytype`,`tar`.`rnk` AS `rnk` 
from `tar`

select *
from (
select *,
case when predate<> prebytype 
	then (select rnk from 
		(select id,rnk,ordate from 
			(select acid,id, rnk, ordate 
				from vw_coun where type = t1.type and acid = t1.acid and ordate < t1.ordate
				group by acid,id,ordate ) as st1
                ) as st2 )
    else 0
    end as re1
from(
select *
from vw_coun
)t1
) t2


									--- left Join column (method 3) ---

with `tar` as 
(select `world`.`vw_task`.`id` AS `id`,`world`.`vw_task`.`acid` AS `acid`,
`world`.`vw_task`.`type` AS `type`,`world`.`vw_task`.`ordate` AS `ordate`,
lag(`world`.`vw_task`.`ordate`) OVER ()  AS `predate`,
lag(`world`.`vw_task`.`ordate`) OVER (PARTITION BY `world`.`vw_task`.`type` ORDER BY `world`.`vw_task`.`ordate` )  AS `prebytype`,
row_number() OVER (PARTITION BY `world`.`vw_task`.`acid` ORDER BY `world`.`vw_task`.`ordate` )  AS `rnk` 
from `world`.`vw_task` order by `world`.`vw_task`.`id`) 

select `tar`.`id` AS `id`,`tar`.`acid` AS `acid`,`tar`.`type` AS `type`,`tar`.`ordate` AS `ordate`,
`tar`.`predate` AS `predate`,`tar`.`prebytype` AS `prebytype`,`tar`.`rnk` AS `rnk` 
from `tar`

select *, rono - diff as result
from(
select * 
from vw_coun2 j1
left join (select id as jid,lag(rono) over(partition by acid) as diff from vw_coun2 where  rono <> 0)  as j2
on j1.id = j2.jid
) as t2									 


------------------------------------------------------------------------------------------------------------


-- daterange sum() example for cohort


select  sum(da) over(partition by da between 1 and 2) from
(
select 1 as da
union all
select 6 as da
union all
select 3 as da
union all
select 4 as da
)

------------------------------------------------------------------------------------------------------------



