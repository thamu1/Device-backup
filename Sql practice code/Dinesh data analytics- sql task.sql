use world ;

-- 1st table *********************************

create table cus_info(Cus_id int, Name Varchar(50) ,City Varchar(50) ,primary key(Cus_id));
create table traval_info(Cus_id int, Trv_typ Varchar(50) , Trv_td datetime , Orig Varchar(10) , Dest Varchar(10),
FOREIGN KEY (Cus_id) REFERENCES cus_info(Cus_id));

insert into cus_info values(111,'Dinesh','Chennai'),
(222,'Selva','Tanjavur'),
(333,'Gayathri','Chennai'),
(444,'Ragul','Trichy'),
(555,'Manika','Delhi'),
(666,'Bakram','Mumbai');

insert into traval_info values
(111,'Business','2022-1-5','CHE','BLR'),
(222,'Personal','2022-4-10','DHL','MUM'),
(555,'Personal','2022-2-7','DHL','CHE'),
(666,'Business','2022-3-28','BLR','KOL'),
(111,'Personal','2022-5-14','MUM','DHL'),
(222,'Business','2022-1-26','KOL','CHE') ;


select distinct c.Cus_id , c.Name , t.Orig ,t.Dest 
from cus_info c join traval_info t 
on c.Cus_id = t.Cus_id
where t.Trv_typ = 'Business' ;

create view cheToblr as(select * from traval_info
where Orig ='CHE' and Dest = 'BLR');
select * from cheToblr;

create view chlToche as(select * from traval_info
where Orig ='DHL' and Dest = 'CHE');
select * from chlToche;

-- select t.Cus_id ,count(t.Trv_td) over(partition by date_format(t.Trv_td,'%Y-%m')) 
-- from traval_info t 
-- where t.Trv_td < date_sub(now(),interval 1 year);

select c.Name, t.Cus_id ,count(t.Trv_td) over(partition by date_format(t.Trv_td,'%Y-%m')) 
from traval_info t  join cus_info c on c.Cus_id = t.Cus_id
where t.Trv_td < date_sub(now(),interval 1 year);


select c.Name , t.Cus_id ,COUNT(date_format(t.Trv_td,'%Y-%m')) 
from cus_info c join traval_info t on c.Cus_id = t.Cus_id
where t.Trv_td <= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY t.Cus_id
HAVING COUNT(DISTINCT date_format(t.Trv_td,'%Y-%m') = 4);


-- 2nd table **************************************

CREATE TABLE transac (
        customer_id INT,
        trans_dt date,
        trans_amt INT
);

INSERT INTO transac VALUES 
(111, '2022-1-5', 739),
(222, '2022-1-14', 864),
(333, '2022-1-26', 819),
(444, '2022-1-31', 1000),
(111, '2022-2-7', 986),
(222, '2022-2-14', 583),
(444, '2022-2-21', 822),
(222, '2022-3-28', 874),
(444, '2022-4-2', 777),
(111, '2022-5-28',532);

select * from transac order by customer_id;

-- consecutive sum from current (sum of previous all)
select customer_id , trans_dt,trans_amt ,
sum(trans_amt) over(partition by customer_id order by customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  ) 
from transac ;

-- group by sum 
select distinct customer_id , trans_dt,trans_amt ,
sum(trans_amt) over(partition by customer_id order by customer_id ) 
from transac ;

-- current + next n following (only 2 value sum)
select customer_id , trans_dt,trans_amt ,
sum(trans_amt) over(order by customer_id ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) 
from transac ;

-- current row + previous row (only 2 value sum)
select customer_id , trans_dt,trans_amt ,
sum(trans_amt) over(order by customer_id ROWS 1 PRECEDING) 
from transac ;

-- ROWS UNBOUNDED PRECEDING (sum between previous and current infinite) or ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
select customer_id , trans_dt,trans_amt ,
sum(trans_amt) over(partition by customer_id order by customer_id ROWS UNBOUNDED PRECEDING) 
from transac ;

