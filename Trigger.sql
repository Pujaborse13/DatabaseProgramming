
use PracticeDatabase
CREATE TABLE Employee_Data (
    Emp_ID INT  Identity(1,1) PRIMARY KEY, 
    Emp_Name VARCHAR(100)not null, 
    Emp_Sal DECIMAL(10,2)not null, 
    Emp_Dob DATETIME not null, 
    Emp_experience INT not null, 
    record_datetime DATETIME not null
);

-----------------------------------------
-- after insert trigger
create trigger dbo.trgAfterInsert on dbo.Employee_Data
after insert
as
declare @emp_dob varchar(20);
declare @Age INT;
declare @Emp_Experience INT;

select @emp_dob =i.Emp_Dob from inserted i;
select @Emp_Experience = i.Emp_Experience from inserted i;

-- Employee's age must bot above 25 years 
SET @Age = year(GetDate()) - year(@emp_dob);

if @Age > 25
	begin
		print 'not Eligible : age is greater than 25'
		Rollback
	END

else if @Emp_Experience < 5
	begin 
		print 'not eligible : Experience is less than 5'
		rollback
	end

else
	begin
	print 'Employee details inserted sucessfully';
	End


Insert into Employee_Data(Emp_Name, Emp_Sal,Emp_Dob,Emp_Experience,record_datetime)
values('Smith',5000,'2000-01-03',6,GetDate())

select * from Employee_Data

-------------------------------------------
--after update trigger
-- create table to store updated values in table 
 create table dbo.EmployeeHistory
(Emp_ID int not null,
 field_name varchar(100) not null,
 old_name varchar(100) not null,
 new_value varchar(100) not null,
Record_DateTime datetime  not null);

select * from EmployeeHistory

-- create trigger to store updation history 

Create trigger dbo.trAfterUpdate ON dbo.Employee_Data
after Update
as
declare @emp_id int;
declare @emp_name varchar(100);
declare @old_emp_name varchar(100);
declare @emp_sal decimal(10,2);
declare @old_emp_sal decimal(10,2);

select @emp_id = i.Emp_id from inserted i;
select @emp_name = i.Emp_Name from inserted i ;
select @old_emp_name = i.Emp_Name from deleted i;
select @emp_sal = i.Emp_sal from inserted i;
select @old_emp_sal = i.Emp_sal from deleted i;

if update(Emp_Name)
begin 
	insert into EmployeeHistory(emp_id, field_name, old_value, new_value,Record_DateTime)
	values(@emp_id, 'Emp_Name',@old_emp_name, @emp_name,getdate())
end

if update(Emp_sal)
begin 
	insert into EmployeeHistory(emp_id, field_name, old_value, new_value,Record_DateTime)
	values(@emp_id, 'Emp_sal',@old_emp_sal, @emp_sal,getdate())
end





--before update
select * from Employee_Data
update Employee_Data set emp_name = 'puja' where emp_id =4;

-- after update
select * from Employee_data
select * from EmployeeHistory
---------------------------------------------------------
-- after delete 
CREATE TABLE EmployeeBackup (
    Emp_ID INT not null, 
    Emp_Name VARCHAR(100)not null, 
    Emp_Sal DECIMAL(10,2)not null, 
    Emp_Dob DATETIME not null, 
    Emp_Experience INT not null, 
    Record_datetime DATETIME not null
);



create trigger dbo.trAfterDelete on dbo.Employee_Data
after delete
as 
	declare @emp_id int;
	declare @emp_name varchar(100);
	declare @emp_sal decimal(10,2);
	declare @emp_dob varchar(20);
	declare @Age int;
	declare @Emp_Experience int;;

	select @emp_id = i.emp_id from deleted i;
	select @emp_name = i.emp_Name from deleted i ;
	select @emp_sal = i.Emp_sal from deleted i;
	select @emp_dob = i.Emp_DOB from deleted i;
	select @Emp_Experience = i.Emp_experience from deleted i;

insert into EmployeeBackup(emp_id,emp_name,emp_sal,emp_dob,emp_experience,record_datetime)
values(@emp_id,@emp_name,@emp_sal,@emp_dob,@Emp_Experience,GETDATE())
print 'Employee details inserted sucessfully';


--before delete
select * from Employee_Data
select * from EmployeeBackup

delete from Employee_Data where Emp_ID = 4;

-- after update
select * from Employee_data
select * from EmployeeBackup

