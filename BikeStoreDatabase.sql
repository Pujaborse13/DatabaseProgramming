

-- Create Database
CREATE DATABASE BikeStores

-- using that database
USE BikeStores

-- create schemas production and sales
CREATE SCHEMA production;
Go

CREATE SCHEMA sales;
Go


-- create tables
CREATE TABLE production.categories (
	category_id INT IDENTITY (1, 1) PRIMARY KEY,
	category_name VARCHAR (255) NOT NULL
);

CREATE TABLE production.brands (
	brand_id INT IDENTITY (1, 1) PRIMARY KEY,
	brand_name VARCHAR (255) NOT NULL
);

CREATE TABLE production.products (
	product_id INT IDENTITY (1, 1) PRIMARY KEY,
	product_name VARCHAR (255) NOT NULL,
	brand_id INT NOT NULL,
	category_id INT NOT NULL,
	model_year SMALLINT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	FOREIGN KEY (category_id) REFERENCES production.categories (category_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (brand_id) REFERENCES production.brands (brand_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE sales.customers (
	customer_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (255) NOT NULL,
	last_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255) NOT NULL,
	street VARCHAR (255),
	city VARCHAR (50),
	state VARCHAR (25),
	zip_code VARCHAR (5)
);

CREATE TABLE sales.stores (
	store_id INT IDENTITY (1, 1) PRIMARY KEY,
	store_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255),
	street VARCHAR (255),
	city VARCHAR (255),
	state VARCHAR (10),
	zip_code VARCHAR (5)
);

CREATE TABLE sales.staffs (
	staff_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (50) NOT NULL,
	last_name VARCHAR (50) NOT NULL,
	email VARCHAR (255) NOT NULL UNIQUE,
	phone VARCHAR (25),
	active tinyint NOT NULL,
	store_id INT NOT NULL,
	manager_id INT,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (manager_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE sales.orders (
	order_id INT IDENTITY (1, 1) PRIMARY KEY,
	customer_id INT,
	order_status tinyint NOT NULL,
	-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed
	order_date DATE NOT NULL,
	required_date DATE NOT NULL,
	shipped_date DATE,
	store_id INT NOT NULL,
	staff_id INT NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES sales.customers (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (staff_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE sales.order_items (
	order_id INT,
	item_id INT,
	product_id INT NOT NULL,
	quantity INT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	discount DECIMAL (4, 2) NOT NULL DEFAULT 0,
	PRIMARY KEY (order_id, item_id),
	FOREIGN KEY (order_id) REFERENCES sales.orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE production.stocks (
	store_id INT,
	product_id INT,
	quantity INT,
	PRIMARY KEY (store_id, product_id),
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);



-- Queries 
---------------- Section 1. Querying data -----------------------
/* 1. Select 

-- SELECT statement to retrieve the first name, last name, and email of all customers:
-- result of a query is often called a result set.
*/

SELECT first_name, last_name, email
	FROM sales.customers;

SELECT * FROM sales.customers;

/* ----------------- Section 2. Sorting data -----------------------

-- ORDER BY clause
The ORDER BY clause allows you to sort the result set of a query by one or more columns.
use ASC or DESC keyword.
ASC keyword sorts rows from low to high
DESC keyword sorts the rows from high to low.


--   defaults used clause : ASC
SELECT
    select_list
FROM
    table_name
ORDER BY 
    column_name | expression [ASC | DESC ];


*/

SELECT first_name,last_name
	FROM sales.customers
ORDER BY first_name 


SELECT first_name,last_name
	FROM sales.customers
ORDER BY first_name ASC

SELECT first_name,last_name
	FROM sales.customers
ORDER BY first_name DESC  -- descending order


-- Sort a result set by multiple columns
SELECT
    city,
    first_name,
    last_name
FROM
    sales.customers
ORDER BY  
    city,
    first_name;

-- Sort a result set by multiple columns in different orders
SELECT
    city,
    first_name,
    last_name
FROM
    sales.customers
ORDER BY  
    city DESC,
    first_name ASC;

--Sort a result set by a column that is not in the select list
SELECT
    first_name,
    last_name
FROM
    sales.customers
ORDER BY  
    city;
-----------------------
SELECT
    city,
    first_name,
    last_name
FROM
    sales.customers
ORDER BY
    state;
	
--  Sort a result set by an expression

SELECT
    city,
    first_name,
    last_name
FROM
    sales.customers
ORDER BY
    LEN(city) DESC;  --LEN() function returns the number of characters in a string.

/*
-- Sort by ordinal positions of columns
sort the result set based on the ordinal positions of columns that 
appear in the select list.

following statement sorts the customers by first and last names. But instead 
of specifying the column names explicitly, it uses the ordinal positions of the columns:
*/

SELECT
	first_name, --1
    last_name   --2
FROM
    sales.customers
ORDER BY
    1 DESC,
    2 DESC;

/* /*****************************************************************************/
----------------------- Section 3. Limiting rows---------------------------------
--1. OFFSET FETCH : The OFFSET and FETCH clauses are options of the ORDER BY clause. 
					They allow you to limit the number of rows returned by a query.
- it's used for pagination, i.e., to retrieve a subset of rows
	from a query result, usually for displaying data page by page
	(like in web apps with "Next" and "Previous" buttons).

	syntax :	ORDER BY column_list [ASC |DESC]
				OFFSET offset_row_count {ROW | ROWS}
				FETCH {FIRST | NEXT} fetch_row_count {ROW | ROWS} ONLY

- OFFSET =  the number of rows to skip before starting to return rows from the query.
- offset_row_count =  constant, variable, or parameter that is greater or equal to zero
- FETCH = specifies the number of rows to return after the OFFSET clause has been processed.
- fetch_row_count = constant, variable, or scalar that is greater or equal to one.

 The OFFSET clause is mandatory, while the FETCH clause is optional. Additionally, FIRST and NEXT
 are synonyms and can be used interchangeably. Similarly, you can use ROW and ROWS interchangeably.

 Note :  you must use the OFFSET and FETCH clauses with the ORDER BY clause. Otherwise, you encounter an error.
*/


SELECT
    product_name,
    list_price
FROM
    production.products
ORDER BY
    list_price,
    product_name 
OFFSET 10 ROWS;  -- To skip the first 10 products and return the rest


-- 1) Using the SQL Server OFFSET FETCH
SELECT
    product_name,
    list_price
FROM
    production.products
ORDER BY
    list_price,
    product_name 
OFFSET 10 ROWS			 -- offset To skip the first 10 products 
FETCH NEXT 10 ROWS ONLY; -- fetch  select the next 10 products,

-- 2) Using the OFFSET FETCH clause to get the top N rows

SELECT product_name, list_price
	FROM production.products
ORDER BY list_price, product_name

OFFSET 0 ROWS  -- OFFSET FETCH clause to retrieve the top 10 most expensive products from the products table
FETCH NEXT 10 ROWS ONLY


/*
-- 2. SELECT TOP

SELECT TOP clause allows you to limit the rows or percentage of rows returned by a query. 
It is useful when you want to retrieve a specific number of rows from a large table.

syntax : 

				SELECT TOP (expression) [PERCENT]
					[WITH TIES]
				FROM 
					table_name
				ORDER BY 
					 column_name;

expression : TOP keyword is an expression that specifies the number of rows to be returned. 
			The expression is evaluated to a float value if PERCENT is used, otherwise, 
			it is converted to a BIGINT value.
PERCENT : The PERCENT keyword indicates that the query returns the first N percentage of rows, 
			where N is the result of the expression
WITH TIES: allows you to return additional rows with values that match those of the
			last row in the limited result set. Note that WITH TIES may result in more 
			rows being returned than specified in the expression.
*/

-- 1) Using SQL Server SELECT TOP with a constant value

		SELECT TOP 10
			product_name, 
			list_price
		FROM
			production.products
		ORDER BY 
			list_price DESC;
--------------------------------
SELECT TOP 2 product_id, product_name, list_price
FROM production.products
ORDER BY list_price DESC;

-- 2) Using SELECT TOP to return a percentage of rows
/*
The following example uses PERCENT to specify the number of products returned in the result set.

The production.products table has 321 rows. Therefore, one percent of 321 is a fraction value ( 3.21),
SQL Server rounds it up to the next whole number, which is four ( 4) in this case
*/
	SELECT TOP 1 PERCENT
		product_name, 
		list_price
	FROM
		production.products
	ORDER BY 
		list_price DESC;

SELECT TOP 40 PERCENT product_id, product_name, list_price
FROM production.products
ORDER BY list_price DESC;



------------------------------------


/*--WITH TIES

WITH TIES is used along with SELECT TOP to include additional rows that have the same value
as the last row in the TOP result based on the ORDER BY column.
It ensures that if multiple rows have the same value as the last row of the limited result set, 
all of them will be included.
It works only when ORDER BY is specified.

*/
-- 3) Using SELECT TOP WITH TIES to include rows that match


SELECT TOP 3 WITH TIES
    product_name, 
    list_price
FROM
    production.products
ORDER BY 
    list_price DESC;


SELECT TOP 2 WITH TIES product_id, product_name, list_price
FROM production.products
ORDER BY list_price DESC;


/****************************************************************************
------------------------------- Section 4. Filtering data -----------------------------

-- <1>. DISTINCT
-- SELECT DISTINCT clause to retrieve the distinct values from one or more columns.

syntax :

		SELECT 
		  DISTINCT column_name 
		FROM 
		  table_name;

*/
--1) Using the SELECT DISTINCT with one column
SELECT DISTINCT city  
FROM sales.customers 
ORDER BY city;

-- 2) Using SELECT DISTINCT with multiple columns

