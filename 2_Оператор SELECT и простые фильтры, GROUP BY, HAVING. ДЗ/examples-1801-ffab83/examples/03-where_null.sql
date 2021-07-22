USE WideWorldImporters

-- --------------------------
-- equals
-- --------------------------
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName = 'Chocolate sharks 250g';

SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemID = 225;

SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemID != 225; -- StockItemID <> 225

-- --------------------------
-- LIKE
-- --------------------------
-- index seek
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName like 'Chocolate%';

-- index scan
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName like '%Chocolate';
GO

-- index scan
SELECT *
FROM Warehouse.StockItems
WHERE StockItemName like '%250%';

SELECT *
FROM Warehouse.StockItems
WHERE StockItemName like 'Chocolate%250g';

SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName like '%25[0-6]%';

-- --------------------------
-- AND, OR
-- --------------------------
-- нужно вывести StockItems, где цена от 350 до 500 и
-- название начинается с USB или Ride.
-- все правильно?
SELECT RecommendedRetailPrice, *
FROM Warehouse.StockItems
WHERE
    RecommendedRetailPrice BETWEEN 350 AND 500
    AND StockItemName like 'USB%' 
    OR StockItemName like 'Ride%';







-- используйте скобки
SELECT RecommendedRetailPrice, *
FROM Warehouse.StockItems
WHERE
    (RecommendedRetailPrice BETWEEN 350 AND 500) 
	AND (StockItemName like 'USB%' 
	OR StockItemName like 'Ride%');

-- --------------------------
-- Функции в WHERE
-- --------------------------
SELECT OrderDate, OrderID, year(OrderDate)
FROM Sales.Orders o
WHERE year(OrderDate) = 2013;
-- Но так лучше не писать (не может использоваться индекс).

-- Лучше через BETWEEN
SELECT OrderDate, OrderID
FROM Sales.Orders o
WHERE OrderDate BETWEEN '2013-01-01' AND '2013-12-31';

