--пример разделения страниц - 15

use WideWorldImporters

-- заполним таблицу строками с четными id
drop table if exists t
go

create table t (
	id int not null 
	, name char(4000) null -- на каждой странице - только 2 строки
	, constraint pk_t primary key (id)
)
go

insert t(id)
select 2 * row_number() over(order by 1/0)
from string_split(space(15), ' ') as t1 --16 строк с нумерацией через 2

--------------------

--на каких страницах хранятся данные
select sys.fn_PhysLocFormatter(t.%%physloc%%) as [file_page_slot], * from t as t

----------------------------
--фрагментация - см. свойства индекса
----------------------------

--sys.dm_db_index_physical_stats
--режимы 

SELECT a.page_count, name as ind_name, avg_fragmentation_in_percent as [Total fragmentation, %], avg_page_space_used_in_percent as [Page fullness, %]
FROM sys.dm_db_index_physical_stats (db_id(), object_id(N'dbo.t'), NULL, NULL, 'detailed') AS a  --detailed - самый подробный, limited - самый быстрый (есть смысл использовать на больших таблицах)
JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id; 

SELECT a.page_count, name as ind_name, avg_fragmentation_in_percent as [Total fragmentation, %], avg_page_space_used_in_percent as [Page fullness, %]
FROM sys.dm_db_index_physical_stats (db_id(), object_id(N'dbo.t'), NULL, NULL, 'limited') AS a  --detailed - самый подробный, limited - самый быстрый (есть смысл использовать на больших таблицах)
JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id; 

----------------------
--вставка в середину индекса - разделение страницы
insert t(id) values(9)

--страницы
select sys.fn_PhysLocFormatter(t.%%physloc%%) as [file_page_slot], * from t

--фрагментация - см. свойства индекса
----------------------
--просмотр журанала транзакций (Page Split)
SELECT
    operation,
	AllocUnitName,
	[Context],
	(CASE [Context]
		WHEN N'LCX_INDEX_LEAF' THEN N'Nonclustered'
		WHEN N'LCX_CLUSTERED' THEN N'Clustered'
		ELSE N'Non-Leaf'
	END) AS [SplitType],
	Description,
	AllocUnitId,
	[Page ID],
	[Slot ID],
	[New Split Page]
FROM fn_dblog(NULL, NULL)
WHERE Operation = 'LOP_DELETE_SPLIT' AND 
      AllocUnitName NOT LIKE 'sys.%';

--1_1_fragmetation_script.sql