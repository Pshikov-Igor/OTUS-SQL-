USE WideWorldImporters
GO

-- Детерменированные и не детерменированные
select 
   dbo.SumDeterministic(1, 2), 
   dbo.SumNondeterministic(3, 4)

create table Table1
(
	a int,
	b int,
	summa as dbo.SumDeterministic(a, b) persisted
)

create table Table22
(
	a int,
	b int,
	summa as dbo.SumNondeterministic(a, b) persisted
)

drop table Table1



-- Функция с обращением к данным в БД
SELECT dbo.CountOrdersForCustomer(832) as [CLR]
SELECT count(*) as [SQL] FROM Sales.Orders
WHERE CustomerID = 832
GO

SELECT dbo.CountOrdersForCustomer(105) as [CLR]
SELECT count(*) as [SQL] FROM Sales.Orders 
WHERE CustomerID = 105
GO

-- Табличная функция
-- Разбивает строку по разделителям
select * 
from dbo.Split('a,ab,abc', ',')
