--fillfactor - уровень экземпляра (лучше не менять), но можно поменять на уровне индекса
EXEC sp_configure 'show advanced options', 1; 
GO 
RECONFIGURE; 

EXEC sp_configure 'fill factor';  
--EXEC sp_configure 'fill factor', 90;  - изменение 
--GO 
--RECONFIGURE;

go 

--просмотр fillfactor у всех индексов
select object_name(object_id) as [table], name as [index], type_desc, fill_factor 
from sys.indexes 
order by fill_factor desc
go

-- пример с fill factor (задается только при создании индекса)
drop table if exists t; 
go

create table t (
	id int not null 
	, name char(1000) null
	, constraint pk_t primary key (id) --with (fillfactor = 50) - не имеет смысла попробовать!
);
go

insert t(id)
select 2 * row_number() over(order by 1/0)
from string_split(space(15), ' ') as t1 --16 строк с нумерацией через 2


--fillfactor
alter index pk_t on dbo.t rebuild with (fillfactor = 50)

--------------------

--на каких страницах хранятся данные
select sys.fn_PhysLocFormatter(t.%%physloc%%) as [file_page_slot], * from t as t


----------------------
--вставка нечетного id = 9 - разделение страницы
insert t(id) values(9)

--страницы
select sys.fn_PhysLocFormatter(t.%%physloc%%) as [file_page_slot], * from t
