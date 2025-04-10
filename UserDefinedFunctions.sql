
/****************  User Defined Function **************

1.scalar-valued functions -- > return a single value
2.table-valued function	-->  return rows of data.
	Inline Table-Valued Function --> Returns a table without using BEGIN...END.
	Multi-Statement Table-Valued Function --> Uses BEGIN...END and can store intermediate results.

user-defined functions help you simplify your development by encapsulating complex
business logic and make them available for reuse in every query.

************************************************************************


1) scalar-valued functions
--  scalar function takes one or more parameters and returns a single value.
help you simplify your code. 
For example, you may have a complex calculation that appears in many queries.
Instead of including the formula in every query, you can create a scalar function that 
encapsulates the formula and uses it in each query.

Syntax 
CREATE FUNCTION [schema_name.]function_name (parameter_list)
RETURNS data_type AS
BEGIN
    statements
    RETURN value
END
*/

Use BikeStores

-- Ex 1) creates a function that calculates the net sales based on the quantity, list price, and discount:

create FUNCTION sales.udfNetSale(
	@quantity INT,
	@list_price dec(18,2),
	@discount dec(5,2)
	)
Returns dec(18,2)
As
Begin
	return  @quantity * @list_price  * (1- @discount);
End;

-- Use
SELECT sales.udfNetSale(10,2,0.1) as net_sale;
	-- OR --

SELECT order_id, SUM(sales.udfNetSale(quantity, list_price, discount)) net_amount
FROM sales.order_items
GROUP BY order_id
ORDER BY net_amount DESC;
		-------------------------------

-- Ex - 2 Calculate Employee Bonus
CREATE FUNCTION udfCalculateBonus(
    @salary DECIMAL(18,2),
    @bonusPercentage DECIMAL(5,2))

RETURNS DECIMAL(18,2)
AS
BEGIN
    RETURN @salary * (@bonusPercentage / 100);
END;

-- use 
SELECT dbo.udfCalculateBonus(50000, 10) AS BonusAmount;  -- Output: 5000.00
	-----------------------------------------------------------------------

-- Ex- 3 Get Employee Full Name
CREATE FUNCTION udfGetFullName(
    @firstName VARCHAR(50),
    @lastName VARCHAR(50)
)
RETURNS VARCHAR(100)
AS
BEGIN
	Declare @fullName varchar(60);
	set @fullName =@firstName + ' ' + @lastName;
	return @fullName
   
   -- RETURN @firstName + ' ' + @lastName; -- direct return full , not need to use declare and set 
END;

SELECT  dbo.udfGetFullName('puja','borse')




	-----------------------------------------------------------------------
--Ex 4- Add two digit 
CREATE FUNCTION AddDigit(@num1 int , @num2 int)
RETURNS INT
AS
BEGIN 
DECLARE @result int;
SET @result = @num1 + @num2;
RETURN @result
END

SELECT  dbo.AddDigit(10,20)
-----------------------------------------------------------------------
---Ex 5:  get total marks of students 
create function GetTotal(@RollNo int)
returns int

as
begin 
declare @result int;
select @result = (Science + Math +Eng) from student_marks where RollNo = @RollNo;
 
 return @result 
 END

 select RollNo,science,math,eng,dbo.GetTotal(RollNo) as  Total from student_marks


 -----------------------------------------------
--get averge 
create function GetAvg(@RollNo int)
returns int

as
begin 
declare @result int;
select @result = (science + Math +Eng)/3 from student_marks where RollNo = @RollNo;
 
 return @result 
 END

 select RollNo,science,math,eng,dbo.GetTotal(RollNo) as  Total, 
 dbo.GetAvg(RollNo) as Averge from student_marks





---***********************************************************************************

-- Table-valued function -->  return rows of data.
	-- Inline Table-Valued Function

-- ex 1) find customer
Create or Alter function udfFindCustomer(
	@customer_id int)
returns table 
as
return (select customer_id , first_name,email from sales.customers
		where customer_id = @customer_id);

SELECT * FROM udfFindCustomer(2);


-------------------------------------------------------
use BikeStores

-- Ex 2 list of products including product name, model year and the list price for a specific model year:
CREATE FUNCTION udfProductInYear (
    @model_year INT
)
RETURNS TABLE
AS
RETURN
    SELECT 
        product_name,
        model_year,
        list_price
    FROM
        production.products
    WHERE
        model_year = @model_year;


select * from udfProductInYear(2017)
	-----------------------------
--Ex 3 Modifying a table-valued function
ALTER FUNCTION udfProductInYear (
    @start_year INT,
    @end_year INT)

RETURNS TABLE
AS
RETURN
    SELECT 
        product_name,
        model_year,
        list_price
    FROM
        production.products
    WHERE
        model_year BETWEEN @start_year AND @end_year


-- use 
SELECT product_name,model_year,list_price
FROM udfProductInYear(2017,2018)
ORDER BY product_name;

	-----------------------------
-- Ex:4  get student list from table 
create function GetStudentList(@total int)
Returns TABLE
AS 
return select * from Student_Marks Where (Science + Math + Eng) > @total;

 select * from dbo.GetStudentList(5)
	-----------------------------



	-----------------------------
	-----------------------------
	-----------------------------
	-----------------------------















----************************************************************************

-- Multi-Statement Table-Valued Function
-- Ex-1) 

CREATE FUNCTION udfContacts()
    RETURNS @contacts TABLE (
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        email VARCHAR(255),
        phone VARCHAR(25),
        contact_type VARCHAR(20))
AS
BEGIN
    INSERT INTO @contacts
    SELECT first_name,last_name,email,phone,'Staff'
    FROM sales.staffs;

    INSERT INTO @contacts
    SELECT first_name,last_name,email,phone,'Customer'
    FROM sales.customers;
    RETURN;
END;


SELECT * FROM udfContacts();

---------------------------------------------------
create function MultiStatemnetGetAllStudents(@RollNo INT)
returns @Marksheet table(StName varchar(50), RollNo INT, Eng INT, Math INT, Sci INT, Average Decimal(4,2))

AS
Begin 
Declare @Per decimal(4,2);
Declare @StName varchar(100);

select @StName = FirstName from students where roll_no =  @RollNo
select @Per = ((Eng + Math + Science)/3) from Student_marks where RollNo = @RollNo

Insert Into @Marksheet (StName , RollNo,Eng , Math , Sci,Average)
select @StName,RollNo,Eng,Math,Science,@Per from Student_marks where RollNo = @RollNo

return
End