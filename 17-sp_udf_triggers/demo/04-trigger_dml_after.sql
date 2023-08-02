use SP
go
Create table TriggerTable (Name varchar(50))
Create table TriggerTableLog (Name varchar(50))

CREATE TRIGGER TriggerTable_Update
ON TriggerTable
 AFTER UPDATE --AFTER |INSTEAD OF 
AS
	INSERT INTO TriggerTableLog(Name)
	SELECT Name
	FROM INSERTED

-- вставляем тестовое значение
INSERT INTO TriggerTable(Name) VALUES ('first go')

update TriggerTable 
set Name ='second go'

select * from TriggerTable
select * from TriggerTableLog

--tranaction
-- изменим тригер
ALTER TRIGGER TriggerTable_Update
ON TriggerTable
 AFTER  UPDATE --AFTER |INSTEAD OF !!!!
AS
	--rollback tran;
	INSERT INTO TriggerTableLog(Name)
	SELECT Name
	FROM INSERTED

-- запустим транзакцию
begin tran
update TriggerTable 
set Name ='transaction'
rollback -- rollback commit !!!

-- INSTEAD OF в тригере и раскоментить rollback tran;  commit в транзакции = пройдет запись
-- AFTER в тригере и закоментить --rollback tran; rollback в транзакции    = не пройдет запись

delete from TriggerTableLog



-- еще один пример
--/////////////////////////////
USE WideWorldImporters;
GO

-- ----------------------
-- AFTER
-- ----------------------
-- DROP TRIGGER Warehouse.TR_StockItems_UPDATE;

CREATE TRIGGER TR_StockItems_UPDATE
ON Warehouse.StockItems
AFTER UPDATE
AS
BEGIN
	IF (ROWCOUNT_BIG() = 0)
		RETURN;
	-- ROWCOUNT_BIG() - https://docs.microsoft.com/en-us/sql/t-sql/statements/create-trigger-transact-sql?view=sql-server-ver15#optimizing-dml-triggers

	DECLARE @Inserted_StockItemID INT = (SELECT TOP 1 StockItemID FROM inserted);

	DECLARE @Msg NVARCHAR(1000) = CONCAT(
	' Inserted_StockItemID = ', @Inserted_StockItemID);

	RAISERROR(@Msg, 1, 1) WITH LOG;-- второй парамерт уровень ошибки. 1 информационная
END
GO

-- Проверяем триггер на UPDATE  (StockItemID = 1)
SELECT * FROM Warehouse.StockItems;

UPDATE Warehouse.StockItems
SET StockItemName = StockItemName + ' TEST' 
WHERE StockItemID = 1;

SELECT * FROM Warehouse.StockItems;

-- DML-триггеры в SSMS:
-- <Таблица> \ Triggers