SELECT DISTINCT city, state 
	FROM sales.customers; 

--3) Using SELECT DISTINCT with NULL

SELECT DISTINCT phone 
FROM sales.customers 
ORDER BY phone;


/*
-- DISTINCT vs. GROUP BY
1.DISTINCT
	DISTINCT is used to remove duplicate rows from the result set.
	It gives unique combinations of the selected columns.
	Does not perform aggregation (like SUM, COUNT, etc.), only filters out duplicates.
DISTINCT = Unique rows based on the columns mentioned.

2.GROUP BY 
	it used to group rows that have the same values in specified columns.
	Often used with aggregate functions like COUNT(), SUM(), AVG(), etc.
	Helps in data aggregation & summarization.

GROUP BY = Grouping + Aggregation.

syntax :
		SELECT column1, AGG_FUNC(column2)
		FROM table_name
		GROUP BY column1;


Use DISTINCT when you want unique data only — no calculation.
Use GROUP BY when you want to group and calculate data (e.g., totals, averages).

*/

--Group Order By Clause
SELECT city, state, zip_code 
	FROM sales.customers 
GROUP BY city, state, zip_code 
ORDER BY city, state, zip_code


-- Distinct
SELECT 
  DISTINCT city, state, zip_code 
FROM 
  sales.customers;

  /*____________________________________________________________________________
  <2>. WHERE
  The WHERE clause is used to filter records that meet a specific condition.
  It is used in SELECT, UPDATE, DELETE statements to specify which rows should be affected.


  */

  -- 1) Using the WHERE clause with a simple equality operator
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    category_id = 1
ORDER BY
    list_price DESC;


