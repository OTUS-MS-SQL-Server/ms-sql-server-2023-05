--Временные хранимые процедуры
USE WideWorldImporters;
go
DROP PROCEDURE IF EXISTS #usp_temp_sp;
CREATE PROCEDURE #usp_temp_sp AS
BEGIN
	declare @Result int;
	set @Result = 10;
	select @Result;
	return;
END

select * from tempdb..sysobjects where id = OBJECT_ID(N'tempdb..#usp_temp_sp', 'P')


-- Для тестирования процедур можно через временные таблицы 

DROP TABLE IF EXISTS #tmp_table;
CREATE TABLE #tmp_table (
	Res int,
);

INSERT INTO #tmp_table
exec #usp_temp_sp

SELECT * FROM #tmp_table;

-- Создание процедуры через интсерфейс SSMS
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE <Procedure_Name, sysname, ProcedureName> 
	-- Add the parameters for the stored procedure here
	<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
END
GO

-- Параметры
--1)  QUOTED_IDENTIFIER --->
-- 1.1
Use SP
DROP TABLE IF EXISTS  dbo.[IDENTIFIER table];

SET QUOTED_IDENTIFIER Off

    SELECT "Hello, world!" -- кавычка
    SELECT 'Hello, world!' --апостроф
    CREATE TABLE [IDENTIFIER table] ([Ссылка] int)
    SELECT [Ссылка] FROM [IDENTIFIER table]

-- 1.2 ANSI (т. е. SET QUOTED_IDENTIFIER ON):
Use SP
DROP TABLE IF EXISTS  dbo.[IDENTIFIER table];
SET QUOTED_IDENTIFIER ON

	SELECT "Hello, world!" -- кавычки вокруг строк в ANSI недопустимы	-- Ошибка
    SELECT 'Hello, world!' --апостроф
    CREATE TABLE "IDENTIFIER table" ("Ссылка" int)						-- сработает
    SELECT "Ссылка" FROM "IDENTIFIER table"

--2) NOCOUNT
declare @i int
set nocount on                  -- On\Off
select * from [IDENTIFIER table] -- закладка Messages 
set @i = @@rowcount				 -- (0 rows affected) 
print @i


-- Создадим свою схему для идентификации созданных процедур
USE [WideWorldImporters]
GO
CREATE SCHEMA [Student] AUTHORIZATION [dbo]
GO

--Создание процедуры в редакторе запросов
USE WideWorldImporters;  
GO  
IF OBJECT_ID ( 'Student.Student_People', 'P' ) IS NOT NULL   
    DROP PROCEDURE Student.Student_People; 
GO
CREATE PROCEDURE [Student].Get_Kayla      
    @SearchName nvarchar(50)   
AS   
    SET NOCOUNT ON;  
	SELECT SearchName,*
	FROM Application.People  
	WHERE FullName = N'Kayla Woodcock';
GO 

--запуск хранимой процедуры возврат без Return !
EXECUTE [Student].Get_Kayla N'Kayla Woodcock';
-- строка вызова короче
EXEC [Student].Get_Kayla N'Kayla Woodcock';

-- создаем процедуру c привелегие исполнения
IF OBJECT_ID ( 'Student.uspVendorAllInfo', 'P' ) IS NOT NULL   
    DROP PROCEDURE Student.uspVendorAllInfo;  
GO  
CREATE PROCEDURE Student.uspVendorAllInfo -- имя процедуры с префиксом  без входящиего параметра
WITH EXECUTE AS CALLER  
AS  
    SET NOCOUNT ON; 
	 
    SELECT s.SupplierName AS Vendor, 
		si.StockItemName AS 'Product name'
    FROM Purchasing.PurchaseOrderLines o  --purchare line 
    INNER JOIN Warehouse.StockItems si    --item
		ON si.StockItemID = o.StockItemID 
	INNER JOIN Purchasing.Suppliers s     --supplier
		ON s.SupplierID = si.SupplierID    
    ORDER BY s.SupplierName ASC;  
GO  

--Изменение процедуры 
ALTER PROCEDURE Student.uspVendorAllInfo  
    @StockItemID varchar(25)  -- добавляем входящий параметр 
