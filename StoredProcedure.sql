

--******************** Store Procedure ******************* 
USE OrganizationData
GO

-- 1. Create Procedure  : to get employees with salary less than 50000

CREATE PROCEDURE spRangeSalary    
AS
BEGIN
    SELECT * FROM Employee WHERE Emp_Salary < 50000;
END;

GO


-- Call Procedure by Name (Different ways)
spRangeSalary;       -- 1
EXECUTE spRangeSalary;  -- 2
EXEC spRangeSalary;     -- 3

-----------------------------------------------------------------------
-- Mutiple statements 

Alter PROCEDURE spRangeSalaryMaxMin
AS
BEGIN
    -- Employees with salary less than 50000
    SELECT * FROM Employee WHERE Emp_Salary < 50000;

    -- Employees with salary greater than 50000
	SELECT * FROM Employee WHERE Emp_Salary > 50000;
END;

Go

EXEC spRangeSalaryMaxMin;

----------------------------------------
-- 2 Drop Procedure

DROP PROCEDURE spRangeSalry;

DROP PROCEDURE spRangeSalryMaxMin;



-------------------------------
/*-- Dynamic Procedure
Parameters in Stored Procedures:
		1.Input Parameter	Used to pass data into procedure
		2.Output Parameter	Used to return data from procedure
		3.Default Parameter	Parameter with default value if not supplied during call
*/



-- 1. Input Parameter
CREATE PROC spDeparList
@dept_name varchar(30), 
@emp_name varchar(100)
AS
BEGIN	
	Select * from employee where   Emp_Name=@emp_name;
	Select * from employee where   Emp_Department =@dept_name;
END


execute spDeparList 'Puja Borse','HR' -- sequence is important in this case
execute spDeparList @dept_name='HR', @emp_name='Puja Borse'; -- sequence is not important 

--------------****************************************************************----------------
--2.Output Parameter

create PROC spAddDigit
@Num1 INT,
@Num2 INT,
@Result INT OUTPUT
--For Encryption
with Encryption

As
BEGIN
	SET @Result = @Num1 + @Num2
END


-- Output 
Declare @EId INT
EXEC spAddDigit 2,2,@EId OUTPUT
SELECT @Eid; ---gives output in table or column


--Store procedure security with encryption 

sp_helptext spAddDigit










--Ex 2 :Create a procedure with output parameter

CREATE PROCEDURE spGetEmpSalary
    @emp_name VARCHAR(100),
    @emp_salary INT OUTPUT   -- Output Parameter
AS
BEGIN
    -- Fetch salary of given employee
    SELECT @emp_salary = Emp_Salary FROM Employee WHERE Emp_Name = @emp_name;
END;




-- Declare a variable to hold output
DECLARE @salary INT;
-- Execute the procedure and fetch salary
EXEC spGetEmpSalary 
    @emp_name = 'Puja Borse', 
    @emp_salary = @salary OUTPUT;

-- Print the output salary
--select @salary
PRINT 'Salary of Puja Borse is: ' + CAST(@salary AS VARCHAR);


-------------------------------------------------------------------------------

-- Create Procedure with Multiple Output Parameters
		CREATE PROCEDURE spEmpDeptDetails
		@emp_name VARCHAR(100),
		@emp_salary INT OUTPUT,
		@dept_name VARCHAR(50) OUTPUT,
		@dept_emp_count INT OUTPUT
	AS
	BEGIN
		-- Get salary of employee
		SELECT @emp_salary = Emp_Salary FROM Employee WHERE Emp_Name = @emp_name;

		-- Get department name of employee
		SELECT @dept_name = Emp_Department FROM Employee WHERE Emp_Name = @emp_name;

		-- Get count of employees in same department
		SELECT @dept_emp_count = COUNT(*) FROM Employee WHERE Emp_Department = @dept_name;
	END;
	GO


--Execute the Procedure and Display All Outputs
		DECLARE @salary INT, @department VARCHAR(50), @empCount INT;

		-- Execute procedure
		EXEC spEmpDeptDetails 
			@emp_name = 'Puja Borse',
			@emp_salary = @salary OUTPUT,
			@dept_name = @department OUTPUT,
			@dept_emp_count = @empCount OUTPUT;

		-- Print the output values
		PRINT 'Salary: ' + CAST(@salary AS VARCHAR);
		PRINT 'Department: ' + @department;
		PRINT 'Number of Employees in Department: ' + CAST(@empCount AS VARCHAR);


--------------****************************************************************----------------
--3.Default Parameter
-- Procedure with default value parameters

CREATE PROCEDURE spEmpByDept
    @dept_name VARCHAR(30) = 'HR'   -- Default department as HR