-- 2) Using the WHERE clause with the AND operator
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    category_id = 1 AND model_year = 2018
ORDER BY
    list_price DESC;

--3) Using WHERE to filter rows using a comparison operator
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price > 300 AND model_year = 2018
ORDER BY
    list_price DESC;

-- 4) Using the WHERE clause to filter rows that meet any of two conditions
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price > 3000 OR model_year = 2018
ORDER BY
    list_price DESC;

-- 5) Using the WHERE clause to filter rows with the value between two values
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price BETWEEN 1899.00 AND 1999.99
ORDER BY
    list_price DESC;

--6) Using the WHERE clause to filter rows that have a value in a list of values
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price IN (299.99, 369.99, 489.99)
ORDER BY
    list_price DESC;

--7) Finding rows whose values contain a string

SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    product_name LIKE '%Cruiser%'
ORDER BY
    list_price;

/*
--<3> AND :
combine two Boolean expressions and return true if all expressions are true.

AND is used in SQL to combine two or more conditions in the WHERE clause.
All conditions must be TRUE for a row to be included in the result.

syntax :
SELECT column1, column2, ...
FROM table_name
WHERE condition1 AND condition2 AND ...;

*/

-- 1) Basic SQL Server AND operator example
SELECT 
* 
FROM 
  production.products 
WHERE 
  category_id = 1 
  AND list_price > 400 
ORDER BY 
  list_price DESC;

-- 2) Using multiple SQL Server AND operators
SELECT 
  * 
FROM 
  production.products 
WHERE 
  category_id = 1 
  AND list_price > 400 
  AND brand_id = 1 
ORDER BY 
  list_price DESC;

 
 --3) Using the AND operator with other logical operators
SELECT
    *
FROM
    production.products
WHERE
    brand_id = 1
OR brand_id = 2
AND list_price > 1000
ORDER BY
    brand_id DESC;
-----------------------------
SELECT
    *
FROM
    production.products
WHERE
    (brand_id = 1 OR brand_id = 2)
AND list_price > 1000
ORDER BY
    brand_id;

/*
-- <4> OR : combine two Boolean expressions and return true if either of the conditions is true.

OR is used to combine two or more conditions in a WHERE clause.
If any one condition is TRUE, the row will be included in the result.
At least one condition must be satisfied.

*/

--1) Basic SQL Server OR operator example
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price < 200
OR list_price > 6000
ORDER BY
    list_price;

