

/*************** view ********************/

use BikeStores

select * from studentdata
select * from students
select * from student_marks


--Creating a Simple View (vwStudentMultiTable)
--This view joins students and student_marks based on roll_no.
--Fetches student names along with marks.
create view vwStudentMultiTable
as
select st.roll_no, st.FirstName, st.LastName , sm.Eng, sm.Science,sm.Math

from students st
join student_marks sm
On st.roll_no = sm.RollNo

select * from vwStudentMultiTable
---------------------------------------------------------

-- Update the metadata of a SQL view
/*
Creates a view vmStudent for the students table.
Adds a new column (Country).
Uses sp_refreshview to update metadata so the view reflects the change.

*/
create view vmStudent
as
select * from students

select  * from vmStudent
alter table students Add Country varchar(50)

exec sp_refreshview vmStudent


---------------------------------------------------
--Schema Binding a View
/*-- how to create schema binding a sql view
SCHEMABINDING prevents changes to the underlying table structure (like dropping/modifying columns).
Error if you try to modify the students table after this view is created:
*/

create  view vwStudentList
as
select * from students;

select * from vwStudentList
alter table Students drop column Country



create view vmStudentListWithSchemaBinding 
with SchemaBinding 
as
select roll_no, firstName,LastName 
from dbo.students;

-- cant update after creating view schema || you cant change view
alter table Students drop column LastName
alter table Students alter column LastName varchar(50);

----------------------------------------------------
-- Row-Level Security View (vmRowLevel)
-- create row level security 
--Only allows access to rows where roll_no < 3.

create view vmRowLevel As
select * from students where roll_no < 3;

select * from vmRowLevel

--Column-Level Security View (vmColumnLevel)
-- create column level security 
--Only shows roll_no and FirstName, hiding other columns.

create view vmColumnLevel
as
select roll_no,FirstName from students;
select * from vmColumnLevel
------------------------------------------------


/*
 Allowed Operations:
		INSERT, UPDATE, DELETE on a single table view.
Limitations:
		Cannot use GROUP BY, DISTINCT, UNION, JOIN, or subqueries.
		Cannot modify views created with SCHEMABINDING.



Updating view
	* we can use DML operations on a single table
	* view should not contain group by , distinct clauses
	* we cannot use a Subquery in a view in SQL server
	* we cannot use set operators in sql view

delete from view
insert into view
*/

create view vmDemo
as 
select * from students

select * from vmDemo
Insert into vmDemo(roll_no,FirstName,LastName)values('23','komal','mali')
delete from vmDemo where roll_no = 20
update vmDemo set FirstName = 'puja' where roll_no= 1

--------------------------------------------------------------
--  View with WITH CHECK OPTION (vmCheckOption)

create view vmCheckOption as
select * from students where LastName='mali'
with check option

select * from vmCheckOption

insert into vmCheckOption(roll_no,FirstName,LastName) values('21','nilesh','mali');