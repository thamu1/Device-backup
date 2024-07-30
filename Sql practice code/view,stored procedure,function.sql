use world;

select * from city;

-- View

create view callAll as (select * from  city where CountryCode='AFG');
select * from callAll;
drop view callAll;

select * from city where Name in(select Name from callAll where Population > 200000);  -- view Sub query.

-- Store procedure

delimiter $$
create procedure callProc(code varchar(50))
begin
select * from city where CountryCode = code;
end ;


delimiter //
create procedure sumPopulation(val int , code varchar(5))
begin
select Name, Population+val as sumPop from city where CountryCode = code ;
end ;


call sumPopulation(2,'AFG');
call callProc('AFG');

drop procedure callProc;
drop procedure sumPopulation;

delimiter $$
CREATE FUNCTION addFour(val int)
RETURNS INTEGER
deterministic
BEGIN
declare sum int;
set sum = val+4;
RETURN sum;
END$$
delimiter ;

select Population , addFour(Population) from city;

drop function addFour;

delimiter $$
create function loopfunc()
returns int
deterministic
begin
declare x int;
set x= 1;
rep: loop
	if x>5 then
		LEAVE  rep;
	else 
		set x = x+1;
	END  IF;
end loop;
return x;
end$$
delimiter ;

select loopfunc();

drop database air;
drop user if exists 'air' ;
CREATE DATABASE air;
CREATE USER 'air'@'%' IDENTIFIED BY 'password';
GRANT USAGE,EXECUTE ON *.* TO 'air'@'%';
GRANT ALL PRIVILEGES ON air.* TO 'air'@'%';
FLUSH PRIVILEGES;


-- drop database airflow;

use airflow_class_db;
show tables;
drop database airflow_class_db;


use thamu;
show tables;
select * from mysql_try;
drop database thamu;

use world;
select * from city;

select CountryCode , count(CountryCode) count from city group by CountryCode having count=1;
select count(distinct CountryCode) from city ;





