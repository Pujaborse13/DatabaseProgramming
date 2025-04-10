
/**************************** Cursors **********************/

use BikeStores
select * from StudentDetails

CREATE TABLE StudentDetails (
    RollNo INT PRIMARY KEY,
    StudentName VARCHAR(100),
    Class VARCHAR(10),
    Marks_Science INT,
    Marks_Math INT,
    Marks_Eng INT
);


INSERT INTO StudentDetails (RollNo, StudentName, Class, Marks_Science, Marks_Math, Marks_Eng) 
VALUES
(1, 'Rahul Sharma', '10th', 85, 90, 88),
(2, 'Priya Singh', '10th', 78, 82, 80),
(3, 'Ankit Verma', '10th', 92, 88, 95),
(4, 'Sneha Joshi', '10th', 76, 84, 79),
(5, 'Vikas Patel', '10th', 89, 91, 87),
(6, 'Pooja Deshmukh', '10th', 95, 97, 99),
(7, 'Amit Gupta', '10th', 72, 80, 74),
(8, 'Neha Kulkarni', '10th', 88, 92, 85),
(9, 'Rohit Mehta', '10th', 79, 83, 81),
(10, 'Swati Malhotra', '10th', 91, 89, 94);


-----------------------------------------

--These variables store data from the current row of the StudentDetails 
--table while iterating through records.
Declare @RollNo Int,
@Student_Name varchar(100),
@Marks_Science int,
@Marks_Math int , 
@Marks_Eng int,
@Marks_Total INT,
@Percentage INT

--This creates a cursor named student_cursor that fetches RollNo, StudentName,
-- Marks_Science, Marks_Math, and Marks_Eng from the StudentDetails table.
Declare student_cursor cursor for select RollNo, StudentName, Marks_Science, Marks_Math, Marks_Eng 
from StudentDetails

open student_cursor -- The OPEN statement makes the cursor available for fetching data.
fetch Next from student_cursor into @RollNo,@Student_Name,@Marks_Science,@Marks_Math,@Marks_Eng --Retrieves the first row and assigns values to the declared variables.

while @@FETCH_STATUS= 0 -- @FETCH_STATUS = 0 ensures that the loop runs until all records are processed.
begin
	--Displays each student’s details.
	print concat('Name: ',@Student_Name);
	print concat('RollNo :',@RollNo);
	print concat('Science :',@Marks_Science);
	print concat('Math :',@Marks_Math);
	print concat('English :',@Marks_Eng);


	set @Marks_Total = @Marks_Science+ @Marks_Math + @Marks_Eng; -- Adds the marks of Science, Math, and English.
	print concat('Total :',@Marks_Total);

	Set @Percentage = @Marks_Total/3;
	set  @Percentage = @Marks_Total /3;
	print concat('Percentage :' , @Percentage,'%');

	--SET @Percentage = CAST(@Marks_Total AS FLOAT) / 3; --Divides the total marks by 3 to get the percentage.,  prevents integer division (which truncates decimals).
--	PRINT CONCAT('Percentage: ', FORMAT(@Percentage, '0.00'), '%'); --ensures 2 decimal places in output.

	-- Determines and prints the grade based on percentage.
	if @Percentage > 80
		BEGIN 
			print 'Grade : A';
		END
		else if @Percentage > 60 AND @Percentage < 80
		begin 
			print 'Grade : B';
		END

		else
		Begin 
			print 'Grade : C';
		end
print '==================';
	fetch next from student_cursor into @RollNo,@Student_Name,@Marks_Science,@Marks_Math,@Marks_Eng --Moves to the next row.
END
close student_cursor; -- releases the cursor but keeps its structure.
Deallocate student_cursor; -- removes the cursor from memory.





