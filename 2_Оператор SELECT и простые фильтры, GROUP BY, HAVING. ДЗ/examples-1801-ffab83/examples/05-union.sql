USE WideWorldImporters

-- Задачка вывести в одном столбце
select 'a' as Col1
union
select 'b' as Col2
union
select 'c' as Col3
go


select * 
from (values('a', 2), ('b', 4), ('c', 1)) as tbl (col1, col2)
go

-- Будет ли разница в производительности между этими вариантами?




-- Что быстрее UNION или UNION ALL?
select 'a'
union all
select 'a'

select 'a'
union
select 'a'
go

-- Совместимость по типам 
-- ошибка
select 'a'
union 
select 123
go

select 'a'
union 
select cast(1 as nchar(1))
go
