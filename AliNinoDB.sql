--CREATE DATABASE AliNinoDB
----use AliNinoDB

------------------------------------------------- Create Tables -------------------------------------------------

--Create Table Categories
--(
--	Id int identity Primary key,
--	Title nvarchar(60),
--	ParentCategoryId int REFERENCES Categories(Id),
--	IsDeleted bit Default 0
--)


--Create Table Authors
--(
--	Id int identity Primary key,
--	Name nvarchar(60),
--	Surname nvarchar(60),
--	IsDeleted bit Default 0
--)

--Create Table PublishingHouse
--(
--	Id int identity Primary key,
--	Title nvarchar(60),
--	IsDeleted bit Default 0
--)
--Create Table Genres
--(
--	Id int identity Primary key,
--	Title nvarchar(60),
--	IsDeleted bit Default 0
--)
--Create Table Bindings
--(
--	Id int identity Primary key,
--	Title nvarchar(60),
--	IsDeleted bit Default 0
--)

--Create Table Languages
--(
--	Id int identity Primary key,
--	Title nvarchar(60),
--	IsDeleted bit Default 0
----)
--Create Table Books
--(
--	Id int identity Primary key,
--	Title nvarchar(60),
--	Description nvarchar(250),
--	ActualPrice int not null,
--	DiscountPrice int default null,
--	PublishingHouseId int REFERENCES PublishingHouse(id),
--	StockCount int,
--	ArticleCode nvarchar(20),
--	BindingId int REFERENCES Bindings(Id),
--	Pages int,
--	CategoryId int REFERENCES Categories(Id),
--	IsDeleted bit Default 0
--)

--Create Table BooksGenres
--(
--	Id int identity Primary key,
--	BookId  int REFERENCES Books(Id),
--	GenreId  int REFERENCES Genres(Id),
--)


--Create Table BooksAuthors
--(
--	Id int identity Primary key,
--	BookId  int REFERENCES Books(Id),
--	AuthorId  int REFERENCES Authors(Id),
--)


--Create Table BooksLanguages
--(
--	Id int identity Primary key,
--	BookId  int REFERENCES Books(Id),
--	LanguageId  int REFERENCES Languages(Id),
--)

--Create Table Comments
--(
--	Id int identity Primary key,
--	Description nvarchar(250),
--	BookId  int REFERENCES Books(Id),
--	Rating tinyint Check(Rating between 0 and 5),
--	Name nvarchar(60) not null,
--	Email nvarchar(254) not null,
--	ImgUrl nvarchar(max),
--	IsDeleted bit Default 0
--)



-------------------------------------------------1 Create Procedure -------------------------------------------------


Alter PROCEDURE InsertValues(@AuthorName nvarchar(60),@AuthorSurname nvarchar(60),@BindingTitle nvarchar(60)
,@BookTitle nvarchar(60),@BookDescription nvarchar(250),@BookActualPrice int,@BookDiscountPrice int,@PublishingHouseTitle nvarchar(60)
,@StockCount int,@ArticleCode nvarchar(20),@Pages int,@CategoryTitle nvarchar(60),@CategoryParentId int,@GenreTitle nvarchar(60), @BookLanguageTitle nvarchar(60))
AS
Declare @AuthorId int
if @AuthorName+@AuthorSurname in (select [Name]+Surname from Authors)
	Set @AuthorId=(select Id from Authors Where [Name]+Surname=@AuthorName+@AuthorSurname)
Else
	INSERT INTO Authors ([Name], Surname)
	VALUES (@AuthorName,@AuthorSurname)
	Set @AuthorId =(select Id from Authors Where [Name]+Surname=@AuthorName+@AuthorSurname)

Declare @BindingId int
if @BindingTitle in (Select Title from Bindings)
	Set @BindingId =(Select Id from Bindings Where @BindingTitle=Title)
Else 
	INSERT INTO Bindings (Title)
	VALUES (@BindingTitle)
	Set @BindingId  =(select Id from Bindings Where Title=@BindingTitle)

Declare @PublishingHouseId int
if @PublishingHouseTitle in (Select Title from PublishingHouse)
	SET @PublishingHouseId =(Select Id from PublishingHouse Where Title=@PublishingHouseTitle)
Else 
	INSERT INTO PublishingHouse (Title)
	VALUES (@PublishingHouseTitle)
	Set @PublishingHouseId =(select Id from PublishingHouse Where Title=@PublishingHouseTitle)

