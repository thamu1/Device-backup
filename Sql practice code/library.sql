-- create database library;
-- drop database library;

use library;


select * from student;
select * from studentlogindetails;


select name from student where rollno='es19it50';

update student set name='Thamu',rollno='es19it50'  where id=1;

insert into student(name,rollno) values('naveen','es19it30');


