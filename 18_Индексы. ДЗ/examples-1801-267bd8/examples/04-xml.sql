-- =========================================
-- XML индексы
-- XML indexes
-- =========================================

USE WideWorldImporters
GO

SET STATISTICS TIME ON
SET STATISTICS IO ON
GO

-- ----------------------------------------
-- Создаем таблицу с XML
-- Сводка по всем заказам по заказчикам
-- ----------------------------------------
DROP TABLE IF EXISTS Sales.OrderSummary
GO

CREATE TABLE Sales.OrderSummary
(
  ID INT NOT NULL IDENTITY,
  OrderSummary XML
)
GO

INSERT INTO Sales.OrderSummary ( OrderSummary)
SELECT 
    (SELECT
      CustomerName 'OrderHeader/CustomerName', 
      OrderDate 'OrderHeader/OrderDate', 
      OrderID 'OrderHeader/OrderID', 
      (SELECT
          LineItems2.StockItemID '@ProductID', 
          StockItems.StockItemName '@ProductName', 
          LineItems2.UnitPrice '@Price', 
          Quantity '@Qty'
       FROM Sales.OrderLines LineItems2 
       INNER JOIN Warehouse.StockItems StockItems ON LineItems2.StockItemID = StockItems.StockItemID
       WHERE LineItems2.OrderID = Base.OrderID 
       FOR XML PATH('Product'), TYPE) 'OrderDetails'
    FROM
    (
      SELECT DISTINCT
        Customers.CustomerName, 
        SalesOrder.OrderDate, 
        SalesOrder.OrderID
      FROM Sales.Orders SalesOrder
      INNER JOIN Sales.OrderLines LineItem ON SalesOrder.OrderID = LineItem.OrderID
      INNER JOIN Sales.Customers Customers ON Customers.CustomerID = SalesOrder.CustomerID
      WHERE customers.CustomerID = OuterCust.CustomerID
    ) Base 
    FOR XML PATH('Order'), ROOT ('SalesOrders'), TYPE) AS OrderSummary
FROM Sales.Customers OuterCust
GO

-- Посмотрим, что получилось 
SELECT TOP 3 * FROM Sales.OrderSummary

-- Нужен первичный ключ с кластерным индексом
ALTER TABLE Sales.OrderSummary 
ADD CONSTRAINT PK_OrderSummary 
PRIMARY KEY CLUSTERED(ID)
GO


-- Посмотрим на запросы без индекса
SELECT ID
FROM Sales.OrderSummary
WHERE OrderSummary.exist('/SalesOrders/Order/OrderDetails/Product/@ProductID[.="22"]') = 1
GO
--Table 'OrderSummary'. Scan count 1, logical reads 9, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 7262, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

-- SQL Server Execution Times:
--   CPU time = 422 ms,  elapsed time = 439 ms.

-- -----------------------
-- Создаем индексы
-- -----------------------

-- !!! может выполняться долго
CREATE PRIMARY XML INDEX [XML_Primary_OrderSummary]
ON Sales.OrderSummary ([OrderSummary])
GO

-- С первичным индексом
SELECT ID
FROM Sales.OrderSummary
WHERE OrderSummary.exist('/SalesOrders/Order/OrderDetails/Product/@ProductID[.="22"]') = 1
GO
--Table 'OrderSummary'. Scan count 0, logical reads 2168, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'xml_index_nodes_1819153526_256000'. Scan count 3, logical reads 17796, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

-- SQL Server Execution Times:
--   CPU time = 468 ms,  elapsed time = 228 ms.


CREATE XML INDEX [XML_SecondaryPATH_OrderSummary]
ON Sales.OrderSummary (OrderSummary)
USING XML INDEX [XML_Primary_OrderSummary] 
FOR PATH
GO

-- С вторичным PATH-индексом
SELECT ID
FROM Sales.OrderSummary
WHERE OrderSummary.exist('/SalesOrders/Order/OrderDetails/Product/@ProductID[.="22"]') = 1
GO
--Table 'OrderSummary'. Scan count 0, logical reads 2168, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'xml_index_nodes_1819153526_256000'. Scan count 3, logical reads 17796, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

-- SQL Server Execution Times:
--   CPU time = 470 ms,  elapsed time = 296 ms.



-- VALUE xml-index

SELECT ID
FROM Sales.OrderSummary
WHERE OrderSummary.exist('//Product/@ProductID[.="194"]') = 1
--Table 'OrderSummary'. Scan count 0, logical reads 2148, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'xml_index_nodes_1819153526_256000'. Scan count 3, logical reads 17796, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

-- SQL Server Execution Times:
--   CPU time = 610 ms,  elapsed time = 328 ms.

CREATE XML INDEX [XML_SecondaryVALUE_OrderSummary]
ON Sales.OrderSummary (OrderSummary)
USING XML INDEX [XML_Primary_OrderSummary] 
FOR VALUE
GO

-- С вторичным VALUE-индексом
SELECT ID
FROM Sales.OrderSummary
WHERE OrderSummary.exist('//Product/@ProductID[.="194"]') = 1

--Table 'OrderSummary'. Scan count 1, logical reads 7, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'xml_index_nodes_1819153526_256000'. Scan count 1, logical reads 12, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

-- SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 11 ms.