Declare @CategoryId int
If @CategoryTitle  in (Select Title  from categories)
	 Set @CategoryId =(Select Id from categories where Title=@CategoryTitle)
Else
	Insert Into categories (Title,ParentCategoryId)
	Values (@CategoryTitle,@CategoryParentId)
	 Set @CategoryId =(Select Id from categories where Title=@CategoryTitle)

Declare @GenreId int 
if @GenreTitle in (Select Title from Genres)
	SET @GenreId =(Select Id from Genres Where @GenreTitle=Title)
Else 
	INSERT INTO Genres (Title)
	VALUES (@GenreTitle)
	Set @GenreId =(select Id from Genres Where Title=@GenreTitle)

Declare @LanguageId int 
if @BookLanguageTitle in (Select Title from Languages)
	SET @LanguageId  =(Select Id from Languages Where @BookLanguageTitle=Title)
Else 
	INSERT INTO Languages (Title)
	VALUES (@BookLanguageTitle)
	SET @LanguageId =(select Id from Languages Where Title=@BookLanguageTitle)
Insert Into Books (Title,Description,ActualPrice,DiscountPrice,PublishingHouseId,StockCount,ArticleCode,BindingId,Pages,CategoryId)
Values(@BookTitle,@BookDescription,@BookActualPrice,@BookDiscountPrice, @PublishingHouseId,@StockCount,@ArticleCode,@BindingId,@Pages,@CategoryId)

Declare @BookId int
Set @BookId=(Select Id from Books Where ArticleCode=@ArticleCode)
Insert Into BooksAuthors(BookId,AuthorId)
Values (@BookId,@AuthorId)

Insert Into BooksGenres(BookId,GenreId)
Values (@BookId,@GenreId)

Insert Into BooksLanguages(BookId,LanguageId)
Values (@BookId,@LanguageId)

----------- Use Procedure -----------

EXEC dbo.InsertValues @AuthorName ='Alii',@AuthorSurname='Sefeerov',@BindingTitle='Yuumsaq',@BookTitle='Seffiller',@BookDescription='eela kitabdir',
@BookActualPrice =10,@BookDiscountPrice=9,@PublishingHouseTitle ='guvennnesriiyyati',@StockCount=100,@ArticleCode ='djsddr243f',@Pages =210,
@CategoryTitle='Kitaablar',@CategoryParentId=Null,@GenreTitle='Draama', @BookLanguageTitle='Azee'

--------- Normalda commenti de yuxardaki procedure yazsaq onda her kitaba static sayda comment elave etmek olur one-to-many elaqede many teref comment oldugu ucun 
--------- ve kitab yaradilanda comment olmur sonradan elave olundugunu dusunduyumden onun ucun ayri procedure yazdim


----------- Comments Procedure -----------

Create Procedure InsertComment(@Description nvarchar (250),@BookArticleCode nvarchar(20),@Rating tinyint,@Name nvarchar (60),@Email nvarchar (254),@imgurl nvarchar(max) )
As
Declare @BookId int ----Articlecode'un unique oldugunu dusunrem ona gorede kitabi article code'a gore tapiram
Set @BookId=(Select Id from Books Where ArticleCode=@BookArticleCode)
Insert Into Comments ([Description],BookId,Rating,[Name],Email,imgurl)
Values (@Description,@BookId,@Rating,@Name,@Email,@imgurl)

----------- Use Procedure -----------

Exec dbo.InsertComment @Description='Maraqli idi',@BookArticleCode='djsdd243f',@Rating=4,@Name='Akif',@Email='Akif@gmail.com',@imgurl='aa.jpg'


----------- Update Procedure -----------
----- Muellimin tam olaraq nece bir sey istediyini tam anlamadim deye numune olaraq anladigim formada bir table ucun uptade yazdim

Create PROCEDURE UpdateBook(@curentArticleCode nvarchar(20),@BookTitle nvarchar(60),@BookDescription nvarchar(250),@BookActualPrice int,@BookDiscountPrice int,@PublishingHouseid int
,@StockCount int,@ArticleCode nvarchar(20),@bindingId int ,@Pages int,@CategoryId int)
As
if @BookTitle is not null
	UPDATE Books
	SET Title = @BookTitle                  ----Articlecode'un unique oldugunu dusunrem ona gorede kitabi article code'a gore tapiram her defe 
	WHERE  ArticleCode=@curentArticleCode   ----inputa ilk olaraq cari code alinir sonra deyismeli olan valueler
