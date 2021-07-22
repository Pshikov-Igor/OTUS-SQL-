-- --------------------------------------------------
-- CLR-агрегат в оконной функции
-- --------------------------------------------------
use WideWorldImporters

DROP TABLE IF EXISTS #AggregateTest
GO

CREATE TABLE #AggregateTest(
  [month] int, 
  [value] int)
GO

INSERT INTO #AggregateTest 
VALUES (1, 1), (1, 0), (1, 2), (2, 3), (2, 2), (3, 2), (4, 3), (5, 1), (5, 3)
GO

SELECT 
  t.[month]
 ,t.[value]

             ,sum(t.[value]) over () as [sum_total]
      ,dbo.SumClr(t.[value]) over () as [SumClr_total]
 
	         ,sum(t.[value]) over (partition by t.[month]) as [sum_partition]
      ,dbo.SumClr(t.[value]) over (partition by t.[month]) as [SumClr_partition]

              -- нарастающий итог
             ,sum(t.[value]) over (order by t.[month]) as [sum_order] 
      --,dbo.SumClr(t.[value]) over (order by t.[month])
 -- SumClr с order by не работает, 
 -- если раcскоментировать, то будет ошибка синтаксиса
FROM #AggregateTest t
GO

