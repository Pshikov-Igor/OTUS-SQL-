USE WideWorldImporters

-----------------------------------------
-- Исходные таблицы
-----------------------------------------

-- Исходная таблица Suppliers
SELECT
  SupplierID,
  SupplierName
FROM Purchasing.Suppliers
/* where - чтобы в примере было меньше строк */
WHERE SupplierName IN ('A Datum Corporation', 'Contoso, Ltd.', 'Consolidated Messenger', 'Nod Publishers')
ORDER BY SupplierID;

-- Исходная таблица -- SupplierTransactions
SELECT
  SupplierTransactionID,
  SupplierID,
  TransactionDate,
  TransactionAmount
FROM Purchasing.SupplierTransactions
WHERE SupplierID IN (1, 2, 3, 9) /* чтобы в примере было меньше строк */
ORDER BY SupplierID;

-----------------------------------------
-- JOINS 
-----------------------------------------

-- CROSS JOIN через FROM, ANSI SQL-89
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM Purchasing.Suppliers s, Purchasing.SupplierTransactions t
WHERE s.SupplierID IN (1, 2, 3, 9) and t.SupplierID IN (1, 2, 3, 9)
ORDER BY s.SupplierID, t.SupplierID

-- INNER JOIN через FROM и WHERE, ANSI SQL-89
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM Purchasing.Suppliers s, Purchasing.SupplierTransactions t
WHERE s.SupplierID IN (1, 2, 3, 9) and t.SupplierID IN (1, 2, 3, 9)
and s.SupplierID = t.SupplierID -- <====== условие JOIN
ORDER BY s.SupplierID, t.SupplierID

-- CROSS JOIN, ANSI SQL-92
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM Purchasing.Suppliers s
CROSS JOIN Purchasing.SupplierTransactions t
WHERE s.SupplierID IN (1, 2, 3, 9) and t.SupplierID IN (1, 2, 3, 9)
ORDER BY s.SupplierID, t.SupplierID

-- INNER JOIN, ANSI SQL-92
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM Purchasing.Suppliers s
INNER JOIN Purchasing.SupplierTransactions t
	  ON t.SupplierID = s.SupplierID
WHERE s.SupplierID IN (1, 2, 3, 9)
ORDER BY s.SupplierID

-- LEFT JOIN 
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM Purchasing.Suppliers s
LEFT OUTER JOIN Purchasing.SupplierTransactions t
	ON t.SupplierID = s.SupplierID
WHERE s.SupplierName IN ('Contoso, Ltd.', 'A Datum Corporation', 'Consolidated Messenger', 'Nod Publishers')
ORDER BY s.SupplierID

-- RIGHT JOIN
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM Purchasing.SupplierTransactions t
RIGHT JOIN  Purchasing.Suppliers s
	ON s.SupplierID = t.SupplierID
WHERE s.SupplierName IN ('Contoso, Ltd.', 'A Datum Corporation', 'Consolidated Messenger', 'Nod Publishers')
ORDER BY s.SupplierID

-- Лучше используйте LEFT JOIN вместо RIGHT JOIN

-- Найти поставщиков (Supplier) без транзакций (transactions)
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.SupplierTransactions t
	ON t.SupplierID = s.SupplierID
WHERE s.SupplierName IN ('Contoso, Ltd.', 'A Datum Corporation', 'Consolidated Messenger', 'Nod Publishers') and
t.SupplierTransactionID is null
ORDER BY s.SupplierID

-- Много JOIN с INNER и LEFT
-- Поставщики (Suppliers) и их транзакции (SupplierTransactions) и много другого,
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

---------------------------------------
-- Порядок JOIN
---------------------------------------
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber,
	l.OrderLineID
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID

-- Поменяем местами Orders и Customers
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber,
	l.OrderLineID
FROM Sales.OrderLines l
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
JOIN Sales.Orders o ON o.OrderID = l.OrderID


-- Поменяем таблицы в FROM и JOIN
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.Orders o
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
JOIN Sales.OrderLines l ON l.OrderID  = o.OrderID

-- Теперь порядок JOIN не влияет
-- Планы для всех запросов абсолютно одинаковые 
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID

-- Все те же запросы с FORCE JOIN
-- (смотрим планы)
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
OPTION (FORCE ORDER);

SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.Orders o
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
JOIN Sales.OrderLines l ON l.OrderID  = o.OrderID
OPTION (FORCE ORDER);

SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.Orders o
JOIN Sales.OrderLines l ON l.OrderID  = o.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
OPTION (FORCE ORDER);
GO

--------------------------------
-- "Съедание данных" LEFT JOIN
--------------------------------
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.TransactionDate,
  t.TransactionAmount
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.SupplierTransactions t ON t.SupplierID = s.SupplierID
WHERE s.SupplierName IN ('Contoso, Ltd.', 'A Datum Corporation', 'Consolidated Messenger', 'Nod Publishers')
ORDER BY s.SupplierID

-- Добавим TransactionTypes через INNER JOIN
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  tt.TransactionTypeName
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.SupplierTransactions t ON t.SupplierID = s.SupplierID
INNER JOIN Application.TransactionTypes tt ON tt.TransactionTypeID = t.TransactionTypeID
WHERE s.SupplierName IN ('Contoso, Ltd.', 'A Datum Corporation', 'Consolidated Messenger', 'Nod Publishers')
ORDER BY s.SupplierID

-- Как сделать так, чтобы  TransactionType не пропал?











SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  tt.TransactionTypeName
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.SupplierTransactions t ON t.SupplierID = s.SupplierID
LEFT JOIN Application.TransactionTypes tt ON tt.TransactionTypeID = t.TransactionTypeID
WHERE s.SupplierName IN ('Contoso, Ltd.', 'A Datum Corporation', 'Consolidated Messenger', 'Nod Publishers')
ORDER BY s.SupplierID


-- В общем случае что быстрее LEFT JOIN или INNER JOIN?
