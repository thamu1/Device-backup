use world ;

show tables;

select * from city ;

-----------------------------------------------------------------------------------------------------------------

SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SET sql_mode= ''

SET sql_mode = 'ONLY_FULL_GROUP_BY'

-----------------------------------------------------------------------------------------------------------------

SET SQL_SAFE_UPDATES = 1;

-----------------------------------------------------------------------------------------------------------------


create view cityview as select Name, CountryCode, District from city ;
select * from cityview where CountryCode = 'AFG';
alter view cityview as select Name,District from city;
drop view cityview;

------------------------------------------------------------------------------------------------------------------


delimiter $$
create procedure vitypro()
begin
select * from city ;
end $$
delimiter  ;

------------------------------------------------------------------------------------------------------------------


create table citycopy like city;
select * from citycopy;
drop table citycopy ; 

select distinct CountryCode ,avg(Population) over(), sum(Population) over(partition by CountryCode)
from city ;

------------------------------------------------------------------------------------------------------------------


use world;
select * from city;
select * from country;

select CountryCode , count(CountryCode) from city group by CountryCode having (count(Countrycode>1));

select Name , Population from 
(select distinct Name , Population from city order by Population desc limit 4) as tab
order by Population limit 1;

------------------------------------------------------------------------------------------------------------------


select * from student;
select * from stu_marks;

select distinct s.std_no from student st left join 
stu_marks s on st.std_no <> s.std_no;

select std_no , name,length(name) from student;
select * from customer;

select * from 
(select *,extract(year from PromoEnrlDt) as year_on from customer) tab2 where year_on = '2022'; 


select * from customer where PromoEnrlDt > '2022-01-31';

------------------------------------------------------------------------------------------------------------------

use sakila;


select last_update , time(last_update) from country;

select country , if(yn='yes',replace(country,'a','#'),country) from 
(select country , if(locate('a',country),'yes','no') as yn from country) as tb2;

select * from country;
select count(country) over(partition by year(last_update)) as yearly , 
count(country) over(partition by year(last_update)) as monthly 
from country ; 


------------------------------------------------------------------------------------------------------------------
select * from actor;
select * from actor_table;

-- replace null with another value --------
select coalesce(a.actor_id , 0), ac.id from actor a 
right join actor_table ac on a.actor_id=ac.id;

------------------------------------------------------------------------------------------------------------------

use world;
select * from city;
select * from country;

select * from city natural join country;

select count(*) from (
select CountryCode, row_number() over(partition by CountryCode) as unic from city) as en
where unic = 1;

select * from city order by ID desc limit 1;

------------------------------------------------------------------------------------------------------------------

use sakila;
select * from city;
select *,3 as sequence from country;

select ci.city_id,ci.city, co.country_id, co.country
from city ci right join country co on (ci.country_id = co.country_id)
where ci.country_id = null;

------------------------------------------------------------------------------------------------------------------


select * from (select address_id,district,city_id,postal_code,last_update,
rank() over(partition by district order by last_update desc) rnk
from address )as ttll where rnk = 1 ;
------------------------------------------------------------------------------------------------------------------

select if(format(current_date(),'yyyy-MM-dd') = format(current_date(),'yyyy-MM-dd'),"yes","no");

------------------------------------------------------------------------------------------------------------------

-- The LAG() function is used to get value from row that precedes the current row.

-- The LEAD() function is used to get value from row that succeeds the current row.

-- in a single column datediff():
SELECT ProductTyp, MAX(dat) FROM (
  SELECT DISTINCT ProductTyp, DATEDIFF(PurchDt, LAG(PurchDt) OVER (PARTITION BY ProductTyp ORDER BY PurchDt)) AS dat
  FROM product
) AS tb2 
GROUP BY ProductTyp;


-- get 2nd largest value in a each group of value
select ProductTyp,dat
from(
SELECT ProductTyp, dat, dense_rank() over( partition by ProductTyp order by dat desc) as seclar
FROM (
  SELECT DISTINCT ProductTyp, DATEDIFF(PurchDt, LAG(PurchDt) OVER (PARTITION BY ProductTyp ORDER BY PurchDt)) AS dat
  FROM product
) AS tb2 
) tb3 where seclar = 2



SELECT DISTINCT seller_id,ship_date, lag(ship_date,2) OVER (PARTITION BY seller_id ORDER BY ship_date) AS dat
FROM world.order 
order by seller_id, ship_Date

------------------------------------------------------------------------------------------------------------------

-- Leet code Consecutive number count

SELECT num,grp, COUNT(*) AS consecutive_count
FROM (
  SELECT num,
         ROW_NUMBER() OVER (ORDER BY id) 
         - ROW_NUMBER() OVER (PARTITION BY num ORDER BY id) AS grp
  FROM Logs
) AS grouped
GROUP BY num, grp
ORDER BY consecutive_count DESC
limit 1

------------------------------------------------------------------------------------------------------------------

-- Variables:

SELECT  @msrp:=MAX(msrp) FROM products;

SELECT productCode, productName, productLine, msrp
FROM products
WHERE msrp = @msrp;

------------------------------------------------------------------------------------------------------------------

-- Compare successive row with in the same table:  [this is same as lead() over() of function]

	SELECT 
		g1.item_no,
		g1.counted_date from_date,
		g2.counted_date to_date,
		(g2.qty - g1.qty) AS receipt_qty
	FROM
		inventory g1
			INNER JOIN
		inventory g2 ON g2.id = g1.id + 1
	WHERE
		g1.item_no = 'A';

------------------------------------------------------------------------------------------------------------------

-- row number generate:

	SET @row_number = 0; 
	SELECT 
		(@row_number:=@row_number + 1) AS num, 
		firstName, lastName
	FROM employees
	ORDER BY firstName, lastName LIMIT 5;

------------------------------------------------------------------------------------------------------------------

-- Generate random :

SELECT * FROM table_name ORDER BY RAND() LIMIT 1;

------------------------------------------------------------------------------------------------------------------

-- get nth greatest value:

	SELECT 
		productCode, productName, buyPrice
	FROM
		products
	ORDER BY buyPrice DESC
	LIMIT 1 , 1;

------------------------------------------------------------------------------------------------------------------
	
-- Delete duplicate value:
	DELETE t1 FROM contacts t1
	INNER JOIN contacts t2 
	WHERE 
		t1.id < t2.id AND 
		t1.email = t2.email;
    
------------------------------------------------------------------------------------------------------------------


