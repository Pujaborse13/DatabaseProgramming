
/******************** CTE ***************************/

use BikeStores

select * from studentdata;

-- retun list of male student
with Male_Student
as
(select * from studentData where gender = 'Male')
select * from Male_Student


-- count of male student
with CountMale_Student
as
(select * from studentData where gender = 'Male')
select count(*) from CountMale_Student



with Age_Range
as
	(select * from studentData where gender = 'Male')
select * from Age_Range where age <= 17



with New_CTE(std_id, std_name, std_class)
as
(select Id,Name,[Standard] from studentdata where Gender='Male')
select std_id, std_name,std_class from New_CTE


--Insert CTE
with InsertData
as
(select * from studentdata)
insert InsertData values(10,'puja borse','female',19,'10th');


--Update CTE
with UpdateData
as
(select * from studentdata)
Update UpdateData set Name = 'Disha Kamble' where id = 2


--Delete Data
with DeleteData
as
(select * from studentdata)
delete DeleteData where id = 10



-- create  view CTE
 alter view VWNewViewDemo
as
with New_CTE
as
(select * from studentdata where [standard] = '12')
select * from New_CTE

select * from VWNewView