AS  
    SET NOCOUNT ON;
	  
    SELECT LEFT(s.SupplierName, 25) AS Vendor, LEFT(si.StockItemName, 25) AS 'Product name',   
    'Rating' = CASE s.PaymentDays   
        WHEN 7 THEN 'Excellent'  
        WHEN 14 THEN 'Average'     
        ELSE 'No rating'  
        END  
    FROM Purchasing.Suppliers AS s   
    INNER JOIN Warehouse.StockItems AS si  
      ON s.SupplierID = si.SupplierID   
    INNER JOIN Purchasing.PurchaseOrderLines AS o   
      ON o.StockItemID = si.StockItemID   
    WHERE o.StockItemID LIKE @StockItemID 
    ORDER BY s.PaymentDays ASC; 	 
GO  
-- выполнение хранимой процедуры
EXEC Student.uspVendorAllInfo N'150';  -- позиционная передача параметра
EXEC Student.uspVendorAllInfo @StockItemID= N'150' -- именная передача
GO


-- Получение существующих хранимых процедур
SELECT name AS procedure_name   
    ,SCHEMA_NAME(schema_id) AS schema_name  
    ,type_desc  
    ,create_date  
    ,modify_date  
FROM sys.procedures;

--удаление хранимой процедуры 
DROP PROCEDURE [Student].uspVendorAllInfo;
   


-- Передача значения переменной. 
-- Остальные параметры будут передаваться через запятую
-- EXEC Purchasing.uspVendorAllInfo @parm1, @parm1; 
DECLARE @StockItemID varchar(25);  
SET @StockItemID = '150';   
EXEC Student.uspVendorAllInfo @StockItemID;  
GO  

-- передача параметром таблицы в хранимую процедуру
-- создаем свой тип
CREATE TYPE uspTableType 
AS TABLE (Name VARCHAR(50))
GO 


-- вставляем запись
DECLARE @uspTable uspTableType
INSERT INTO @uspTable(Name) VALUES('It is me')
SELECT * FROM @uspTable
-- создаем процедуру
CREATE PROCEDURE Student.uspTableParm -- имя процедуры с префиксом
     @uspTable uspTableType  READONLY    
AS 
     SET NOCOUNT ON;
	 SELECT TOP 1  Name FROM @uspTable
	 RETURN  -- если нужно точно вывод информации указываем Return
GO

--проверяем
DECLARE @tempTable uspTableType
INSERT INTO @tempTable(Name) VALUES('It is temp')
EXEC Student.uspTableParm @uspTable=@tempTable


--Указание значений параметра по умолчанию
IF OBJECT_ID ( 'Student.uspGetSalesName', 'P' ) IS NOT NULL   
    DROP PROCEDURE Student.uspGetSalesName;  
GO  
CREATE PROCEDURE Student.uspGetSalesName ( 
@SalesPersonID int = NULL  -- NULL default value / заменить на 1 тогда не будет ошибки
)
AS   
    SET NOCOUNT ON;   
-- Проверка параметра @SalesPerson .  
IF @SalesPersonID IS NULL  
	BEGIN  
	   PRINT N'ОШИБКА: Неоходимо передать идентификатор сотрудника.'  
	   RETURN  -- не обрабатываем дальше код. Команда Возврата
	END     
-- Присвоение выходному параметру output parameter.  
SELECT FullName,*  
FROM   Application.People AS p   
WHERE  p.PersonID = @SalesPersonID  
-- принудительный возврат значения из хранимой процедуры командой Return	   
RETURN  
GO  

-- Проверка 
-- 1 Запуск процедуры без входящего параметра.  
EXEC Student.uspGetSalesName;  
GO  

-- 2 Запуск процедуры с входящим параметром.  
EXEC Student.uspGetSalesName @SalesPersonID = 18;  
GO  

-- точные имена системных процедур
select * from sys.system_objects
-- и передаваемые параметры
select * from sys.system_parameters

--Указание направления параметров
IF OBJECT_ID ( 'Student.uspGetList', 'P' ) IS NOT NULL   
    DROP PROCEDURE Student.uspGetList;  
GO  
CREATE PROCEDURE Student.uspGetList 
     @Product varchar(40)   
    , @MaxPrice money   
    , @ComparePrice money OUTPUT -- выходной параметр 
    , @ListPrice money OUT       -- тоже выходной, но запись короче
AS  
    SET NOCOUNT ON;  
    SELECT si.[StockItemName] AS Product, si.UnitPrice AS 'List Price'  
    FROM Warehouse.StockItems AS si  
    WHERE si.[StockItemName] LIKE @Product AND si.UnitPrice < @MaxPrice;  
-- Заполнение output переменной  @ListPprice.  
SET @ListPrice = (SELECT MAX(si.UnitPrice)  
        FROM Warehouse.StockItems AS si   
        WHERE si.[StockItemName] LIKE @Product AND si.UnitPrice < @MaxPrice);  