-- 2) Using multiple OR operators
SELECT
    product_name,
    brand_id
FROM
    production.products
WHERE
    brand_id = 1
OR brand_id = 2
OR brand_id = 4
ORDER BY
    brand_id DESC;

-- OR --
SELECT
    product_name,
    brand_id
FROM
    production.products
WHERE
    brand_id IN (1, 2, 3)
ORDER BY
    brand_id DESC;


-- 3) Combining the OR operator with the AND operator

SELECT 
    product_name, 
    brand_id, 
    list_price
FROM 
    production.products
WHERE 
    brand_id = 1
      OR brand_id = 2
      AND list_price > 500
ORDER BY 
    brand_id DESC, 
    list_price;


	--OR--
	SELECT
    product_name,
    brand_id,
    list_price
FROM
    production.products
WHERE
    (brand_id = 1 OR brand_id = 2)
     AND list_price > 500
ORDER BY
    brand_id;

	/*-----------------------------------------------------------------------
 <5> IN :check whether a value matches any value in a list or a subquery.

The IN operator allows you to specify multiple values in a WHERE clause.
It helps simplify multiple OR conditions.
It returns rows where the column value matches any value in a list.

syntax:
SELECT column1, column2, ...
FROM table_name
WHERE column_name IN (value1, value2, value3, ...);
*/

--1) Basic SQL Server IN operator example

SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price IN (89.99, 109.99, 159.99)
ORDER BY
    list_price;


--Not IN
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price NOT IN (89.99, 109.99, 159.99)
ORDER BY
    list_price;


-- 2) Using SQL Server IN operator with a subquery example

SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    product_id IN (
        SELECT
            product_id
        FROM
            production.stocks
        WHERE
            store_id = 1 AND quantity >= 30
    )
ORDER BY
    product_name;


/*
<6> BETWEEN 

The BETWEEN operator is used to filter the result set within a certain range.
The range includes both the start and end values (inclusive).
You can use BETWEEN for numbers, text (alphabetical range), and dates.

syntax:

SELECT column1, column2, ...
FROM table_name
WHERE column_name BETWEEN value1 AND value2;

*/

-- A) Using SQL Server BETWEEN with numbers example

SELECT
    product_id,
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price BETWEEN 149.99 AND 199.99
ORDER BY
    list_price;

-------------------------------
SELECT
    product_id,
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price NOT BETWEEN 149.99 AND 199.99 -- NOT BETWEEN
ORDER BY
    list_price;


--B) Using SQL Server BETWEEN with dates example
SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM
    sales.orders
WHERE
    order_date BETWEEN '20170115' AND '20170117'
ORDER BY
    order_date;

/*
<7> LIKE  :check if a character string matches a specified pattern.

The LIKE operator is used in a WHERE clause to search for a specified pattern in a column.
It allows us to perform partial, flexible string matching.
Mostly used with wildcards:
% (percent): Zero, one, or many characters.
_ (underscore): Exactly one character.


*/

--1) Using the LIKE operator with the % wildcard examples

--- last name starts with the letter z
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE 'z%'  -- start with z
ORDER BY
    first_name;

----------- last name ends with the string er
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE '%er' -- end with er
ORDER BY
    first_name;


--- last name starts with the letter t and ends with the letter s
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE 't%s'
ORDER BY
    first_name;


-- 2) Using the LIKE operator with the _ (underscore) wildcard example

--customers where the second character is the letter u
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE '_u%'
ORDER BY
    first_name; 


--3) Using the LIKE operator with the [list of characters] wildcard example

-- returns the customers where the first character in the last name is Y or Z:
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE '[YZ]%'
ORDER BY
    last_name;


-- 4) Using the LIKE operator with the [character-character] wildcard example
-- The square brackets with a character range e.g., [A-C] represent a single character that 
  -- must be within a specified range.

SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE '[A-C]%'
ORDER BY
    first_name;

--5) Using the LIKE operator with the [^Character List or Range] wildcard example
/* The square brackets with a caret sign (^) followed by a range e.g., [^A-C] or 
character list e.g., [ABC] represent a single character that is not in the specified range 
or character list.*/


SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE '[^A-X]%'
ORDER BY
    last_name;

-- 6) Using the NOT LIKE operator example
-- find customers where the first character in the first name is not the letter A
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    first_name NOT LIKE 'A%'
ORDER BY
    first_name;

--7) Using the LIKE operator with ESCAPE example

-- First, create a new table for the demonstration:
-- Second, insert some rows into the sales.feedbacks table:
-- Third, query data from the sales.feedbacks table:
CREATE TABLE sales.feedbacks (
  feedback_id INT IDENTITY(1, 1) PRIMARY KEY, 
  comment VARCHAR(255) NOT NULL
);

