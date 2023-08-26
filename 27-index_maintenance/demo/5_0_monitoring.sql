-- время, прошедшее с момента перезагрузки сервера 
select create_date, datediff (dd, create_date, getdate ()) as days_metadata
from sys.databases
where name = 'tempdb'

select * from sys.dm_db_index_usage_stats
--
-- анализ использования индексов (скрипт)
-- Плохо, когда user_seeks, user_scans мало, а user_updates много - индекс не используется
select 
	 p.rows as [rows]
	 --, t.object_id
	 --, i.index_id
	 , s.name + '.' + t.name as [table]
	 , i.name as [index]
	 , i.type_desc
	 , i.has_filter as [filtered]
	 , i.is_unique as [unique]
	 , ius.user_seeks as [seeks]
	 , ius.user_scans as [scans]
	 , ius.user_lookups as [lookups]
	 , ius.user_seeks + ius.user_scans + ius.user_lookups as [reads]
	 , ius.user_updates as [updates]
	 , ius.last_user_seek as [last seek]
	 , ius.last_user_scan as [last scan]
	 , ius.last_user_lookup as [last lookup]
	 , ius.last_user_update as [last update]
from sys.tables t (nolock)
inner join sys.indexes i (nolock) on t.object_id = i.object_id 
inner join sys.schemas s (nolock) on t.schema_id = s.schema_id 
cross apply (
	select sum(p.rows) as [rows] 
	from sys.partitions p (nolock)
	where i.object_id = p.object_id and i.index_id = p.index_id
	) p 
left join sys.dm_db_index_usage_stats ius on ius.database_id = db_id() and ius.object_id = i.object_id and ius.index_id = i.index_id 
where i.is_disabled = 0 and i.is_hypothetical = 0 and t.is_memory_optimized = 0 and t.is_ms_shipped = 0 
	and t.name = N't'
order by s.name, t.name, i.index_id 
option (recompile)