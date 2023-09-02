--query hints
--------------------------
use WideWorldImporters;

set statistics time on;
set statistics io on;

begin --optimize for (при неравномерном распределении данных)
	drop table if exists t1
	drop table if exists t2

	create table t1 (id int not null primary key, name varchar(100));
	create table t2(id int not null, t1_id int not null);

	create unique clustered index idx_t2_t1_id_id on t2(t1_id, id);

	insert t1 (id, name) --50 тыс
	select row_number() over(order by 1/0), concat('name ', row_number() over(order by 1/0))
	from string_split(space(999), ' ') t1 
	cross join string_split(space(49), ' ') t2

	insert t2(id, t1_id)
	select row_number() over(order by 1/0) , t1.id
	from t1 
	cross join string_split(space(9), ' ')

	--неравномерность - обычно t2.id встречается 50 тыс
	insert t2(id, t1_id) values(-1, -1)
	insert t1(id) values(-1)
	

	--большая часть данных равномерно распределена 
	select *
	from t2 
	inner join t1 on t1.id = t2.t1_id
	where t2.id < 10000

	--вкл план запроса
	--дб 1 строка (значение выбивается из распределения)
	select *
	from t2 
	inner join t1 on t1.id = t2.t1_id
	where t2.id < 0

	--запрос с параметрами - для типичных данных
	declare @id1 int = 0
	select *
	from t2 
	inner join t1 on t1.id = t2.t1_id
	where t2.id < @id1

	--укажем, для каких параметров оптимизировать
	declare @id2 int = 0
	select *
	from t2 
	inner join t1 on t1.id = t2.t1_id
	where t2.id < @id2
	option (optimize for (@id2 = 0))

	--unknown - среднестатистический параметр
	declare @id3 int = 0
	select *
	from t2 
	inner join t1 on t1.id = t2.t1_id
	where t2.id < @id3
	option (optimize for unknown)
end 