INSERT INTO sales.feedbacks(comment)
VALUES('Can you give me 30% discount?'),
      ('May I get me 30USD off?'),
      ('Is this having 20% discount today?');

SELECT * FROM sales.feedbacks;

-- If you want to search for 30% in the comment column, you may come up with a query like this:
SELECT 
   feedback_id,
   comment
FROM 
   sales.feedbacks
WHERE 
   comment LIKE '%30%';


-- The query returns comments that contain 30% and 30 USD, which is not what we expected.
-- To address this issue, you can use the ESCAPE clause:

SELECT 
   feedback_id, 
   comment
FROM 
   sales.feedbacks
WHERE 
   comment LIKE '%30!%%' ESCAPE '!';

  
/*
<8> Column & table aliases : show you how to use column aliases to change the heading
	of the query output and table aliases to improve the readability of a query.

- A column alias is a temporary name assigned to a column or an expression in a query’s result set.
- Use a column alias to rename the output of a column or an expression to make it more meaningful.
- A table alias is a shorthand or temporary name assigned to a table in a query.
- Use table aliases when joining multiple tables or when referencing the same table more than once in a query.
	
A) column alias : Change how column names appear in the query result.
				  Make output user-friendly and readable.

B) Table Aliases :Shorten table names when writing queries.
					Make complex queries (like JOINs) easier to read and write.

*/

-- A) column alias

SELECT
    first_name + ' ' + last_name AS 'Full Name'
FROM
    sales.customers
ORDER BY
    first_name;
---------------------------------------
SELECT
    category_name 'Product Category'
FROM
    production.categories
ORDER BY
    category_name;  
-----------------------------------

-- B) Table : you can assign a table a temporary name with or without the AS keyword:
	-- table_name AS table_alias
	--  table_name table_alias

SELECT
    c.customer_id,
    first_name,
    last_name,
    order_id
FROM
    sales.customers c
INNER JOIN sales.orders o ON o.customer_id = c.customer_id;


/* c is the alias for the sales.customers table and o is the alias for the sales.orders table.
When you assign an alias to a table, you must use the alias to refer to the table column.
Otherwise, SQL Server will issue an error.
*/


/****************************************************************************
-------------------------- Section 5. Joining tables ------------------

Joins : A JOIN is used to combine rows from two or more tables based on a 
		related column between them (usually a foreign key).

Join Type					Description
1.INNER JOIN-->Returns records that have matching values in both tables.
2.LEFT JOIN-->Returns all records from the left table and matched records from the right table.
				Unmatched rows from the right side return NULL.
3.RIGHT JOIN-->Returns all records from the right table and matched records from the left table. 
				Unmatched rows from the left side return NULL.
4.FULL OUTER-->JOIN	Returns all records when there is a match in either left or right table. 
					If no match, returns NULL.
5.CROSS JOIN--> Returns Cartesian product (all combinations of rows).

6. Self Join --> A self join allows you to join a table to itself. 
		It helps query hierarchical data or compare rows within the same table.

*/
--First, create a new schema named hr
CREATE SCHEMA hr;
GO

--Second, create two new tables named candidates and employees in the hr schema:
CREATE TABLE hr.candidates(
    id INT PRIMARY KEY IDENTITY,
    fullname VARCHAR(100) NOT NULL
);

CREATE TABLE hr.employees(
    id INT PRIMARY KEY IDENTITY,
    fullname VARCHAR(100) NOT NULL
);

--left table
INSERT INTO 
    hr.candidates(fullname)
VALUES
    ('John Doe'),
    ('Lily Bush'),
    ('Peter Drucker'),
    ('Jane Doe');

-- right table
INSERT INTO 
    hr.employees(fullname)
VALUES
    ('John Doe'),
    ('Jane Doe'),
    ('Michael Scott'),
    ('Jack Sparrow');


-- 1.Inner Join
SELECT 
	c.id candidate_id,
	c.fullname candidate_name,
	e.id employees_id,
	e.fullname employees_name
FROM 
	hr.candidates c
	INNER JOIN hr.employees e  
	ON e.fullname = c.fullname;

-----------------------------------------
SELECT 
	c.id candidate_id,
	c.fullname candidate_name,
	e.id employees_id,
	e.fullname employees_name
FROM 
	hr.employees e
    INNER JOIN hr.candidates c
	ON e.fullname = c.fullname;


--2. Left Join
/*
Left join selects data starting from the left table and matching rows in the right table. 
The left join returns all rows from the left table and the matching rows from the right table.
If a row in the left table does not have a matching row in the right table, the columns of the right table will have nulls.
The left join is also known as the left outer join. The outer keyword is optional.
*/