-- WHERE по выражению
SELECT  OrderLineID as [Order Line ID],
		Quantity,
		UnitPrice,
		(Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
WHERE (Quantity * UnitPrice) > 1000;

-- --------------------------
-- DATES
-- --------------------------

-- Назовите дату, которая указана в запросе?

SELECT *
FROM [Sales].[Orders]
WHERE OrderDate > '01.05.2016' 
ORDER BY OrderDate





















SET DATEFORMAT mdy
SELECT *
FROM [Sales].[Orders]
WHERE OrderDate > '01.05.2016' -- пятое января
ORDER BY OrderDate
GO


SET DATEFORMAT dmy
SELECT *
FROM [Sales].[Orders]
WHERE OrderDate > '01.05.2016' -- первое мая
ORDER BY OrderDate
GO

SET DATEFORMAT mdy
SELECT *
FROM [Sales].[Orders]
WHERE OrderDate > '20160501' -- первое мая
ORDER BY OrderDate
GO

-- --------------------------
-- Функции с DATE, CONVERT
-- --------------------------

-- MONTH, DAY, YEAR
SELECT DISTINCT o.OrderDate,
       MONTH(o.OrderDate) AS OrderMonth,
       DAY(o.OrderDate) AS OrderDay,
       YEAR(o.OrderDate) AS OrderYear
FROM Sales.Orders AS o

-- DATEPART ( datepart , date )
SELECT o.OrderID,
       o.OrderDate,
       DATEPART(m, o.OrderDate) AS OrderMonth,
       DATEPART(d, o.OrderDate) AS OrderDay,
       DATEPART(yy, o.OrderDate) AS OrderYear
FROM Sales.Orders AS o

-- Справка по DATEPART
-- https://docs.microsoft.com/ru-ru/sql/t-sql/functions/datepart-transact-sql

-- -----------------------------------------------
-- DATEDIFF ( datepart , startdate , enddate )
-- -----------------------------------------------
-- Справка DATEDIFF https://docs.microsoft.com/ru-ru/sql/t-sql/functions/datediff-transact-sql
-- Справка DATEADD  https://docs.microsoft.com/ru-ru/sql/t-sql/functions/datediff-transact-sql

-- Years
SELECT DATEDIFF (yy,'2007-01-01', '2008-01-01') AS 'YearDiff';

-- Days
SELECT DATEDIFF (dd,'2007-01-01', '2008-01-01') AS 'DayDiff';

-- Months
SELECT o.OrderID,
       o.OrderDate,
       o.PickingCompletedWhen,
       DATEDIFF(mm, o.OrderDate, o.PickingCompletedWhen) AS MonthsDiff
FROM Sales.Orders o
WHERE DATEDIFF(mm, o.OrderDate, o.PickingCompletedWhen) > 0

-- DATEADD (datepart , number , date )
SELECT o.OrderID,
       o.OrderDate,
       DATEADD (yy, 1, o.OrderDate) AS DateAddOneYear,
       EOMONTH(o.OrderDate) AS EndOfMonth
FROM Sales.Orders o

-- DATETIME to date, CONVERT
-- Показать заказы с 2013-01-05 по 2013-01-07 включительно.
-- Есть ошибка?
SELECT
 PickingCompletedWhen,
 cast(PickingCompletedWhen as date) CastDate,
 convert(nvarchar(16), PickingCompletedWhen, 104) as DateAsString,
 cast(floor(cast(cast(PickingCompletedWhen as datetime) as float)) as datetime) as PickingDateWithoutTime_FLOOR,
 *
FROM Sales.Orders o
WHERE PickingCompletedWhen BETWEEN '2013-01-05' AND '2013-01-07' 

-- Справка по CONVERT
-- https://docs.microsoft.com/ru-ru/sql/t-sql/functions/cast-and-convert-transact-sql

-- Полезная статья:
-- "Ошибки при работе с датой и временем в SQL Server"
-- https://habr.com/ru/company/otus/blog/487774/

-- --------------------------
-- IS NULL, IS NOT NULL
-- --------------------------

-- Будет ли так работать? (= null, != null)
-- Будет ошибка или выполнится?
SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen = null;

SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen != null;
GO









SET ANSI_NULLS OFF
	SELECT OrderID, PickingCompletedWhen
	FROM Sales.Orders
	WHERE PickingCompletedWhen = null;
SET ANSI_NULLS ON
-- По умолчанию ANSI_NULLS = ON, в будущих версиях OFF будет вызывать ошибку
-- Так писать самим не надо, но может встретиться в каком-нибудь дремучем легаси

-- так правильно
SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen is null;

SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen is not null;
GO



-- Конкатенация с NULL
SELECT 'abc' + null;

SET CONCAT_NULL_YIELDS_NULL OFF;
    SELECT 'abc' + null;
SET CONCAT_NULL_YIELDS_NULL ON;
-- По умолчанию CONCAT_NULL_YIELDS_NULL = ON, в будущих версиях OFF будет вызывать ошибку


-- Арифметические операции с NULL
SELECT 3 + null;

-- -----------------------------------
-- ISNULL(), COALESCE()
-- -----------------------------------
SELECT 
    OrderId,    
    ISNULL(PickingCompletedWhen,'1900-01-01')
FROM Sales.Orders

-- Задача - вывести значение "Unknown", там, где NULL
-- Так будет работать?
SELECT 
	OrderId,    
	ISNULL(PickingCompletedWhen, 'Unknown') AS PickingCompletedWhen
FROM Sales.Orders;














-- вариант решения (и еще примеры CASE)
SELECT 
    OrderId,    
    PickingCompletedWhen,
    
	ISNULL(CONVERT(nvarchar(10), PickingCompletedWhen, 104), 'Unknown') AS PickingCompletedWhenDay1,

	CASE 
		WHEN PickingCompletedWhen is null THEN 'Unknown'
		-- WHEN ... THEN ...
		ELSE CONVERT(nvarchar(10), PickingCompletedWhen, 104) 
	END PickingCompletedWhenDay2,

    CASE datediff(d, o.OrderDate, o.PickingCompletedWhen)
        WHEN 0 THEN 'today'
        WHEN 1 THEN 'one day'
        ELSE 'more then one day'
    END [Order and Picking Date Diff]
FROM Sales.Orders o
ORDER BY PickingCompletedWhen;

-- COALESCE()
DECLARE @val1 int = NULL;
DECLARE @val2 int = NULL;
DECLARE @val3 int = 2;
DECLARE @val4 int = 5;

SELECT COALESCE(@val1, @val2, @val3, @val4);

   
-- Здесь есть NULL
SELECT DISTINCT PickingCompletedWhen
FROM Sales.Orders
ORDER BY PickingCompletedWhen;

-- Здесь NULL нет
SELECT COUNT(DISTINCT PickingCompletedWhen)
FROM Sales.Orders;