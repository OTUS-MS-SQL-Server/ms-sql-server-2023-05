USE SP;
GO

-- ----------------------
-- INSTEAD OF
-- ----------------------

-- Реализуем "мягкое" удаление (soft delete) в таблице [dbo].[TriggerTable]
-- Вместо удаления (DELETE) будем только помечать запись как удаленную

-- Добавим столбец Deleted

insert into  [dbo].[TriggerTable] values('one'),('two');

ALTER TABLE [dbo].[TriggerTable]
ADD Deleted BIT NULL;

SELECT TOP 2 *
FROM [dbo].[TriggerTable];

-- Создаем триггер
-- DROP TRIGGER Sales.TR_SpecialDeals_INSTEAD_DELETE

CREATE TRIGGER TR_TriggerTable_INSTEAD_DELETE
ON [dbo].[TriggerTable]
INSTEAD OF DELETE
AS
BEGIN
	UPDATE [dbo].[TriggerTable]
	SET Deleted = 1
	WHERE NAME = (SELECT NAME FROM deleted)
END

-- Проверяем работу триггера
SELECT TOP 5 *
FROM [dbo].[TriggerTable];

DELETE FROM [dbo].[TriggerTable] 
WHERE Name = 'one';

SELECT TOP 5 *
FROM [dbo].[TriggerTable];
