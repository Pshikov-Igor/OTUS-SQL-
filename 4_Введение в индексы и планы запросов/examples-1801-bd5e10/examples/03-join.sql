use WideWorldImporters

-- -----------------------------------------
-- 3) JOIN
-- -----------------------------------------

-- В Messages выводится информация под вводу-выводу, времени выполнения запросов
SET STATISTICS IO, TIME ON
-- SET STATISTICS IO ON
-- SET STATISTICS TIME ON

exec sp_helpindex 'Sales.Invoices'

-- 1 111  - select count(*) from Application.People	
-- 70 510 - select count(*) from Sales.Invoices

-- nested loops + parallelism
SELECT Staff.PersonID, Staff.FullName, Invoice.InvoiceID, Invoice.InvoiceDate
FROM Application.People	AS Staff
JOIN Sales.Invoices AS Invoice ON Invoice.SalespersonPersonID = Staff.PersonID 
WHERE Staff.PersonID = 16;

-- nested loops
SELECT Staff.PersonID, Staff.FullName, Invoice.InvoiceID, Invoice.InvoiceDate
FROM Application.People	AS Staff
JOIN Sales.Invoices AS Invoice ON Invoice.SalespersonPersonID = Staff.PersonID
WHERE Invoice.SalespersonPersonID = 16
OPTION (MAXDOP 1)
--


-- hash match
SELECT Staff.PersonID, Staff.FullName, Invoice.InvoiceID, Invoice.InvoiceDate
FROM Application.People	AS Staff
JOIN Sales.Invoices AS Invoice ON Invoice.SalespersonPersonID = Staff.PersonID
OPTION (MAXDOP 1)

-- hash match left join
SELECT Staff.PersonID, Staff.FullName, Invoice.InvoiceID, Invoice.InvoiceDate
FROM Application.People	AS Staff
LEFT JOIN Sales.Invoices AS Invoice ON Invoice.SalespersonPersonID = Staff.PersonID
OPTION (MAXDOP 1)

-- OPTION (MAXDOP 1) для того, чтобы план был проще

-- MERGE example

-- Создадим тестовую таблицу
DROP TABLE IF EXISTS Sales.InvoiceLines_Test;

SELECT * 
INTO Sales.InvoiceLines_Test
FROM Sales.InvoiceLines

-- Создадим кластерный индекс
CREATE CLUSTERED INDEX CL_InvoiceLines on Sales.InvoiceLines_Test (InvoiceId, InvoiceLineId);

-- И первичный ключ
ALTER TABLE [Sales].InvoiceLines_Test 
ADD CONSTRAINT [PK_Sales_InvoiceLines_Test] PRIMARY KEY NONCLUSTERED 
(
	[InvoiceLineID] ASC
);

-- merge join
SELECT Invoice.InvoiceID, Invoice.InvoiceDate, Detail.Quantity, Detail.UnitPrice
FROM  Sales.Invoices AS Invoice
JOIN Sales.InvoiceLines_Test AS Detail 
ON Invoice.InvoiceId = Detail.InvoiceId;


-- Сравним Nested Loops, Merge, Hash.
-- Кто победит?
-- Hints! INNER LOOP JOIN, INNER MERGE JOIN, INNER HASH JOIN

SELECT Staff.PersonID, Staff.FullName, Invoice.InvoiceID, Invoice.InvoiceDate
FROM Application.People	AS Staff
INNER LOOP JOIN Sales.Invoices AS Invoice ON Invoice.SalespersonPersonID = Staff.PersonID;

-- будет SORT
SELECT Staff.PersonID, Staff.FullName, Invoice.InvoiceID, Invoice.InvoiceDate
FROM Application.People	AS Staff
INNER MERGE JOIN Sales.Invoices AS Invoice ON Invoice.SalespersonPersonID = Staff.PersonID;

SELECT Staff.PersonID, Staff.FullName, Invoice.InvoiceID, Invoice.InvoiceDate
FROM Application.People	AS Staff
INNER HASH JOIN Sales.Invoices AS Invoice ON Invoice.SalespersonPersonID = Staff.PersonID;


-- JOIN выполняется попарно
-- Логически разницы нет в каком порядке
-- Много JOIN с INNER и LEFT
-- Поставщики (Suppliers) с их транзакциями, 
-- включая тех поставщиков, у которых нет транзакций
SELECT 
  s.SupplierID as [Supplier ID],
  s.SupplierName as [Supplier Name],
  c.SupplierCategoryName as [Supplier Category],
  primaryContact.EmailAddress as [Primary Contact],
  alternateContact.EmailAddress as [Alternate Contact],
  d.DeliveryMethodName as [Delivery Method Name],
  t.SupplierTransactionID as [Transaction ID],
  t.TransactionDate as [Transaction Date],  
  t.TransactionTypeName AS [Transaction Type]
FROM Purchasing.Suppliers s 
JOIN Purchasing.SupplierCategories c ON c.SupplierCategoryID = s.SupplierCategoryID
JOIN Application.People primaryContact ON primaryContact.PersonID = s.PrimaryContactPersonID
JOIN Application.People alternateContact ON alternateContact.PersonID = s.AlternateContactPersonID
LEFT JOIN Application.DeliveryMethods d ON d.DeliveryMethodID = s.DeliveryMethodID
LEFT JOIN (SELECT t.SupplierTransactionID,  
				  t.TransactionDate, 
				  t.SupplierID,
				  t.TransactionTypeID,
			tt.TransactionTypeName 
			FROM Purchasing.SupplierTransactions t
			JOIN Application.TransactionTypes tt ON tt.TransactionTypeID = t.TransactionTypeID) AS t
ON t.SupplierID = s.SupplierID
ORDER BY t.TransactionTypeID

-- Посмотрим это же запрос в SentryOne Plan Explorer
-- Есть плагин в SSMS (в плане правой кнопкой -> View with Sentry One Plan Explorer) 

-- -----------------------------------------
-- 4) SORT
-- -----------------------------------------

-- Здесь есть Sort
SELECT Continent, CountryName, CountryID
FROM Application.Countries
ORDER BY Continent;

-- Почему здесь нет сортировки в плане?
SELECT Continent, CountryName, CountryID
FROM Application.Countries
ORDER BY CountryID;

-- index seek + parallel sort
SELECT Staff.PersonID, Staff.FullName, Invoice.InvoiceID, Invoice.InvoiceDate
FROM Application.People	AS Staff
JOIN Sales.Invoices AS Invoice ON Invoice.SalespersonPersonID = Staff.PersonID
WHERE Invoice.SalespersonPersonID = 16
ORDER BY Invoice.InvoiceDate
-- OPTION (MAXDOP 1)

-- top + sort
SELECT TOP 50 Staff.PersonID, Staff.FullName, Invoice.InvoiceID, Invoice.InvoiceDate
FROM Application.People	AS Staff
JOIN Sales.Invoices AS Invoice ON Invoice.SalespersonPersonID = Staff.PersonID
WHERE Invoice.SalespersonPersonID = 16
ORDER BY Invoice.InvoiceDate;

SELECT Staff.PersonID, Staff.FullName, Invoice.InvoiceID, Invoice.InvoiceDate
FROM Application.People	AS Staff
	JOIN Sales.Invoices AS Invoice 
		ON Invoice.SalespersonPersonID = Staff.PersonID
WHERE Invoice.SalespersonPersonID = 16
ORDER BY Invoice.InvoiceDate
OFFSET 100 ROWS FETCH NEXT 50 ROWS ONLY;