begin --use plan
	--OPTION(USE PLAN) - план посмотреть в 00_ad_hoc_plan_cashe.sql
	
	declare @id4 int = 0
	select *
	from t2 
	inner join t1 on t1.id = t2.t1_id
	where t2.id < @id4

	option (use plan N'<ShowPlanXML xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.564" Build="16.0.1050.5"><BatchSequence><Batch><Statements><StmtSimple StatementText="&#x9;declare @id2 int = 0&#xD;&#xA;&#x9;" StatementId="1" StatementCompId="1" StatementType="ASSIGN" RetrievedFromCache="true" /><StmtSimple StatementText="select *&#xD;&#xA;&#x9;from t2 &#xD;&#xA;&#x9;inner join t1 on t1.id = t2.t1_id&#xD;&#xA;&#x9;where t2.id &lt; @id2&#xD;&#xA;&#x9;option (optimize for (@id2 = 0))" StatementId="2" StatementCompId="2" StatementType="SELECT" StatementSqlHandle="0x09000B797E77A3B24C9A4B4D6E4C025F24300000000000000000000000000000000000000000000000000000" DatabaseContextSettingsId="8" ParentObjectId="0" StatementParameterizationType="0" RetrievedFromCache="true" StatementSubTreeCost="1.57509" StatementEstRows="1" SecurityPolicyApplied="false" StatementOptmLevel="FULL" QueryHash="0x8B80996EFA40A776" QueryPlanHash="0x786687712A546D28" CardinalityEstimationModelVersion="130"><StatementSetOptions QUOTED_IDENTIFIER="true" ARITHABORT="true" CONCAT_NULL_YIELDS_NULL="true" ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" NUMERIC_ROUNDABORT="false" /><QueryPlan CachedPlanSize="24" CompileTime="11" CompileCPU="10" CompileMemory="240"><MissingIndexes><MissingIndexGroup Impact="82.3334"><MissingIndex Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]"><ColumnGroup Usage="INEQUALITY"><Column Name="[id]" ColumnId="1" /></ColumnGroup></MissingIndex></MissingIndexGroup></MissingIndexes><MemoryGrantInfo SerialRequiredMemory="0" SerialDesiredMemory="0" GrantedMemory="0" MaxUsedMemory="0" /><OptimizerHardwareDependentProperties EstimatedAvailableMemoryGrant="125824" EstimatedPagesCached="31456" EstimatedAvailableDegreeOfParallelism="2" MaxCompileMemory="2131232" /><OptimizerStatsUsage><StatisticsInfo LastUpdate="2023-09-02T11:05:18.23" ModificationCount="0" SamplingPercent="100" Statistics="[PK__t1__3213E83F70B1D652]" Table="[t1]" Schema="[dbo]" Database="[WideWorldImporters]" /><StatisticsInfo LastUpdate="2023-09-02T11:05:19.79" ModificationCount="0" SamplingPercent="100" Statistics="[idx_t2_t1_id_id]" Table="[t2]" Schema="[dbo]" Database="[WideWorldImporters]" /><StatisticsInfo LastUpdate="2023-09-02T11:05:17.20" ModificationCount="0" SamplingPercent="100" Statistics="[_WA_Sys_00000001_3C89F72A]" Table="[t2]" Schema="[dbo]" Database="[WideWorldImporters]" /></OptimizerStatsUsage><RelOp NodeId="0" PhysicalOp="Nested Loops" LogicalOp="Inner Join" EstimateRows="1" EstimateIO="0" EstimateCPU="4.18e-06" AvgRowSize="73" EstimatedTotalSubtreeCost="1.57509" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]" Column="id" /><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]" Column="t1_id" /><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t1]" Column="id" /><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t1]" Column="name" /></OutputList><NestedLoops Optimized="0"><OuterReferences><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]" Column="t1_id" /></OuterReferences><RelOp NodeId="1" PhysicalOp="Clustered Index Scan" LogicalOp="Clustered Index Scan" EstimateRows="1" EstimatedRowsRead="500001" EstimateIO="0.781644" EstimateCPU="0.550158" AvgRowSize="15" EstimatedTotalSubtreeCost="1.3318" TableCardinality="500001" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]" Column="id" /><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]" Column="t1_id" /></OutputList><IndexScan Ordered="0" ForcedIndex="0" ForceScan="0" NoExpandHint="0" Storage="RowStore"><DefinedValues><DefinedValue><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]" Column="id" /></DefinedValue><DefinedValue><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]" Column="t1_id" /></DefinedValue></DefinedValues><Object Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]" Index="[idx_t2_t1_id_id]" IndexKind="Clustered" Storage="RowStore" /><Predicate><ScalarOperator ScalarString="[WideWorldImporters].[dbo].[t2].[id]&lt;[@id2]"><Compare CompareOp="LT"><ScalarOperator><Identifier><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]" Column="id" /></Identifier></ScalarOperator><ScalarOperator><Identifier><ColumnReference Column="@id2" /></Identifier></ScalarOperator></Compare></ScalarOperator></Predicate></IndexScan></RelOp><RelOp NodeId="2" PhysicalOp="Clustered Index Seek" LogicalOp="Clustered Index Seek" EstimateRows="1" EstimatedRowsRead="1" EstimateIO="0.003125" EstimateCPU="0.0001581" AvgRowSize="65" EstimatedTotalSubtreeCost="0.0032831" TableCardinality="50001" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t1]" Column="id" /><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t1]" Column="name" /></OutputList><IndexScan Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore"><DefinedValues><DefinedValue><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t1]" Column="id" /></DefinedValue><DefinedValue><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t1]" Column="name" /></DefinedValue></DefinedValues><Object Database="[WideWorldImporters]" Schema="[dbo]" Table="[t1]" Index="[PK__t1__3213E83F70B1D652]" IndexKind="Clustered" Storage="RowStore" /><SeekPredicates><SeekPredicateNew><SeekKeys><Prefix ScanType="EQ"><RangeColumns><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t1]" Column="id" /></RangeColumns><RangeExpressions><ScalarOperator ScalarString="[WideWorldImporters].[dbo].[t2].[t1_id]"><Identifier><ColumnReference Database="[WideWorldImporters]" Schema="[dbo]" Table="[t2]" Column="t1_id" /></Identifier></ScalarOperator></RangeExpressions></Prefix></SeekKeys></SeekPredicateNew></SeekPredicates></IndexScan></RelOp></NestedLoops></RelOp><ParameterList><ColumnReference Column="@id2" ParameterDataType="int" ParameterCompiledValue="(0)" /></ParameterList></QueryPlan></StmtSimple></Statements></Batch></BatchSequence></ShowPlanXML>')