AS
BEGIN
    SELECT * FROM Employee WHERE Emp_Department = @dept_name;
END;
GO

-- Call without parameter (will use 'HR')
EXEC spEmpByDept;

-- Call with specific parameter
EXEC spEmpByDept @dept_name = 'Sales';


/*----------------------------1. Banking: Withdrawal with Balance Check (No Logging)---------------------------------------------

Problem:
Implement a stored procedure to handle bank account withdrawals. Ensure:
The withdrawal amount does not exceed the account balance.
Raise errors for insufficient funds or non-existent accounts.

*/

USE PracticeDatabase
CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY IDENTITY(1,1),  -- Auto-increment Account ID
    AccountHolderName NVARCHAR(100) NOT NULL,
    Balance DECIMAL(18, 2) NOT NULL CHECK (Balance >= 0)  -- Non-negative balance
);

INSERT INTO Accounts (AccountHolderName, Balance)
VALUES
('Puja Borse', 5000.00),
('Rahul Sharma', 10000.00),
('Prathmesh Pawar', 40000.00),
('Komal Patil', 50000.00),
('Disha Sharma', 55000.00),
('Rohit Desle', 65000.00),
('Sneha Patil', 3000.00);


--Create Procedure
create procedure WithdrawAmount
	@AccountID INT,
	@Amount decimal(10,2)

AS
Begin
	Begin Try
	--Check if Account exists
	if not exists (select 1 from Accounts WHERE AccountID = AccountID)
	BEGIN
		THROW 50004,'Account not found',1;
	END

	--CHECK BALANCE 
	DECLARE @Balance DECIMAL(10,2);
	SELECT @Balance = Balance FROM Accounts WHERE AccountID = @AccountID;

	IF @Balance < @Amount
	BEGIN 
		THROW 50005, 'Insufficient funds.', 1;
	END

	 -- Deduct the amount
        UPDATE Accounts
        SET Balance = Balance - @Amount
        WHERE AccountID = @AccountID;


print 'Withdrawl Successful. remaining balance :' + cast(@Balance - @Amount as Nvarchar(50));
End TRY

BEGIN CATCH
	-- handle errors
	declare @ErrorMessage Nvarchar(4000), @ErrorSeverity INT , @ErrorState INT;
	select 
	@ErrorMessage = ERROR_MESSAGE(),
	@ErrorSeverity = ERROR_SEVERITY(),
    @ErrorState = ERROR_STATE();

	--rethrow the rror
	 THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;


-- Withdraw amount (Valid Case)
EXEC WithdrawAmount @AccountID = 1, @Amount = 1000.00;

-- Withdraw more than balance (Should throw Insufficient funds error)
EXEC WithdrawAmount @AccountID = 3, @Amount = 5000.00;

-- Withdraw from non-existent account (Should throw Account not found error)
EXEC WithdrawAmount @AccountID = 99, @Amount = 500.00;
	


----------------------------------2. Inventory Management: Stock Update --------------------------------------------------
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),  -- Auto-increment Product ID
    ProductName VARCHAR(100) NOT NULL,
    Stock INT NOT NULL,                      -- Quantity available in stock
    Price DECIMAL(10, 2) NOT NULL            -- Price per product
);


INSERT INTO Products (ProductName, Stock, Price)
VALUES 
('Laptop', 20, 75000.00),
('Mouse', 100, 500.00),
('Keyboard', 50, 1500.00),
('Monitor', 30, 12000.00);




CREATE PROCEDURE UpdateStock
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    BEGIN TRY
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
        BEGIN
            THROW 50006, 'Product not found.', 1;
        END

        -- Check if sufficient stock is available
        DECLARE @CurrentStock INT;
        SELECT @CurrentStock = Stock FROM Products WHERE ProductID = @ProductID;

        IF @CurrentStock < @Quantity
        BEGIN
            THROW 50007, 'Insufficient stock.', 1;
        END

        -- Update stock
        UPDATE Products
        SET Stock = Stock - @Quantity
        WHERE ProductID = @ProductID;

        PRINT 'Stock updated successfully. Remaining Stock: ' + CAST(@CurrentStock - @Quantity AS NVARCHAR(50));
    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Re-throw the error
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;

-- Valid Stock Update (Successful Case)
EXEC UpdateStock @ProductID = 2, @Quantity = 10;


--Product Not Found (Error Case)
EXEC UpdateStock @ProductID = 99, @Quantity = 5;

--Insufficient Stock (Error Case)
EXEC UpdateStock @ProductID = 1, @Quantity = 50;



---------------------------3.E-commerce: Apply Discount Code  --------------------------------------------------