-- ROWS UNBOUNDED FOLLOWING (sum between  current and next infinite)
select customer_id , trans_dt,trans_amt ,
sum(trans_amt) over(partition by customer_id order by customer_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) 
from transac ;

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


-- 3rd table ***************************

create table customer(CustId int,PromoEnrlDt date,PromoCode Varchar(20));
create table product(CustId int,ProductTyp varchar(30),PurchDt date);

insert into customer values
(111,'2022-1-5','A1S2D3'),
(222,'2022-1-14','A1S2D3'),
(333 ,'2022-1-26', 'A1S2D3'),
(444,'2022-1-31','G56TR'),
(111,'2022-2-7','G56TR'),
(222,'2022-2-14','SBE45T'),
(444,'2022-2-21','A1S2D3'),
(222,'2022-3-28','NEW30D'),
(444,'2022-4-4','NEW30D'),
(111,'2022-5-28','SBE45T') ;

INSERT INTO product VALUES
(111, 'Electronic', '2022-01-07'),
(111, 'Fashion', '2022-01-15'),
(222, 'Fashion', '2022-01-28'),
(333, 'Electronic', '2022-02-09'),
(222, 'Fashion', '2022-02-15'),
(444, 'Fashion', '2022-02-28'),
(111, 'Home', '2022-03-08'),
(222, 'Fashion', '2022-04-01'),
(333, 'Home', '2022-02-14'),
(555, 'Fashion', '2022-03-28');


select * from customer;
select * from product;


select distinct CustId ,count(ProductTyp) 
from product where PurchDt <= date_sub(now(),interval 6 month)
group by CustId
having count(ProductTyp) > 2;

select distinct CustId from product 
where ProductTyp='Fashion' 
and ProductTyp != 'Electronic' and ProductTyp != 'Home';

select c.CustId ,p.ProductTyp,c.PromoCode , c.PromoEnrlDt , p.PurchDt ,datediff(p.PurchDt , c.PromoEnrlDt) 
from customer c join product p on c.CustId = p.CustId
where c.PromoCode = 'A1S2D3'and p.ProductTyp='Electronic' and datediff(p.PurchDt , c.PromoEnrlDt) < 90 ;


-- 4th table  *************************

CREATE TABLE student (
std_no INT PRIMARY KEY,name VARCHAR(50),address VARCHAR(50),age INT);

INSERT INTO student VALUES
(101, 'Ramu', 'Chennai', 15),
(102, 'Geetha', 'Madurai', 17),
(104, 'Prakash', 'Trichy', 16),
(105, 'Dinesh', 'Chennai', 17),
(107, 'Selva', 'Chennai', 17),
(108, 'Ranjani', 'Coimbatore', 16),
(110, 'Akash', 'Trichy', 15);

CREATE TABLE stu_marks (std_no INT,subject VARCHAR(40),marks INT,
FOREIGN KEY (std_no) REFERENCES student(std_no));

INSERT INTO stu_marks VALUES
(101, 'English', 70),
(102, 'Maths', 62),
(104, 'Science', 63),
(105, 'Maths', 86),
(101, 'Science', 97),
(102, 'English', 79),
(104, 'English', 68),
(107, 'Science', 81),
(108, 'Maths', 77),
(108, 'English', 81);

CREATE TABLE fee (std_no INT,class VARCHAR(40),amount INT,
FOREIGN KEY (std_no) REFERENCES student(std_no));

INSERT INTO fee VALUES
(101, 'Tenth', 20000),
(102, 'Tenth', 15000),
(104, 'twelfth', 14000),
(105, 'eleventh', 12000);


select * from student;
select * from stu_marks;
select * from fee;

select st.name, s.std_no , count(s.subject) 
from stu_marks s join student st using(std_no)
group by std_no
having count(s.subject) > 1;

select s.std_no , s.name , s.address , f.amount
from student s join fee f using(std_no)
where s.address = 'Chennai' and f.amount > 12000 ;

select m.std_no ,m.subject , m.marks , s.name 
from student s join stu_marks m using(std_no)
where m.marks > 65
order by m.std_no asc;