SELECT 
	c.id candidate_id,
	c.fullname candidate_name,
	e.id employees_id,
	e.fullname employees_name
FROM
	hr.candidates c   -- mention table which returns all records
	LEFT JOIN hr.employees e   -- mention table which match records 
	ON e.fullname = c.fullname;


-- To get the rows that are available only in the left table but not in the right table, 
-- you add a WHERE clause to the above query:
SELECT  
    c.id candidate_id,
    c.fullname candidate_name,
    e.id employee_id,
    e.fullname employee_name
FROM 
    hr.candidates c
    LEFT JOIN hr.employees e 
        ON e.fullname = c.fullname
WHERE 
    e.id IS NULL;



-- 3 Right JOIN
/*  The right join returns a result set that contains all rows from the right table and
	the matching rows in the left table. If a row in the right table does not have a
	matching row in the left table, all columns in the left table will contain nulls.*/



SELECT  
    c.id candidate_id,
    c.fullname candidate_name,
    e.id employee_id,
    e.fullname employee_name
FROM 
    hr.candidates c
    RIGHT JOIN hr.employees e 
    ON e.fullname = c.fullname;

/*
-- 4. Full Outer join
	Returns all records when there is a match in either left or right table. 
	Returns all candidates and all employees.
	Shows matches where available, NULL where no match.
	*/

SELECT  
    c.id AS candidate_id,
    c.fullname AS candidate_name,
    e.id AS employee_id,
    e.fullname AS employee_name
FROM 
    hr.candidates c
    FULL OUTER JOIN hr.employees e 
    ON e.fullname = c.fullname;


--5. CROSS JOIN:
  --Returns all possible combinations of candidates and employees.
SELECT  
	c.id AS candidate_id,
	e.id AS employee_id,
    c.fullname AS candidate_name,
    e.fullname AS employee_name
FROM 
    hr.candidates c
    CROSS JOIN hr.employees e;


/*	-- 6.  Self Join
A self join allows you to join a table to itself.
It helps query hierarchical data or compare rows within the same table.
A self join uses the inner join or left join clause. 
Because the query that uses the self join references the same table, 
the table alias is used to assign different names to the same table within the query.

Note that referencing the same table more than once in a query without using table aliases
will result in an error.

 syntax : 
 SELECT
    select_list
FROM
    T t1
[INNER | LEFT]  JOIN T t2 ON
    join_predicate; 

*/

--1) Using self join to query hierarchical data
SELECT
    e.first_name + ' ' + e.last_name employee,
    m.first_name + ' ' + m.last_name manager
FROM
    sales.staffs e
INNER JOIN sales.staffs m ON m.staff_id = e.manager_id
ORDER BY
    manager;

--2) Using self join to compare rows within a table
SELECT
    c1.city,
    c1.first_name + ' ' + c1.last_name customer_1,
    c2.first_name + ' ' + c2.last_name customer_2
FROM
    sales.customers c1
INNER JOIN sales.customers c2 ON c1.customer_id > c2.customer_id
AND c1.city = c2.city
ORDER BY
    city,
    customer_1,
    customer_2;

/*---------********************* JIONS ***************************------------------------------------
-- 4 Tables 
hr.candidates — List of candidates.
hr.employees — List of employees.
hr.departments — Departments where employees work.
hr.interviews — Interview records between candidates and employees.

*/

--1. Create a new table departments:
CREATE TABLE hr.departments (
    id INT PRIMARY KEY IDENTITY,
    dept_name VARCHAR(100) NOT NULL);


-- 2. Create a new table interviews:
CREATE TABLE hr.interviews (
    id INT PRIMARY KEY IDENTITY,
    candidate_id INT NOT NULL,
    employee_id INT NOT NULL,
    interview_date DATE,
    result VARCHAR(50),

    FOREIGN KEY (candidate_id) REFERENCES hr.candidates(id),
    FOREIGN KEY (employee_id) REFERENCES hr.employees(id)
);

-- 3. Add a department_id to employees:
ALTER TABLE hr.employees
ADD department_id INT;

-- Add Foreign Key to connect employees with departments
ALTER TABLE hr.employees
ADD CONSTRAINT FK_Employee_Department
FOREIGN KEY (department_id) REFERENCES hr.departments(id);

-- 4. Insert some sample data into departments and update employees:

INSERT INTO hr.departments (dept_name)
VALUES ('HR'), ('Engineering'), ('Finance');


-- Assume employees already inserted; now assign departments
UPDATE hr.employees
SET department_id = 1
WHERE fullname = 'John Doe';

