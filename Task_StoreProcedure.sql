/*
Task 1) using store procedure 
A user sends a list of items in their cart.
applies best offers/coupons from a stored list (e.g., BOGO, 20% off, Buy 3 get 1).It returns the final price + savings.

1.create two table 
2.product : productid , namme , stock , price -- use existing
3.craete cart table : cartId , productID , quantity  foregin key 
4.create store procedure  
   which takes productid , cartid , quantiy , productname 
   according to quantity  apply offer use conditions 
  
  if quantity is 1 BOGO buy 1 get one free ,  
  if quantity 3 then buy 3 get 1 free ,
  else 20% off , 

  op: productid , productName , quantity , orignalprice , totalpriceAfterOffer , savingamount 

*/

	----------------------------------------------------------------

create table cart(CartID int ,ProductID int , Quantity int , foreign key (ProductID) references products(ProductID))

insert into cart (CartID ,ProductID,Quantity)
	values(101,1,1), (102,2,3) , (103,3,6)

select * from Products
select * from cart

--create procedure ApplyOffer
alter procedure ApplyOffer
@CartID int

As 
begin
		-- select c.ProductID, p.ProductName, c.Quantity , p.price as OrignalPricePerUnit,
			select c.ProductID, p.ProductName, c.Quantity as OrderedQuantity  , p.price as OrignalPricePerUnit,

			--qunatity customer get
		case 
			when c.Quantity = 1 then c.Quantity+1   --BOGO
			when c.Quantity = 3 then c.Quantity+1    --buy 3 get 3
			else c.Quantity 
			end as QuantityAfterOffer,


		-- 1.calculate total price 
		case
			when c.quantity = 1 then p.price * c.Quantity
			when c.quantity = 3 then p.price * c.Quantity
			else c.quantity * p.price 
		end as TotalPriceBeforeOffer, 

		--- 2.calculate price after applied offer
		case
			--when c.quantity = 1 then p.price * c.Quantity
			when c.quantity = 1 then p.price * 1 
			when c.quantity = 3 then p.price * 3 
			--else (c.quantity * p.price * (20/100))
			else c.quantity * p.price * 0.8

		end as TotalPriceAfterOffer, 

		--3. save amount
		case 
			when  c.quantity = 1 then p.price
			when c.quantity = 3 then p.price
			else c.quantity * p.price * 0.2
	end as SavingAmount


	from cart c
	join Products p on c.productID = p.ProductID
	where c.cartID = @CartID;

end;

exec ApplyOffer @CartID = 102;




-------**********************************************************************************----------------------------
/*
Task 2: Build a multiplayer quiz system:
Two players join a session and answer the same questions.
Tracks time taken + correctness.
API decides the winner and stores the score.

table : players , quizeque , gameSessionstore , playeranswers 
*/

-- 1. player table
create table player(PlayerID int Identity, PlayerName varchar(50))
alter table player add constraint  PK_PlayerID  primary key (PlayerID);


insert into player(PlayerName) 
values('Puja'), ('Disha');
select* from player

-- 2. Quiz Questions Table

create table QuizQuestions(QueID int identity , QueText nvarchar(500), CorrectAns Nvarchar(100) )
alter table QuizQuestions add constraint  PK_QueID  primary key (QueID);


INSERT INTO QuizQuestions (QueText, CorrectAns)
VALUES('ASP.NET is used for ?	 1.Web Development 2.Mobile Apps 3.Database Design',   '1 Web Development'),
	  ('Which language is commonly used in ASP.NET?		 1.Java  2.C#  3.Python',		'2 C#'),
	  ('ASP.NET is developed by?	1.Google  2.Microsoft 3.Amazon',					'2: Microsoft'),
	  ('JWT stands for?		1. Java Web Token 2. JSON Web Token 3. JavaScript Web Token', '2 JSON Web Token'),
	  ('Which method is used to secure APIs in ASP.NET Core? 1. Session 2. JWT Token 3. Cookies', '2 JWT Token'),
	  ('Which tool is used to document APIs in ASP.NET Core? 1. Swagger 2. Postman 3. LINQ', '1 Swagger'),
	  ('Which is used as  message broker  ? 1. RabbitMQ 2. SMTP 3. Redis',			 '1 RabbitMQ')

