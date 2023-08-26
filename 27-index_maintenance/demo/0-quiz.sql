--почему код создания таблицы даст ошибку? (синтаксических ошибок нет)

drop table if exists t;

create table t (
    id int not null
    , col1 char(5000) 
    , col2 char(5000) 
);