UPDATE hr.employees
SET department_id = 2
WHERE fullname = 'Jane Doe';

UPDATE hr.employees
SET department_id = 3
WHERE fullname = 'Michael Scott';

UPDATE hr.employees
SET department_id = 2
WHERE fullname = 'Jack Sparrow';

select * from hr.employees;



--5. Insert data into interviews:
INSERT INTO hr.interviews (candidate_id, employee_id, interview_date, result)
VALUES 
(1, 1, '2024-03-01', 'Selected'),
(2, 2, '2024-03-02', 'Rejected'),
(3, 3, '2024-03-03', 'Pending'),
(4, 1, '2024-03-04', 'Selected');

/*
--  Example 1: Get candidates, interviewer employee, interview date, result, and
	-- department of the interviewer:

interviews	Acts as a bridge connecting candidates and employees (interviewer)
candidates	Gives candidate details
employees	Gives interviewer details
departments	Gives department of interviewer
*/

SELECT 
    c.id AS candidate_id,
    c.fullname AS candidate_name,
    e.id AS employee_id,
    e.fullname AS employee_name,
    d.dept_name AS department_name,
    i.interview_date,
    i.result
FROM 
    hr.interviews i
    INNER JOIN hr.candidates c ON i.candidate_id = c.id
    INNER JOIN hr.employees e ON i.employee_id = e.id
    INNER JOIN hr.departments d ON e.department_id = d.id;


/* EXAMPLE 2 If you want to make this Left Join to show all candidates whether they attended
	an interview or not:

INNER JOIN	Returns records with matching rows in both tables
LEFT JOIN	Returns all records from left table and matched records from right
RIGHT JOIN	Returns all records from right table and matched records from left
Foreign Key Relationship	Connecting related tables (candidates & employees via interviews)
Table Aliases	Short names (e.g., c, e, i, d) for better readability

*/

SELECT 
    c.id AS candidate_id,
    c.fullname AS candidate_name,
    e.id AS employee_id,
    e.fullname AS employee_name,
    d.dept_name AS department_name,
    i.interview_date,
    i.result
FROM 
    hr.candidates c
    LEFT JOIN hr.interviews i ON i.candidate_id = c.id
    LEFT JOIN hr.employees e ON i.employee_id = e.id
    LEFT JOIN hr.departments d ON e.department_id = d.id;


/*
1. FULL OUTER JOIN (Combining unmatched data from both sides) 
To get all candidates and all employees, even if there are no interviews between them
*/

SELECT
    c.id AS candidate_id,
    c.fullname AS candidate_name,
    e.id AS employee_id,
    e.fullname AS employee_name,
    i.interview_date,
    i.result
FROM
    hr.candidates c
    FULL OUTER JOIN hr.interviews i ON c.id = i.candidate_id
    FULL OUTER JOIN hr.employees e ON i.employee_id = e.id;



/*
CROSS JOIN (Cartesian product)
Purpose: To combine every candidate with every department (just an example).
Returns all possible combinations of candidates and departments.
Useful for generating all possible pairs when needed (e.g., possible assignment combinations).

*/

SELECT
    c.id AS candidate_id,
    c.fullname AS candidate_name,
    d.id AS department_id,
    d.dept_name AS department_name
FROM
    hr.candidates c
    CROSS JOIN hr.departments d;


/*
LEFT JOIN with conditions (filtering left join result)
Purpose: Find candidates who have been interviewed, along with employees and department
info — but only show candidates interviewed by "HR" department.
*/

SELECT
    c.id AS candidate_id,
    c.fullname AS candidate_name,
    e.id AS employee_id,
    e.fullname AS employee_name,
    d.dept_name AS department_name,
    i.interview_date,
    i.result
FROM
    hr.candidates c
    LEFT JOIN hr.interviews i ON c.id = i.candidate_id
    LEFT JOIN hr.employees e ON i.employee_id = e.id
    LEFT JOIN hr.departments d ON e.department_id = d.id
WHERE
    d.dept_name = 'HR';


/*
RIGHT JOIN example for employees & departments
Purpose: Find all departments and employees working in them (even if no employees are in a department).
*/

SELECT
    d.id AS department_id,
    d.dept_name AS department_name,
    e.id AS employee_id,
    e.fullname AS employee_name
FROM
    hr.employees e
    RIGHT JOIN hr.departments d ON e.department_id = d.id;


	/*
6. INNER JOIN with multiple conditions
Purpose: Candidates interviewed and selected by employees from "Engineering" department.
	*/