-- Заполнение output переменной @compareprice.   
SET @ComparePrice = @MaxPrice;  
GO  



--Имена параметра и переменной не должны совпадать 
DECLARE @ComparePrice money, @Cost money ;  
EXECUTE Student.uspGetList '%10 mm Double%', 200,   
    @ComparePrice OUT,   
    @Cost OUTPUT  
IF @Cost <= @ComparePrice   
BEGIN  
    PRINT 'These products can be purchased for less than   
    $'+RTRIM(CAST(@ComparePrice AS varchar(20)))+'.'  
END  
ELSE  
    PRINT 'The prices for all products in this category exceed   
    $'+ RTRIM(CAST(@ComparePrice AS varchar(20)))+'.';   
  

--Предоставление разрешений на хранимую процедуру
USE WideWorldImporters;   
GRANT EXECUTE ON OBJECT::Student.uspGetList  
    TO guest;  --user in database
GO  

--Использование входного параметра, выходного параметра и кода возврата  
USE WideWorldImporters;   
GO  
-- Создание процедуры, которая принимает input параметр, возвращает output параметр и код возврата.
CREATE PROCEDURE [Student].SampleProcedure 
		@PersonIDParm INT,
        @MaxTotal Date OUTPUT
AS
-- Объявление и инициализация переменной @@ERROR.
DECLARE @ErrorSave INT
SET @ErrorSave = 0

-- SELECT с использованием input параметра.
SELECT PreferredName, FullName
FROM Application.People
WHERE PersonID = @PersonIDParm

-- Save any nonzero @@ERROR value.
IF (@@ERROR <> 0)
   SET @ErrorSave = @@ERROR

-- Set a value in the output parameter.
SELECT @MaxTotal = MAX(OrderDate)
FROM Sales.Orders;

IF (@@ERROR <> 0)
   SET @ErrorSave = @@ERROR

-- Возвращает 0 если  SELECT содержит ошибку (error); иначе возвращает посленюю ошибку.
RETURN @ErrorSave
GO


--Обработка ошибок 
-- создаем таблицу для тестов
CREATE TABLE [dbo].[Workload](
	[WorloadID] [bigint] NULL,
	[WorkloadName] [nchar](10) NULL
) ON [PRIMARY]
GO

-- что будет если заменить Test на NEWID()?
BEGIN TRY
	INSERT INTO [dbo].[Workload] values(1,'Test')
	PRINT N'Данные удачно вставились'
END TRY
BEGIN CATCH
	PRINT 'ERROR' + CONVERT(VARCHAR, ERROR_NUMBER()) + ':' + ERROR_MESSAGE()
END CATCH

-- c @@ERROR и RAISERROR
-- https://docs.microsoft.com/ru-ru/sql/t-sql/language-elements/raiserror-transact-sql?view=sql-server-ver15
BEGIN TRY
	INSERT INTO [dbo].[Workload] values('Test',1)
END TRY
BEGIN CATCH
	--PRINT  @@ERROR -- 8114  Код ошибки
	RAISERROR (15600,-1,10, 'myStoreProcedure') ;--  15600 Код ошибки; 
												-- - 1 severity Уровень серьезности читать документацию; 
												-- 10- статус (Целое число от 0 до 255)
END CATCH


--Возврат данных с использованием кода возврата
USE WideWorldImporters;     
GO  
IF OBJECT_ID('Student.usp_GetSalesName', 'P') IS NOT NULL  
    DROP PROCEDURE Student.usp_GetSalesName;  
GO  
CREATE PROCEDURE Student.usp_GetSalesName  
@SalesPerson int = NULL,  -- NULL default value  
@SalesName varchar(50) = NULL OUTPUT  
AS    
-- Validate the @SalesPerson parameter.  
IF @SalesPerson IS NULL  
   BEGIN  
       PRINT 'ERROR: You must specify a last name for the sales person.'  
       RETURN(1)  -- Возвращенное значение 1
   END  
ELSE  
   BEGIN  
   -- Make sure the value is valid.  
   IF (SELECT COUNT(*) FROM Application.People  
          WHERE PersonID = @SalesPerson) = 0  
      RETURN(2)  -- Возвращенное значение 2
   END  
-- Назначаем параметру значение и отдаем    
--  output параметр.  
SELECT @SalesName = FullName   
FROM Application.People AS sp   
WHERE PersonID = @SalesPerson;  
-- Проверяем ошибки SQL Server .  
IF @@ERROR <> 0   
   BEGIN  
      RETURN(3)  -- Возвращенное значение 3
   END  