-- Create Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),     -- Auto-increment Order ID
    CustomerName VARCHAR(100) NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL        -- Total order amount before discount
);
GO

-- Create DiscountCodes Table
CREATE TABLE DiscountCodes (
    Code NVARCHAR(50) PRIMARY KEY,             -- Unique Discount Code
    DiscountAmount DECIMAL(10, 2) NOT NULL,   -- Discount amount
    ExpiryDate DATE NOT NULL                  -- Validity of discount
);
GO

-- 5. Insert Sample Orders
INSERT INTO Orders (CustomerName, TotalAmount)
VALUES 
('Puja Borse', 1000.00),
('John Doe', 500.00),
('Alice Smith', 1500.00);
GO

-- 6. Insert Sample Discount Codes
INSERT INTO DiscountCodes (Code, DiscountAmount, ExpiryDate)
VALUES
('DISC10', 100.00, '2025-12-31'),
('BIGSALE', 500.00, '2024-12-31'),
('EXPIRED', 200.00, '2023-12-31'); -- Expired code for testing
GO

-- 7. Create Stored Procedure for Applying Discount
CREATE PROCEDURE ApplyDiscount
    @OrderID INT,
    @DiscountCode NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Check if order exists
        IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
        BEGIN
            THROW 50008, 'Order not found.', 1;
        END;

        -- Check if discount code is valid and not expired
        IF NOT EXISTS (SELECT 1 FROM DiscountCodes WHERE Code = @DiscountCode AND ExpiryDate >= GETDATE())
        BEGIN
            THROW 50009, 'Invalid or expired discount code.', 1;
        END;

        -- Fetch order total and discount value
        DECLARE @OrderTotal DECIMAL(10, 2), @DiscountValue DECIMAL(10, 2);
        SELECT @OrderTotal = TotalAmount FROM Orders WHERE OrderID = @OrderID;
        SELECT @DiscountValue = DiscountAmount FROM DiscountCodes WHERE Code = @DiscountCode;

        -- Check if discount amount is greater than order total
        IF @DiscountValue > @OrderTotal
        BEGIN
            THROW 50010, 'Discount value exceeds the order total.', 1;
        END;

        -- Apply discount to the order
        UPDATE Orders
        SET TotalAmount = TotalAmount - @DiscountValue
        WHERE OrderID = @OrderID;

        -- Success message
        PRINT 'Discount applied successfully. New Total: ' + CAST(@OrderTotal - @DiscountValue AS NVARCHAR(50));

    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Rethrow error
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;
GO



--Valid Discount Application (Success Case)
EXEC ApplyDiscount @OrderID = 1, @DiscountCode = 'DISC10';

--Order Not Found (Error Case)
EXEC ApplyDiscount @OrderID = 99, @DiscountCode = 'DISC10';

-- Invalid or Expired Discount Code (Error Case)
EXEC ApplyDiscount @OrderID = 1, @DiscountCode = 'EXPIRED';

--Discount Value Exceeds Order Total (Error Case)
EXEC ApplyDiscount @OrderID = 2, @DiscountCode = 'BIGSALE';


-------------------------------------------

use PracticeDatabase

select * from Employee

create procedure UpdateSalary
	@Id Int,
	@Salary Int,
	@dept varchar(30)

as 
begin 

	begin try 
	if not exists(select 1 from Employee where Id = @Id)
	begin 
		throw 50007, 'id not exist.', 1
		
	end

	update Employee
	set Salary =  @Salary, dept = @dept
	where Id = @Id

PRINT 'Salary updated successfully: ' + CONVERT(NVARCHAR, @Salary) + ', Department: ' + @dept;
end try

begin catch
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        THROW;
    END CATCH
END;

EXEC UpdateSalary @Id = 2, @Salary= 66666 , @dept = 'testing';






----------------------------------
CREATE PROCEDURE UpdateStock
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    BEGIN TRY
        -- Check if product exists
        IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
        BEGIN
            THROW 50006, 'Product not found.', 1;
        END

        -- Check if sufficient stock is available
        DECLARE @CurrentStock INT;
        SELECT @CurrentStock = Stock FROM Products WHERE ProductID = @ProductID;

        IF @CurrentStock < @Quantity
        BEGIN
            THROW 50007, 'Insufficient stock.', 1;
        END

        -- Update stock
        UPDATE Products
        SET Stock = Stock - @Quantity
        WHERE ProductID = @ProductID;

        PRINT 'Stock updated successfully. Remaining Stock: ' + CAST(@CurrentStock - @Quantity AS NVARCHAR(50));
    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Re-throw the error
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;

-- Valid Stock Update (Successful Case)
EXEC UpdateStock @ProductID = 2, @Quantity = 10;
---------------------------------------------------------------------------------------------------