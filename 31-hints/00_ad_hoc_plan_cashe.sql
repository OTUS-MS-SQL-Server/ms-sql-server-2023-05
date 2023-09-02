SELECT st.text
	, qs.execution_count
	, qs.*
	, pl.*
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS pl
WHERE st.text like '%inner join t1%'
ORDER BY creation_time desc, st.text, qs.execution_count DESC