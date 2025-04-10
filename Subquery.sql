
/**************** Subquery ********************
Single-row Subquery - Returns a single value.
Multi-row Subquery - Returns multiple values.
Correlated Subquery - Uses outer query data in the subquery.
Nested Subquery - Subquery inside another subquery.
Subquery in FROM clause - Used as a temporary table.

Key Notes
1) Subquery Types:
	Scalar Subquery: Returns a single value.
	Multi-Row Subquery: Returns multiple rows.
	Multi-Column Subquery: Returns multiple columns.
2)Subquery Placement:
	Subqueries can be used in SELECT, FROM, WHERE, and HAVING clauses

1. Subquery with SELECT
A subquery is used to filter or fetch specific data.
Example: Fetch employees with a salary greater than the average salary
*/


USE BikeStores

-- 1. find the sales orders of the customers located in New York
select order_id ,order_date , customer_id
from sales.orders
where
	customer_id IN (select customer_id from sales.customers where city = 'New York')
order by order_date DESC;


------------------------------------------------
-- Nesting subquery
SELECT product_name,list_price
FROM production.products
WHERE
    list_price > (SELECT AVG (list_price)
				   FROM	production.products
					WHERE brand_id IN (SELECT brand_id
										 FROM production.brands
										 WHERE brand_name = 'Strider' OR brand_name = 'Trek')
					)
ORDER BY
    list_price;

	--------------------------------------------------------------------
/*
--> SQL Server subquery types
You can use a subquery in many places:
	In place of an expression
	With IN or NOT IN
	With ANY or ALL
	With EXISTS or NOT EXISTS
	In UPDATE, DELETE, or INSERT statement
	In the FROM clause	

*/

-- select 
SELECT order_id, order_date,
			(SELECT MAX (list_price)
			FROM sales.order_items i
			WHERE i.order_id = o.order_id) 
			AS max_list_price
FROM sales.orders o
order by order_date desc;


-- In
SELECT product_id, product_name
FROM production.products
	WHERE category_id IN ( SELECT category_id 
							FROM production.categories
							WHERE category_name = 'Mountain Bikes' OR category_name = 'Road Bikes'
    );

	-----------------------------------------------
	---ANY
SELECT  product_name, list_price
FROM  production.products
WHERE list_price >= ANY (SELECT AVG (list_price)
						 FROM production.products GROUP BY brand_id)


--------------------------
-- ALL
SELECT  product_name, list_price
FROM  production.products
WHERE list_price >= ALL (SELECT AVG (list_price)
						 FROM production.products GROUP BY brand_id)

-----------------------------
-- EXISTS or NOT EXISTS

-- query finds the customers who bought products in 2017:
SELECT customer_id,first_name,last_name,city
FROM sales.customers c
WHERE
    EXISTS (SELECT customer_id
			FROM sales.orders o
			WHERE o.customer_id = c.customer_id AND YEAR (order_date) = 2017
			)
ORDER BY
    first_name,
    last_name;

--- you can find the customers who did not buy any products in 2017.

SELECT customer_id,first_name,last_name,city
FROM sales.customers c
WHERE
    NOT EXISTS (SELECT customer_id
			FROM sales.orders o
			WHERE o.customer_id = c.customer_id AND YEAR (order_date) = 2017
			)
ORDER BY
    first_name,
    last_name;


--- FROM clause
--find the average of the sum of orders of all sales staff.
--1 first find the number of orders by staff:
SELECT  staff_id, COUNT(order_id) order_count
FROM  sales.orders
GROUP BY staff_id;

--2 Then, you can apply the AVG() function to this result set.
SELECT 
   AVG(order_count) average_order_count_by_staff
FROM
(
    SELECT 
	staff_id, 
        COUNT(order_id) order_count
    FROM 
	sales.orders
    GROUP BY 
	staff_id
) t;


/*------------------------------------------------------------------------------------------------------------------------------------------------
1. Subquery with SELECT
A subquery is used to filter or fetch specific data.
Example: Fetch employees with a salary greater than the average salary
*/
use PracticeDatabase

select Id , Name , Salary , dept 
From Employee 
	where  salary > (select AVG(salary) from Employee)



/*------------------------------------------------------------------------------------------------------------------------------------------------
2. Subquery with INSERT
A subquery can provide data for an INSERT statement.
Example: Insert employees from another department into a temporary table
*/

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50) NOT NULL
);
INSERT INTO Departments(DepartmentID, DepartmentName) 
VALUES (1, 'Sales'), (2, 'HR'), (3, 'IT');
INSERT INTO Employees (EmployeeID, EmployeeName, DepartmentID) 
VALUES 
(101, 'John Doe', 1), 
(102, 'Jane Smith', 1), 
(103, 'Alice Johnson', 2), 
(104, 'Bob Brown', 3);

create table TempEmployee (EmployeeID int , EmployeeName varchar(30), DeptName varchar(50));

INSERT INTO TempEmployee(EmployeeID, EmployeeName, DeptName , DepartmentID)
SELECT Id, Name, dept ,DepartmentID 
FROM Employee
WHERE DepartmentID = (SELECT DepartmentID FROM Departments WHERE DepartmentName = 'HR');

select * from TempEmployee



/*------------------------------------------------------------------------------------------------
3. Subquery with UPDATE
A subquery can be used to compute new values for an UPDATE.
Example: Update employee salaries based on the department average
*/


update Employee
set Salary = Salary + 1000
where DepartmentID In (Select DepartmentID  from Departments where DepartmentName = 'HR');

select * from Employee





/*------------------------------------------------------------------------------------------------
4. Subquery with DELETE
A subquery can specify which rows to delete.
Example: Delete customers who have not placed any orders

*/
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL
);

INSERT INTO Customers (CustomerID, CustomerName)
VALUES 
(1, 'Puja Borse'),
(2, 'John Doe'),
(3, 'Alice Smith'),
(4, 'David Miller'); -- This customer has not placed any orders


DELETE FROM Customers
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders);


use PracticeDatabase

/*-------------------------------------------------------------------------------------------------------
5. Correlated Subquery
A correlated subquery refers to columns from the outer query, making it re-evaluate for each row of the outer query.
Example: Fetch employees with a salary higher than the average salary in their department
*/

SELECT ID,Name, Salary, DepartmentID
FROM Employee E1
WHERE Salary > (SELECT AVG(Salary)
                FROM Employee E2
                WHERE E1.DepartmentID = E2.DepartmentID);


-----------------------------------------