ELSE  
   BEGIN  
   -- Првоеряем значение на NULL.  
     IF @SalesName IS NULL  
       RETURN(4)   -- Возвращенное значение 4
     ELSE  
      -- SUCCESS!!  
        RETURN(0)  -- Возвращенное значение 0
   END 


--Перекомпиляция хранимой процедуры
USE WideWorldImporters;  
GO  
IF OBJECT_ID ( 'Student.uspProductByCustomers', 'P' ) IS NOT NULL   
    DROP PROCEDURE Student.uspProductByCustomers;  
GO  
CREATE PROCEDURE Student.uspProductByCustomers @Name varchar(30) = '%'  
WITH RECOMPILE  
AS  
    SET NOCOUNT ON;  
    SELECT c.CustomerName AS 'Suct name', ol.StockItemID AS 'Product id'  
    FROM Sales.Customers AS c   
    JOIN Sales.Orders AS so   
      ON so.CustomerID = c.CustomerID   
    JOIN Sales.OrderLines AS ol   
      ON ol.OrderID = ol.OrderID  
    WHERE c.CustomerName LIKE @Name;   

  
EXECUTE Student.uspProductByCustomers  WITH RECOMPILE;  
GO  


--Просмотр определения хранимой процедуры
USE WideWorldImporters;  
GO 
-- 1) 
EXEC sp_helptext N'WideWorldImporters.Student.uspProductByCustomers';

--2)
SELECT OBJECT_DEFINITION (OBJECT_ID(N'WideWorldImporters.Student.uspProductByCustomers'));

--3)
USE WideWorldImporters;  
GO  
SELECT definition  
FROM sys.sql_modules  
WHERE object_id = (OBJECT_ID(N'WideWorldImporters.Student.uspProductByCustomers'));

--Просмотр зависимостей хранимой процедуры
USE WideWorldImporters;  
GO  
IF OBJECT_ID ( 'Student.uspCustomerAllInfo', 'P' ) IS NOT NULL   
    DROP PROCEDURE Student.uspCustomerAllInfo;  
GO  
CREATE PROCEDURE Student.uspCustomerAllInfo  
WITH EXECUTE AS CALLER --выполняются от имени вызывающей стороны родительской процедуры 
AS  
    SET NOCOUNT ON;  
    SELECT c.CustomerName AS Customer, ol.StockItemID AS 'Product id'  
    FROM Sales.Customers AS c   
    JOIN Sales.Orders AS so   
      ON so.CustomerID = c.CustomerID   
    JOIN Sales.OrderLines AS ol   
      ON ol.OrderID = ol.OrderID  
    ORDER BY c.CustomerName ASC;   
GO     

-- 1) объекты, зависящие от процедуры
  SELECT referencing_schema_name, referencing_entity_name, referencing_id, referencing_class_desc, is_caller_dependent  
FROM sys.dm_sql_referencing_entities ('Student.uspCustomerAllInfo', 'OBJECT');   
GO    


-- 2)на какие таблицы ссылается хранимая процедура
 SELECT referenced_entity_name AS table_name, referenced_minor_name as column_name, is_selected, is_updated, is_select_all  
FROM sys.dm_sql_referenced_entities ('Student.uspCustomerAllInfo', 'OBJECT');   
GO   

-- RESULT SET для оператора EXECUTE. 
--запрос 
SELECT FULLNAME AS 'Bus Name', EMAILADDRESS AS 'mail'   FROM Application.People;
--трансофрмируем в 
EXEC ('SELECT FULLNAME, EMAILADDRESS  FROM Application.People')
WITH RESULT SETS
(
	([Bus Name] varchar(50) NOT NULL,
	 [mail] varchar(256) 
	)
);

--как быть если надо вернуть несколько результатов (data sets) из одной хранимой процедуры
--Возвращаем два набора данных из одной хранимой процедуры 
CREATE PROC student.GetSales
AS
SELECT ORDERID +' '+CAST(CUSTOMERID AS VARCHAR(20)) FROM SALES.ORDERS
SELECT STOCKITEMID , UNITPRICE FROM SALES.ORDERLINES 
Return 
GO

-- Использовать Result set!
EXEC student.GetSales
WITH RESULT SETS
( 
	(
		[ID and Customer] varchar (100) -- из первого набора данных : FROM SALES.ORDERS
	),
	(	
		[ItemId] VARCHAR(25),-- из второго набора данных, но с другими алиасами : FROM SALES.ORDERLINES 
		[Price]  Money
	)
)
