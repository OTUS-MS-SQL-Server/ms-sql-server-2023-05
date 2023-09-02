USE WideWorldImporters;
GO

DECLARE @RowCount INT = 50000;

DECLARE @i INT = 1;  
BEGIN TRAN;
  WHILE @i <= @RowCount  
  BEGIN;  
    INSERT INTO Sales.OrdersDisk
    (OrderLineID, OrderId, StockItemID, Quantity) 
    VALUES (@i, @i, @i, @i*10);  
    SET @i += 1;  
  END;  
COMMIT;
GO
  --2 sec
-- Проверим, что данные вставились
SELECT COUNT(*) FROM Sales.OrdersDisk;
GO

-- Через хранимую процедуру
CREATE OR ALTER PROCEDURE Sales.OrdersDisk_Insert
    @RowCount INT 
AS   
BEGIN      
  
  DECLARE @i INT = 1;  
  WHILE @i <= @RowCount  
  BEGIN;  
    INSERT INTO Sales.OrdersDisk
    (OrderLineID, OrderId, StockItemID, Quantity) 
    VALUES (@i, @i, @i, @i*10);  
    SET @i += 1;  
  END;  
END;
GO

-- Очищаем таблицу
DELETE FROM Sales.OrdersDisk
GO

-- Проверяем
SELECT COUNT(*) FROM Sales.OrdersDisk;
GO

-- Запускаем хранимую процедуру
EXEC Sales.OrdersDisk_Insert @RowCount = 50000;
--18 s
-- Проверяем
SELECT COUNT(*) FROM Sales.OrdersDisk;
GO