SELECT
    c.id AS candidate_id,
    c.fullname AS candidate_name,
    e.id AS employee_id,
    e.fullname AS employee_name,
    d.dept_name AS department_name,
    i.interview_date,
    i.result
FROM
    hr.interviews i
    INNER JOIN hr.candidates c ON i.candidate_id = c.id
    INNER JOIN hr.employees e ON i.employee_id = e.id
    INNER JOIN hr.departments d ON e.department_id = d.id
WHERE
    i.result = 'Selected'
    AND d.dept_name = 'Engineering';



/**************************** INDEX ***********************************
Index is a database object that improves the speed of data retrieval on a table by allowing quick lookup of records—just like an index in a book that helps you quickly find topics.

--> Purpose of Index:
Improve query performance (especially SELECT).
Quickly locate data without scanning the whole table (avoiding full table scans).
Helps WHERE, JOIN, ORDER BY, and GROUP BY clauses work faster.

SQL provides Create Index, Alter Index, and Drop Index commands used to 
	create a new index, update an existing one, and delete an index in SQL Server.

--> What are Indexes in SQL Server?
	Indexes are special lookup tables that SQL Server uses to speed up data access.
	Commands to manage indexes:
	CREATE INDEX – to create a new index.
	ALTER INDEX – to modify an existing index.
	DROP INDEX – to remove an index.

--> Data Storage and Extents in SQL Server
	Data is stored in pages (each 8 KB in size).
	8 continuous pages form an extent.
	When tables are created, extents are allocated to store data.


-->Table Scan in SQL Server
If no index is present, SQL Server performs a Table Scan, meaning it will read all rows to
find the data.

--> System Table sysindexes:
	Contains information about all indexes.
	indid = 0: Indicates no index (heap).
	indid = 1: Clustered index.
	indid >= 2: Non-clustered index.

-->Drawbacks of Table Scan:
	Poor performance as table size grows.
	Increases I/O operations and query execution time.

** Types of Indexes in SQL Server: **
Index Type				Description
Clustered Index			Physically sorts data in the table based on indexed column(s).
Non-Clustered Index		Logical structure with a pointer to the actual data rows.
Unique Index			Ensures unique values in the column (like UNIQUE constraint).
Composite Index			Index on multiple columns.
Filtered Index			Index on a subset of rows (using WHERE).
Full-Text Index			Used for searching textual data efficiently.


-->Table Scan
A Table Scan occurs when SQL Server reads each and every row of a table to find matching 
records for the query condition (e.g., in WHERE clause).
This happens when there is no index available on the column used in the query's condition.

--> sysindexes Table:
sysindexes is a system table that stores information about all indexes defined on user tables.
Columns of sysindexes (like indid - index id) help SQL Server decide whether an index exists on a table or not.


--> 1. Clustered Index
	Physically arranges rows in sorted order in memory.
	Only one clustered index allowed per table.
	B-Tree structure used for storage.
	Fast for range queries.
	Insert/Update performance impact due to sorted structure.
*/



CREATE TABLE students (
    roll_no INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50)
);

INSERT INTO students (roll_no, FirstName, LastName)
VALUES 
(1, 'John', 'Doe'),
(2, 'Jane', 'Smith'),
(3, 'Alice', 'Johnson'),
(4, 'Bob', 'Brown'),
(5, 'Charlie', 'Davis');

-- Create a Clustered Index
CREATE CLUSTERED INDEX idx_StudRollNo ON students(roll_no);

--Verify Index Creation
sp_helpindex 'students';
--OR

SELECT 
    name AS index_name, 
    type_desc, 
    is_primary_key, 
    is_unique 
FROM 
    sys.indexes 
WHERE 
    object_id = OBJECT_ID('students');


select * from students


--Create Non-Clustered Index:
CREATE NONCLUSTERED INDEX idx_FirstName ON students(FirstName);

--Create Composite Non-Clustered Index on (FirstName, LastName)
CREATE NONCLUSTERED INDEX idx_First_LastName ON students(FirstName, LastName);

--Step 9: Create Unique Non-Clustered Index on roll_no (to ensure unique roll numbers)
-- Note: Since roll_no already has clustered index, this will ensure uniqueness with non-clustered behavior
CREATE UNIQUE NONCLUSTERED INDEX idx_UniqueRollNo ON students(roll_no);

-- Create Composite Index:
CREATE INDEX idx_RollNo ON students(roll_no, FirstName);

-- Step 10: Alter (Rebuild) an Index (Example for maintenance of idx_FirstName)
ALTER INDEX idx_FirstName ON students REBUILD;

-- Step 11: Drop Index (Example to drop idx_FirstName)
DROP INDEX idx_FirstName ON students;


