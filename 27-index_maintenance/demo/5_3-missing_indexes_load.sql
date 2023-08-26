-- пропущенные индексы (пример в SSMS) выполняется около 4 минут
-- собираем данные для использования кода 
--5_3-missing_indexes_script.sql

SELECT InvoiceDate
FROM Sales.Invoices
WHERE InvoiceDate = '2013-09-03';
go 300
