/*
-- не выполнять - уже все создано
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP WWI_UserData  
    CONTAINS MEMORY_OPTIMIZED_DATA;  

 -- не выполнять - уже все создано
ALTER DATABASE [WideWorldImporters] ADD FILE  
    (Name = demoim_file, Filename= 'e:\mssql2017\demoim')  
    TO FILEGROUP WWI_UserData;  
*/

USE WideWorldImporters;
GO

DROP PROCEDURE IF EXISTS Sales.OrdersMemory_SCHEMA_AND_DATA_Insert_Native;
DROP PROCEDURE IF EXISTS Sales.OrdersMemory_SCHEMA_ONLY_Insert;
DROP TABLE IF EXISTS Sales.OrdersDisk;
DROP TABLE IF EXISTS Sales.OrdersMemory_SCHEMA_AND_DATA;
DROP TABLE IF EXISTS Sales.OrdersMemory_SCHEMA_ONLY;
GO

-- Обычная таблица с хранением на диске
CREATE TABLE Sales.OrdersDisk
(
  OrderLineID INT NOT NULL,
  OrderID INT NOT NULL,
  StockItemID INT NOT NULL,
  Quantity INT NOT NULL,
  CONSTRAINT PK_Sales_OrderLinesD PRIMARY KEY CLUSTERED (OrderLineID ASC)
);
GO

-- Таблица в памяти SCHEMA_AND_DATA
CREATE TABLE Sales.OrdersMemory_SCHEMA_AND_DATA
(
  OrderLineID INT NOT NULL,
  OrderID INT NOT NULL,
  StockItemID INT NOT NULL,
  Quantity INT NOT NULL,
  CONSTRAINT PK_Sales_OrderLinesMO PRIMARY KEY NONCLUSTERED (OrderLineID ASC)
)
WITH (MEMORY_OPTIMIZED=ON, DURABILITY = SCHEMA_AND_DATA);
GO

-- Таблица в памяти SCHEMA_ONLY
CREATE TABLE Sales.OrdersMemory_SCHEMA_ONLY
(
  OrderLineID INT NOT NULL,
  OrderID INT NOT NULL,
  StockItemID INT NOT NULL,
  Quantity INT NOT NULL,
  CONSTRAINT PK_Sales_OrderLinesMO2 PRIMARY KEY NONCLUSTERED (OrderLineID ASC)
)  
WITH (MEMORY_OPTIMIZED=ON, DURABILITY = SCHEMA_ONLY);
GO

-- Как найти memory optimized таблицы
-- (в SSMS отображаются как обычные таблицы)
SELECT 
	SCHEMA_NAME(schema_id) as [Schema],
	[name] as [Table], 
	is_memory_optimized,
	durability_desc
FROM sys.tables
ORDER BY is_memory_optimized DESC;

-- Вставим данные и сравним производительность
-- (в других файлах)