select * from QuizQuestions


-----------------------------------------
-- table to store session  GameSession 

create table GameSession(SessionID int identity , Player1Id int , Player2ID int , StartTime Datetime default getDate(), 
				foreign key (Player1Id) references player(PlayerID),
				foreign key (Player2Id) references player(PlayerID))

alter table GameSession add constraint  Pk_sessionID  primary key (SessionID);


				

insert into GameSession (Player1Id, Player2ID)
values (1, 2); 

select * from GameSession
select * from player 



---------------------------------------
-- create table to store player answers records

create table PlayerAnswerTable(
	AnswerID  int primary key identity,
	SessionID int,
	PlayerID int,
	QuestionID int,
	Answer nvarchar(100),
	AnsweredAt datetime,
	IsCorrect bit,
	TimeTakenSeconds int,
	foreign key (SessionID) references GameSession(SessionID),
	foreign key (PlayerID) references Player(PlayerID),
	foreign key (QuestionID) references QuizQuestions(QueID)
);


--PlayerID =1 
insert into PlayerAnswerTable (SessionID, PlayerID, QuestionID, Answer,AnsweredAt, IsCorrect, TimeTakenSeconds)
values	(1, 1, 1, '1 Web Development', getdate(), 1, 9),
		(1, 2, 1, '1 Web Development', getdate(), 1, 10),

		(1, 1, 2, '3 Python', getdate(), 0, 7),
		(1, 2, 2, '2 C#', getdate(), 1, 8),

		(1, 1, 3, '2 Microsoft', getdate(), 1, 13),
		(1, 2, 3, '2 Microsoft', getdate(), 1, 12),

		(1, 1, 4, '2 JSON Web Token', getdate(), 1, 10),
		(1, 2, 4, '1 Java Web Token', getdate(), 0, 15),

		(1, 1, 5, '1 Session', getdate(), 0, 14),
		(1, 2, 5, '2 JWT Token', getdate(), 1, 11),

		(1, 1, 6, '1 Swagger', getdate(), 0, 14),
		(1, 2, 6, '1 Swagger', getdate(), 1, 11),

		(1, 1, 7, '2 SMTP', getdate(), 0, 14),
		(1, 2, 7, '1 RabbitMQ', getdate(), 1, 11);



		select * from PlayerAnswerTable
		select * from QuizQuestions
-----------------------------------------------------------------------
--drop table PlayerAnswerTable


-----------------------------------------------------
-- create procedure to decide winner
create procedure DecideWinner
@SessionId int

as 
begin

	declare @Player1 int , @Player2 int;

	select @Player1 = Player1Id , @Player2= Player2Id
	from GameSession
		where sessionId = @SessionId

	--player 1 correct ans and total time
	Declare @p1Correct int , @p1Time int 
	select
		@p1Correct = count(*),
		@p1Time = sum(TimeTakenSeconds)
		from PlayerAnswerTable
		where SessionID = @SessionId and PlayerID = @Player1 and IsCorrect =1;


	--player 2 correct ans and total time
	declare @P2Correct int, @P2Time int;
     select
        @P2Correct = count(*), 
        @P2Time = sum(TimeTakenSeconds)
    from PlayerAnswerTable 
    where SessionID = @SessionID AND PlayerID = @Player2 AND IsCorrect = 1;
 
    select 
        case
            when @P1Correct > @P2Correct Then @Player1
            when @P2Correct > @P1Correct Then @Player2
            when @P1Correct = @P2Correct AND @P1Time < @P2Time Then @Player1
            when @P1Correct = @P2Correct AND @P2Time < @P1Time Then @Player2
            else NULL
        end AS WinnerPlayerID;
end

exec DecideWinner @SessionID = 1






	

