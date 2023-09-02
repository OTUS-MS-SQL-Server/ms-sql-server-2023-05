--join hints
--------------------------------
/*
����� �������� - ����� ���� ���������� ���������� ������ �������?
���������� ������������ 1 �� 3� ����� ���������� ���������� ��� ����������� ����������
���� ����� ������������ ��� ���������� �������� ���-�� ������, ���� ��� ad-hoc 

������ ���� ���������
https://statisticsparser.com/
*/
-- ���������� - �������� �������� ���� ������� � Sales.Customers 

--��������
--ALTER SECURITY POLICY Application.FilterCustomersBySalesTerritoryRole WITH (STATE = ON)

select CustomerID from Sales.Customers where CustomerID = 7 --���� �������
ALTER SECURITY POLICY Application.FilterCustomersBySalesTerritoryRole WITH (STATE = OFF)


set statistics time on;
set statistics io on;

use WideWorldImporters;

begin

	-- ��������� ������ ������� �������� � ������� ���������� � �����������
	select Client.CustomerName, Inv.InvoiceID, Inv.InvoiceDate, Item.StockItemName, Details.Quantity, Details.UnitPrice, PayClient.CustomerName as BillForCustomer
	from Sales.Invoices as Inv
	inner join Sales.InvoiceLines as Details on Inv.InvoiceID = Details.InvoiceID
	inner join Sales.Customers as Client on Client.CustomerID = Inv.CustomerID
	inner join Sales.Customers as PayClient on PayClient.CustomerID = Inv.BillToCustomerID
	inner join Warehouse.StockItems as Item on Item.StockItemID = Details.StockItemID
	where Client.CustomerID = 1


	select Client.CustomerName, Inv.InvoiceID, Inv.InvoiceDate, Item.StockItemName, Details.Quantity, Details.UnitPrice, PayClient.CustomerName as BillForCustomer
	from Sales.Invoices as Inv
	inner MERGE join Sales.InvoiceLines as Details on Inv.InvoiceID = Details.InvoiceID
	inner HASH join Sales.Customers as Client on Client.CustomerID = Inv.CustomerID
	inner join Sales.Customers as PayClient on PayClient.CustomerID = Inv.BillToCustomerID
	inner join Warehouse.StockItems as Item on Item.StockItemID = Details.StockItemID
	where Client.CustomerID = 1
	
	-----
	--��������� - �������������� ������� ���������� (loop)
	select Client.CustomerName, Inv.InvoiceID, Inv.InvoiceDate, Item.StockItemName, Details.Quantity, Details.UnitPrice, PayClient.CustomerName as BillForCustomer
	from Sales.Invoices as Inv
	inner join Sales.InvoiceLines as Details on Inv.InvoiceID = Details.InvoiceID
	inner loop join Sales.Customers as Client on Client.CustomerID = Inv.CustomerID
	--inner join Application.People as People on People.PersonID = Inv.SalespersonPersonID
	inner join Sales.Customers as PayClient on PayClient.CustomerID = Inv.BillToCustomerID
	inner join Warehouse.StockItems as Item on Item.StockItemID = Details.StockItemID
	where Inv.CustomerID = 1

	select Client.CustomerName, Inv.InvoiceID, Inv.InvoiceDate, Item.StockItemName, Details.Quantity, Details.UnitPrice, PayClient.CustomerName as BillForCustomer
	from Sales.Invoices as Inv
	inner join Sales.InvoiceLines as Details on Inv.InvoiceID = Details.InvoiceID
	inner join Sales.Customers as Client on Client.CustomerID = Inv.CustomerID
	inner join Sales.Customers as PayClient on PayClient.CustomerID = Inv.BillToCustomerID
	inner join Warehouse.StockItems as Item on Item.StockItemID = Details.StockItemID
	where Inv.CustomerID = 1

	select Client.CustomerName, Inv.InvoiceID, Inv.InvoiceDate, Item.StockItemName, Details.Quantity, Details.UnitPrice, PayClient.CustomerName as BillForCustomer
	from Sales.Invoices as Inv
	inner join Sales.InvoiceLines as Details on Inv.InvoiceID = Details.InvoiceID
	inner join Sales.Customers as Client on Client.CustomerID = Inv.CustomerID
	inner join Sales.Customers as PayClient on PayClient.CustomerID = Inv.BillToCustomerID
	inner join Warehouse.StockItems as Item on Item.StockItemID = Details.StockItemID
	where Inv.CustomerID = 1
	option (hash join)

	--join HINT
	select Inv.InvoiceID, Inv.InvoiceDate, Details.Quantity, Details.UnitPrice
	from Sales.Invoices as Inv
	inner join Sales.InvoiceLines as Details on Inv.InvoiceID = Details.InvoiceID;

	select Inv.InvoiceID, Inv.InvoiceDate, Details.Quantity, Details.UnitPrice
	from Sales.Invoices as Inv
	inner MERGE join Sales.InvoiceLines as Details on Inv.InvoiceID = Details.InvoiceID;

	select Inv.InvoiceID, Inv.InvoiceDate, Details.Quantity, Details.UnitPrice
	from Sales.Invoices as Inv
	inner LOOP join Sales.InvoiceLines as Details on Inv.InvoiceID = Details.InvoiceID;

	--hash �������� �� ����������� �������
	select Inv.InvoiceID, Inv.InvoiceDate, Details.Quantity, Details.UnitPrice
	from Sales.Invoices as Inv
	inner HASH join Sales.InvoiceLines as Details on Inv.InvoiceID = Details.InvoiceID;

	--������� �� ���-�� ������ (���� ������� - ���� �����������)
	--��������� ���-�� ������ ��� ���������� - parser
	select People.FullName, Inv.InvoiceID, Inv.InvoiceDate
	from Sales.Invoices as Inv
	inner LOOP join Application.People as People on People.PersonID = Inv.SalespersonPersonID;

	select People.FullName, Inv.InvoiceID, Inv.InvoiceDate
	from Sales.Invoices as Inv
	left LOOP join Application.People as People on People.PersonID = Inv.SalespersonPersonID;

end

begin --����������
	--���������� ���� ���������� � �����������

	select distinct o.ContactPersonID, po.ContactPersonID 
	from Sales.Orders as o
	full join Purchasing.PurchaseOrders as po on po.ContactPersonID = o.ContactPersonID

	select distinct o.ContactPersonID, po.ContactPersonID 
	from Sales.Orders as o
	left loop join Purchasing.PurchaseOrders as po on po.ContactPersonID = o.ContactPersonID

	select distinct o.ContactPersonID, po.ContactPersonID 
	from Sales.Orders as o
	right join Purchasing.PurchaseOrders as po on po.ContactPersonID = o.ContactPersonID

	--����������
	select distinct o.ContactPersonID, po.ContactPersonID 
	from Sales.Orders as o
	right loop join Purchasing.PurchaseOrders as po on po.ContactPersonID = o.ContactPersonID

end