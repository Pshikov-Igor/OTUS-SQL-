use WideWorldImporters

-- -----------------------------------------
-- 2) TABLE SCAN, INDEX SEEK, ...
-- -----------------------------------------

-- Удалим тестовую таблицу
DROP TABLE IF EXISTS Application.CountriesCount;

-- Создаем тестовую таблицу с помощью SELECT INTO
SELECT Continent, COUNT(*) AS CountryCount 
INTO Application.CountriesCount
FROM Application.Countries
GROUP BY Continent;

-- Посмотрим, что получилось
SELECT * 
FROM Application.CountriesCount
-- Созданная таблица будет "кучей" (heap)

-- Table Scan 
-- Как по плану выполнения понять куча или кластеризованная таблица?
SELECT CountryCount
FROM Application.CountriesCount
WHERE Continent = 'Asia';

-- Clustered Index Scan
SELECT * 
FROM Application.Countries

-- Добавим условие WHERE
SELECT CountryName
FROM Application.Countries
WHERE Continent = 'Asia';

-- С помощью sp_helpindex можно посмотреть индексы в таблице
-- а также в SSMS: <table> \ Indexes

exec sp_helpindex 'Application.Countries';
-- есть индекс по CountryName

-- Index Seek (используется индекс)
SELECT CountryID
FROM Application.Countries
WHERE CountryName = 'Korea';

-- Сравним с Index Scan
SELECT CountryID
FROM Application.Countries WITH(INDEX(0))
WHERE CountryName = 'Korea';
-- Если существует кластеризованный индекс, 
-- INDEX(0) - clustered index scan, 
-- INDEX(1) - clustered index scan или seek. 
-- 
-- Если кластеризованный индекс не существует, 
-- INDEX(0) - table scan, 
-- INDEX(1) - ошибка.

-- Key Lookup
-- предыдущий запрос
SELECT CountryID
FROM Application.Countries
WHERE CountryName = 'Korea';

-- здесь Key Lookup
-- Откуда в плане JOIN? 
SELECT CountryID, Continent
FROM Application.Countries 
WHERE CountryName = 'Korea';

-- Как убрать Key Lookup?
CREATE NONCLUSTERED INDEX IX_Application_Countries_CountryName_INCLUDE_Continent
ON Application.Countries(CountryName)
INCLUDE(Continent)
GO
-- Это будет "покрывающий" индекс
-- SQL Server берет все данные из индекса и не обращается к другим данным

-- Проверим использование IX_Application_Countries_CountryName_INCLUDE_Continent
SELECT CountryID, Continent
FROM Application.Countries 
WHERE CountryName = 'Korea';
GO

-- Удалим индекс, он нам больше не понадобиться
DROP INDEX IX_Application_Countries_CountryName_INCLUDE_Continent
ON Application.Countries
GO

-- Создаем еще одну кучу (heap) и потом создадим индекс для нее 
DROP TABLE IF EXISTS Application.CountriesCount_Index;

-- тестовая heap-табличка с индексом
SELECT * 
INTO Application.CountriesCount_Index
FROM Application.CountriesCount
GO

CREATE INDEX IX_CountryCount_ContinentIndex 
ON Application.CountriesCount_Index (Continent);
GO

-- Что в табличке и какие индексы
SELECT * FROM Application.CountriesCount_Index
exec sp_helpindex 'Application.CountriesCount_Index';
GO

-- RID Lookup
SELECT CountryCount
FROM Application.CountriesCount_Index
WITH (INDEX(IX_CountryCount_ContinentIndex))
WHERE Continent = 'Asia';

-- Сравним без хинта WITH (INDEX(IX_CountryCount_ContinentIndex))
SELECT CountryCount
FROM Application.CountriesCount_Index
WHERE Continent = 'Asia';

-- Несколько индексов в одном запросе
exec sp_helpindex 'Sales.Invoices';

SELECT InvoiceID
FROM Sales.Invoices 
WHERE SalespersonPersonID = 16 and CustomerID = 57;

-- Несколько индексов в одном запросе + Key Lookup
SELECT InvoiceID, InvoiceDate
FROM Sales.Invoices
WHERE SalespersonPersonID = 16 and CustomerID = 57;

-- Опять JOIN, аж две штуки. Откуда? В исходном запросе нет ни одного?

-- А в чем отличие RID Lookup и Key Lookup?

-- SARGable (Search ARGguments able)
-- Можно ли в условии WHERE использовать индексы или нет 
-- Надо стремиться создавать запросы, которые SARGable

-- Где будет использоваться индекс?
exec sp_helpindex 'Sales.Invoices';

-- Здесь 
SELECT InvoiceID
FROM Sales.Invoices
WHERE year(Sales.Invoices.ConfirmedDeliveryTime) = 2014

-- Или здесь
SELECT InvoiceID
FROM Sales.Invoices
WHERE Sales.Invoices.ConfirmedDeliveryTime BETWEEN '2014-01-01' AND '2014-12-31'
GO

-- плохо  - WHERE f(x) = 'some_value'
-- хорошо - WHERE field = f(x)

-- А здесь?
SELECT FullName, LEFT(FullName, 1)
FROM Application.People
WHERE LEFT(FullName, 1) = 'K'
-- Если нет, то как исправить?







-- Index Seek
SELECT FullName  
FROM Application.People
WHERE FullName like 'K%'

-- А здесь?
SELECT FullName  
FROM Application.People
WHERE FullName like '%K'

-- А здесь?
SELECT FullName  
FROM Application.People
WHERE FullName like '%K%'
GO

-- А здесь? Index Seek или Index Scan?
SELECT OrderID, OrderDate, COALESCE([PickingCompletedWhen], OrderDate), [PickingCompletedWhen]
FROM [Sales].[Orders]
WHERE CustomerID = 90;

-- Добавлен COALESCE в WHERE
SELECT OrderID, OrderDate, COALESCE([PickingCompletedWhen], OrderDate), [PickingCompletedWhen]
FROM [Sales].[Orders]
WHERE CustomerID = 90
	AND COALESCE([PickingCompletedWhen], OrderDate) < '2014-01-01';










-- Index Seek, SQL Server может развернуть COALESCE
-- запрос выше эквивалентен следующему
-- COALESCE([PickingCompletedWhen], OrderDate) < '2014-01-01';
SELECT OrderID, OrderDate, COALESCE([PickingCompletedWhen], OrderDate), [PickingCompletedWhen]
FROM [Sales].[Orders]
WHERE CustomerID = 90
	AND (([PickingCompletedWhen] IS NULL AND OrderDate < '2014-01-01')
		  OR 
		 ([PickingCompletedWhen] < '2014-01-01')
	);

-- Проверим ISNULL
SELECT OrderID, OrderDate, COALESCE([PickingCompletedWhen], OrderDate), [PickingCompletedWhen]
FROM [Sales].[Orders]
WHERE CustomerID = 90
	AND ISNULL([PickingCompletedWhen], OrderDate) < '2014-01-01';
