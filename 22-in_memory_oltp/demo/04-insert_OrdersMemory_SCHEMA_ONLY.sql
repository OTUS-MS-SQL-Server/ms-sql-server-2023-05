USE WideWorldImporters;
GO

DELETE FROM Sales.OrdersMemory_SCHEMA_ONLY;
GO

DECLARE @RowCount INT = 50000;

DECLARE @i INT = 1;  
BEGIN TRAN;
  WHILE @i <= @RowCount  
  BEGIN;  
    INSERT INTO Sales.OrdersMemory_SCHEMA_ONLY
    (OrderLineID, OrderId, StockItemID, Quantity) 
    VALUES (@i, @i, @i, @i*10);  
    SET @i += 1;  
  END;  
COMMIT;
GO
-- 2s
-- Проверим, что данные вставились
SELECT COUNT(*) FROM Sales.OrdersMemory_SCHEMA_ONLY;
GO

-- Нативная ХП
CREATE OR ALTER PROCEDURE Sales.OrdersMemory_SCHEMA_ONLY_Insert_Native
    @RowCount INT 
WITH NATIVE_COMPILATION, SCHEMABINDING 
AS   
BEGIN ATOMIC   
  WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')  
  
  DECLARE @i INT = 1;  
  WHILE @i <= @RowCount  
  BEGIN;  
    INSERT INTO Sales.OrdersMemory_SCHEMA_ONLY
    (OrderLineID, OrderId, StockItemID, Quantity) 
    VALUES (@i, @i, @i, @i*10);  
    SET @i += 1;  
  END;  
END;
GO

-- Очищаем таблицу
DELETE FROM Sales.OrdersMemory_SCHEMA_ONLY;
GO

-- Проверяем
SELECT COUNT(*) FROM Sales.OrdersMemory_SCHEMA_ONLY;
GO

-- Запускаем хранимую процедуру
EXEC Sales.OrdersMemory_SCHEMA_ONLY_Insert_Native @RowCount = 50000;

-- Проверяем
SELECT COUNT(*) FROM Sales.OrdersMemory_SCHEMA_ONLY;
GO



-- Обычная ХП
CREATE OR ALTER PROCEDURE Sales.OrdersMemory_SCHEMA_ONLY_Insert
    @RowCount INT 
AS   
BEGIN   
  DECLARE @i INT = 1;  
  WHILE @i <= @RowCount  
  BEGIN;  
    INSERT INTO Sales.OrdersMemory_SCHEMA_ONLY
    (OrderLineID, OrderId, StockItemID, Quantity) 
    VALUES (@i, @i, @i, @i*10);  
    SET @i += 1;  
  END;  
END;
GO


EXEC Sales.OrdersMemory_SCHEMA_ONLY_Insert @RowCount = 50000;
--3-4 s 