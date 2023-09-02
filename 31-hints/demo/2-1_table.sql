--table hints - используются чаще всего
--------------------------
use WideWorldImporters;

set statistics time on;
set statistics io on;

begin --index (таблица с колоночным индексом + существует подходящий индекс для поиска)
/* -
фильтр на колонку, по которой есть подходящий некластерный индекс
*/
	--план запроса - без хинта
	--посмотреть какие есть индексы
	select avg(l.PickedQuantity)
	from Sales.OrderLines as l
	where l.StockItemID = 1

	exec sp_helpindex 'Sales.OrderLines'

	--с хинтом
	select avg(l.PickedQuantity)
	from Sales.OrderLines as l with (index(IX_Sales_OrderLines_AllocatedStockItems)) 
	where l.StockItemID = 1

end

--------------------------
begin --index (аккуратно! индекс могут удалить)
	--аккуратно! (индекс могут удалить)
	alter index IX_Sales_OrderLines_AllocatedStockItems on Sales.OrderLines disable;

	SELECT avg(l.PickedQuantity)
	FROM Sales.OrderLines as l with (index(IX_Sales_OrderLines_AllocatedStockItems)) 
	where l.StockItemID = 1

	-- не забыть вернуть!
	alter index IX_Sales_OrderLines_AllocatedStockItems on Sales.OrderLines rebuild;

	/*
	with (index(...)) - используем аккуратно
	паттерны: 
	- в таблице есть подходящий некластерный индекс + колоночный некластерный индекс
	- устаревшая статистика (большая таблица + изменилась информация)
	*/ 
end

--

begin --noexpand/expand views - только для индексированных представлений!! 

	--обычно используют NOEXPAND, чтобы оптимизатор знал, что у нас есть индекс
	--noexpand (подсказка, что у нас есть индекс)
	select * 
	from AdventureWorks2017.Production.vProductAndDescription where CultureID = N'ar'
	
	select * 
	from AdventureWorks2017.Production.vProductAndDescription with (noexpand) where CultureID = N'ar'
end 


--------------------------
--гранулярность блокировки: rowlock / pagelock / tablock
--открыть 00_get locks on table.sql
--------------------------
begin 
	/*
	rowlock / pagelock - осторожно! 
	возможна эскалация блокировок (гранулярность поднимется на уровень таблицы)
	*/
	drop table if exists t

	create table t (
		id int
		, name varchar(100)
		, constraint pk_t primary key(id)
		)

	insert t (id, name) --1 млн строк
	select row_number() over(order by 1/0) , concat('name ', row_number() over(order by 1/0))
	from string_split(space(999), ' ') t1 
	cross join string_split(space(999), ' ') t2

	select count(*) from t

	-----
	begin tran 
		select count(*) from t with(rowlock, holdlock /*serializible*/) where id < 1e4 --10 тыс
		---------

		--другой сеанс! - попытка изменить запись с id = 1млн (предыдущий запрос ее не трогает)
		begin tran 
			update t set name = name + '' where id = 1e6 -- + посмотреть 
		--rollback

		--просмотр блокировок (блокировка на таблицу) 00_get locks on table

	--rollback
end 

--------------------------
-- уровень изоляции транзакций 
--------------------------
begin -- nolock
	--предыдущий пример
	begin tran 

		update t set name = name + ' ' where id = 500
		---------
		--другой сеанс!
		select id from t (nolock) where id = 500
		-- без nolock
		select id from t where id = 500
		
		--rollback

end

begin --tablockx - эксклюзивная блокировка всей таблицы
	--типовой шаблон использования
	drop table if exists t1
	create table t1 (id int)

	--часто выигрыш в скорости
	insert t1 with (tablockx) 
	select id from t where id < 0 

end 

begin --readpast (пропуск заблокированных строк)
	begin tran 

		update t set name = name + ' ' where id = 500
		---------
		--другой сеанс!
		select id from t where id between 500 and 501

		select id from t with (readpast) where id between 500 and 501

		--rollback
end 