if @BookDescription is not null
	UPDATE Books
	SET Description= @BookDescription    
	WHERE  ArticleCode=@curentArticleCode  
if @BookActualPrice is not null
	UPDATE Books
	SET ActualPrice= @BookActualPrice    
	WHERE  ArticleCode=@curentArticleCode  

if @BookDiscountPrice is not null
	UPDATE Books
	SET DiscountPrice= @BookDiscountPrice    
	WHERE  ArticleCode=@curentArticleCode  

if @PublishingHouseid is not null
	UPDATE Books
	SET PublishingHouseid= @PublishingHouseid    
	WHERE  ArticleCode=@curentArticleCode  
	
if @StockCount is not null
	UPDATE Books
	SET StockCount= @StockCount    
	WHERE  ArticleCode=@curentArticleCode  
	
if @ArticleCode is not null
	UPDATE Books
	SET ArticleCode= @ArticleCode    
	WHERE  ArticleCode=@curentArticleCode  
if @bindingId is not null
	UPDATE Books
	SET bindingId= @bindingId    
	WHERE  ArticleCode=@curentArticleCode  
	
if @Pages is not null
	UPDATE Books
	SET Pages= @Pages    
	WHERE  ArticleCode=@curentArticleCode  

if @CategoryId is not null
	UPDATE Books
	SET CategoryId= @CategoryId    
	WHERE  ArticleCode=@curentArticleCode  

----------- Use Procedure -----------

------ilk value book u tapmaq ucun cari book code dur sonraki deyerler null'dursa demeli deyismek istemir null deyilse hemin deyeri table'da update edirik
------curentArticleCode u ona gore goturdumki id ni istifadechi gomur ama curentArticleCode u istifadechi gorurdu  bu saytda
Exec dbo.UpdateBook @curentArticleCode ='djsdd243f',@BookTitle='Harry Potter',@BookDescription=null,@BookActualPrice=null,@BookDiscountPrice=null,@PublishingHouseid=null
,@StockCount=1,@ArticleCode=null,@bindingId=null ,@Pages=null,@CategoryId=null





-------------------------------------------------2 Create Trigger -------------------------------------------------

------Her table ucun trigger yazdim ama eyni sey tekrar idi deye tes ucun bir defe isletdim Asagida
Create Trigger DeleteBook
On Books
Instead Of Delete
as
BEGIN
	UPDATE Books
	SET IsDeleted = 1
	WHERE  Id in(SELECT Id FROM deleted)
END
--------------
Create Trigger DeleteAuthors
On Authors
Instead Of Delete
as
BEGIN
	UPDATE Authors
	SET IsDeleted = 1
	WHERE  Id in(SELECT Id FROM deleted)
END
--------------
Create Trigger DeleteBindings
On Bindings
Instead Of Delete
as
BEGIN
	UPDATE Bindings
	SET IsDeleted = 1
	WHERE  Id in(SELECT Id FROM deleted)
END
--------------
Create Trigger DeleteCategories
On Categories
Instead Of Delete
as
BEGIN
	UPDATE Categories
	SET IsDeleted = 1
	WHERE  Id in(SELECT Id FROM deleted)
END
--------------
Create Trigger DeleteComments
On Comments
Instead Of Delete
as
BEGIN
	UPDATE Comments
	SET IsDeleted = 1
	WHERE  Id in(SELECT Id FROM deleted)
END
--------------
Create Trigger DeleteGenres
On Genres
Instead Of Delete
as
BEGIN
	UPDATE Genres
	SET IsDeleted = 1
	WHERE  Id in(SELECT Id FROM deleted)
END
--------------
Create Trigger DeleteLanguages
On Languages
Instead Of Delete
as
BEGIN
	UPDATE Languages
	SET IsDeleted = 1
	WHERE  Id in(SELECT Id FROM deleted)
END
--------------
Create Trigger DeletePublishingHouse
On PublishingHouse
Instead Of Delete
as
BEGIN
	UPDATE PublishingHouse
	SET IsDeleted = 1
	WHERE  Id in(SELECT Id FROM deleted)
END
----------- Use trigger -----------

Delete from books
Where id=1

