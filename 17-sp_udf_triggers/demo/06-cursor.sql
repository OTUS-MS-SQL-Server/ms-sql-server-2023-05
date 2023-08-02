
--общераспространенный пример курсора с использованием хранимой процедуры:
USE WideWorldImporters;   
GO  
IF OBJECT_ID ( 'Student.uspCitiesCursor', 'P' ) IS NOT NULL  
    DROP PROCEDURE Student.uspCitiesCursor;  
GO  
CREATE PROCEDURE Student.uspCitiesCursor   
    @CityCursor CURSOR VARYING OUTPUT  
AS  
    SET NOCOUNT ON;  
    SET @CityCursor = CURSOR  
    FORWARD_ONLY STATIC FOR  
      SELECT CityID, CityName  
      FROM Application.Cities;  
    OPEN @CityCursor;  
GO  

--пакет, который объявляет локальную переменную курсора, выполняет процедуру
USE WideWorldImporters;     
GO  
DECLARE @MyCursor CURSOR; -- объявляем переменную определенного типа 
-- вызываем хранимую процедуру получаем из него курсор
EXEC Student.uspCitiesCursor @CityCursor = @MyCursor OUTPUT;  
WHILE (@@FETCH_STATUS = 0)  -- цикл до последней строчки из запроса
BEGIN;  
     FETCH NEXT FROM @MyCursor;  -- получение значения курсора
END;  
CLOSE @MyCursor;  
DEALLOCATE @MyCursor;  
GO    



------------------------------------------------
-- разъяснение по курсору


USE WideWorldImporters;

-- Подготовка:
-- Удалим кластерный колоночный индекс, создадим обычный строковый.
-- (курсоры не поддерживаются для таблиц с кластерным колоночным индексом)
-- Cursors are not supported on a table which has a clustered columnstore index.

/*
DROP INDEX CCX_Warehouse_StockItemTransactions ON Warehouse.StockItemTransactions;
GO

CREATE CLUSTERED INDEX CX_Warehouse_StockItemTransactions_StockItemTransactionID 
ON Warehouse.StockItemTransactions(StockItemTransactionID);
GO
*/
-- Задача:
-- Просто проитетрироваться по всем StockItemTransactions

-- Объявление курсора
DECLARE TransactionsCursor CURSOR FOR
	SELECT si.StockItemTransactionID
	FROM Warehouse.StockItemTransactions si
	-- 236 667 записей

-- Открытие курсора
OPEN TransactionsCursor;

-- (Переменные для хранения промежуточных результатов)
DECLARE @StockItemTransactionID INT

-- Переход на первую строку курсора с одновременным чтением из столбцов запроса
FETCH FROM TransactionsCursor INTO @StockItemTransactionID

-- Цикл по строкам
WHILE @@FETCH_STATUS = 0 
BEGIN
    -- Здесь может быть какая-то логика
	-- ...
	-- PRINT @StockItemTransactionID

	-- Перемещаемся на следующую строку курсора
	FETCH FROM TransactionsCursor INTO @StockItemTransactionID
END

-- Закрытие курсора
CLOSE TransactionsCursor

-- Удаление курсора
DEALLOCATE TransactionsCursor

-- Смотрим сколько времени заняла простая итерация по 236 667 записям



-- Пример самый быстрый вариант--------------------
DECLARE TransactionsCursor CURSOR FAST_FORWARD FOR

-- -------------------------------
-- Пример изменение данных
-- -------------------------------

-- Увеличим стоимость на 10%
PRINT '--- 6 UPDATE ---'
UPDATE Warehouse.StockItems
SET UnitPrice = 1.1 * UnitPrice
WHERE CURRENT OF StockItemsCursor








