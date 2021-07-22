-- =========================================
-- Покрывающие индексы
-- Covering index
-- =========================================

use WideWorldImporters

-----------------------------------
-- Покрывающие (INCLUDE)
-----------------------------------
SET STATISTICS IO ON

-- Index Seek 
SELECT CustomerID 
FROM Sales.Orders
WHERE CustomerID = 803

-- Index Seek + Key Lookup 
SELECT CustomerID, OrderDate
FROM Sales.Orders
WHERE CustomerID = 803

-- Добавляем индекс с INCLUDE
CREATE NONCLUSTERED INDEX [FK_Sales_Orders_CustomerID] 
ON [Sales].[Orders]
(
	[CustomerID] ASC
)
INCLUDE(OrderDate)
WITH DROP_EXISTING
ON [USERDATA]
GO

-- Только INDEX SEEK 
SELECT CustomerID, OrderDate
FROM Sales.Orders
WHERE CustomerID = 803

-- А если * ?
SELECT *
FROM Sales.Orders
WHERE CustomerID = 803

