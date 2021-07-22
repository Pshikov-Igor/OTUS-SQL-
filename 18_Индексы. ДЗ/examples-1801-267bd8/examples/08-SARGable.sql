-- =========================================
-- SARGable
-- Search ARGument ABLE
-- =========================================

use WideWorldImporters

-- Index Seek, Scan?
SELECT FullName  
FROM Application.People
WHERE LEFT(FullName, 1) = 'K'

-- или RIGHT
SELECT FullName  
FROM Application.People
WHERE RIGHT(FullName, 1) = 'K'

-- надо писать с стиле:
-- where Col = func(...)

-- Как переписать запрос, чтобы использовался индекс?

-- Продолжение ниже




























-- Index Seek
SELECT FullName  
FROM Application.People
WHERE FullName like 'K%'
-- ------------------------------------------------

CREATE NONCLUSTERED INDEX IX_Sales_Orders_OrderDate
ON Sales.Orders (OrderDate)

-- Index Seek, Scan?
SELECT OrderDate
FROM Sales.Orders
WHERE YEAR(OrderDate) = 2013

-- Как переписать запрос, чтобы использовался индекс?

-- Продолжение ниже











SELECT OrderDate
FROM Sales.Orders
WHERE OrderDate BETWEEN '20130101' AND '20131231'


-- ---------------------------------------------------------
-- Цель - сделать условие SARGable 
-- WHERE RIGHT(SomeColumn,3) = '333'
-- 
-- http://sqlservercode.blogspot.com/2019/06/Can-adding-an-index-make-a-non-SARGable-query-SARGable-instead-of-rewriting-sql-query.html
-- перевод - https://otus.ru/nest/post/839/
-- ---------------------------------------------------------

SET STATISTICS IO ON
USE tempdb
GO

DROP TABLE IF EXISTS StagingData;
GO

-- Создадим таблицу
CREATE TABLE StagingData (SomeColumn varchar(255) NOT NULL PRIMARY KEY)
GO

-- Генерируем тестовые данные
DECLARE @guid uniqueidentifier
SELECT @guid = 'DEADBEEF-DEAD-BEEF-DEAD-BEEF00000075' 

INSERT StagingData
SELECT CONVERT(varchar(200),@guid) + '.100'

INSERT StagingData
SELECT TOP 999999 CONVERT(varchar(200),NEWID()) 
 +  '.' 
 + CONVERT(VARCHAR(10),s2.number)
FROM master..SPT_VALUES s1
CROSS JOIN master..SPT_VALUES s2
WHERE s1.type = 'P'
AND s2.type = 'P'
AND s1.number BETWEEN 100 AND 999
AND s2.number BETWEEN 100 AND 999
GO

-- Посмотрим данные
SELECT TOP 20 * FROM StagingData
GO

-- Clustered Index Scan
SELECT SomeColumn FROM StagingData
WHERE RIGHT(SomeColumn,3) = '333'

-- Добавляем вычисляемый столбец и индекс 
ALTER TABLE StagingData ADD RightChar as RIGHT(SomeColumn,3)
GO
CREATE INDEX ix_RightChar on StagingData(RightChar)
GO


SELECT TOP 5 * FROM StagingData

-- Index Seek
SELECT SomeColumn  FROM StagingData
WHERE RightChar  = '333'
GO

-- Но это не то, что мы хотим.
-- У нас WHERE RIGHT(SomeColumn, 3) = '333'
-- Пробуем его.
SELECT SomeColumn FROM StagingData
WHERE RIGHT(SomeColumn, 3) = '333'
GO
-- Index Seek !

-- А так? RIGHT(SomeColumn, 2)
SELECT SomeColumn FROM StagingData
WHERE RIGHT(SomeColumn, 2) = '33'
GO

-- Или так? RIGHT(SomeColumn, 4)
SELECT SomeColumn FROM StagingData
WHERE RIGHT(SomeColumn, 4) = '333'
GO

