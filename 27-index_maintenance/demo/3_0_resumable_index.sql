drop table if exists resumable_table

create table resumable_table (
	id int identity primary key
	, name varchar(100)
)
; with cte as (select value from string_split(space(1999), ' '))
insert resumable_table (name)
select concat('name ', row_number() over(order by 1/0)) from cte as t1, cte as t2

--
create nonclustered index nix_resumable_table on resumable_table(name) with (online = on, resumable = on);

-------------
--сразу ставим на паузу (другой сеанс)
alter index nix_resumable_table on resumable_table pause;

--состояние индекса
select name, percent_complete, state_desc, last_pause_time, page_count from sys.index_resumable_operations;

---
alter index nix_resumable_table on resumable_table resume --возобновить
--alter index nix_resumable_table on resumable_table abort --прерывание