end


begin --recompile с хп или option (recompile)
	--для хп или параметризированных запросов создает новый план выполнения запроса
	-- recompile (универсальная хп CustomerSearch_KitchenSink - фильтры в зависимости от параметорв) 

	-- Подготовка - отключим контроль прав доступа к Sales.Customers 
	alter security policy Application.FilterCustomersBySalesTerritoryRole with (state = off)

	--включить
	--alter security policy Application.FilterCustomersBySalesTerritoryRole with (state = on)

	--запрос по всей таблице Customers
	exec CustomerSearch_KitchenSink
			@CustomerID = NULL,
			@CustomerName = NULL,
			@BillToCustomerID = NULL,
			@CustomerCategoryID = NULL,
			@BuyingGroupID = NULL,
			@MinAccountOpenedDate = NULL,
			@MaxAccountOpenedDate = NULL,
			@DeliveryCityID = NULL,
			@IsOnCreditHold = NULL
			--WITH RECOMPILE
	
	--запрос по 1 клиенту (неоптимальный план)
	--запрос по 1 клиенту + recompile (оптимальный план)
	exec CustomerSearch_KitchenSink
			@CustomerID = 5,
			@CustomerName = NULL,
			@BillToCustomerID = NULL,
			@CustomerCategoryID = NULL,
			@BuyingGroupID = NULL,
			@MinAccountOpenedDate = NULL,
			@MaxAccountOpenedDate = NULL,
			@DeliveryCityID = NULL,
			@IsOnCreditHold = NULL
			WITH RECOMPILE

end 

begin --maxdop
	--maxdop 1 - на небольших таблицах или при нехватеке памяти
	select People.FullName, max(Inv.InvoiceDate)
	from Sales.Invoices as Inv
	inner join Application.People as People ON People.PersonID = Inv.SalespersonPersonID
	group by People.FullName

	select People.FullName, max(Inv.InvoiceDate)
	from Sales.Invoices AS Inv
	inner join Application.People AS People ON People.PersonID = Inv.SalespersonPersonID
	group by People.FullName
	option (maxdop 1)
end 

begin --max recursion
	--заполнить таблицу датами за 180 дней
	; with cte as (
		select cast(getdate() as date) as dt, 1 as i 
		union all
		select dateadd(dd, 1, dt), i + 1 from cte where i < 180
	)
	select * from cte
	option (maxrecursion 180)
end 

begin --IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX
	--если есть подходящий не колоночный индекс
	exec sp_helpindex 'Sales.OrderLines'

	select avg(l.PickedQuantity)
	from Sales.OrderLines as l
	inner join Warehouse.PackageTypes as pt on pt.PackageTypeID = l.PackageTypeID
	where l.StockItemID = 1
	group by pt.PackageTypeName

	select avg(l.PickedQuantity)
	from Sales.OrderLines as l
	inner join Warehouse.PackageTypes as pt on pt.PackageTypeID = l.PackageTypeID
	where l.StockItemID = 1
	option (ignore_nonclustered_columnstore_index)
end 

begin --force order - порядок выполнения соединений
	--? есть ли разница в порядке выполнения?
	select so.OrderID, li.OrderLineID
	from Sales.Orders AS so
	inner join Sales.OrderLines AS li ON so.OrderID = li.OrderID
	where so.CustomerID = 832 AND so.SalespersonPersonID = 2


	select so.OrderID, li.OrderLineID
	from Sales.OrderLines AS li
	inner join Sales.Orders AS so ON li.OrderID = so.OrderID
	where so.CustomerID = 832 AND so.SalespersonPersonID = 2

	--




	--принцип соединения и фильтрации - на первом шаге используем фильтр, отсекающий самое большое кол-во строк
	--какой из запросов выполнится быстрее?
	select so.OrderID, li.OrderLineID
	from Sales.Orders AS so
	inner join Sales.OrderLines AS li ON so.OrderID = li.OrderID
	where so.CustomerID = 832 AND so.SalespersonPersonID = 2
	option (force order)


	select so.OrderID, li.OrderLineID
	from Sales.OrderLines AS li
	inner join Sales.Orders AS so ON li.OrderID = so.OrderID
	where so.CustomerID = 832 AND so.SalespersonPersonID = 2
	option (force order)

end