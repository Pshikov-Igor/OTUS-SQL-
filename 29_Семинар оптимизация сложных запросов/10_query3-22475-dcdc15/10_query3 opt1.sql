SET STATISTICS IO, TIME ON

DECLARE @startdate DATE = DATEADD(yy,-3, DATEADD(yy,DATEDIFF(yy,0, GETDATE()),0)),
		@enddate DATE = GETDATE();
--DATEADD(yy,-3,GETDATE())
--select DATEADD(yy,-3,GETDATE()),DATEDIFF(yy, @curdate, GETDATE()), @curdate

--I.InvoiceDate > DATEADD(yy,-3,GETDATE())
--DATEDIFF(yy, I.InvoiceDate, @curdate) = 3


CREATE TABLE #TotalItems  
	(StockItemId INT PRIMARY KEY, 
	Quantity INT);

CREATE TABLE #MaxQuantityPerCustomer  
	(CustomerId INT PRIMARY KEY, 
	Quantity INT);

INSERT INTO #TotalItems
(StockItemId, Quantity)
SELECT L.StockItemID, SUM(L.Quantity)
FROM Sales.InvoiceLines AS L
	JOIN Sales.Invoices AS I
		ON I.InvoiceID = L.InvoiceID
		AND I.InvoiceDate >= @startdate
		AND I.InvoiceDate < @enddate
GROUP BY L.StockItemId;

INSERT INTO #MaxQuantityPerCustomer
(CustomerId, Quantity)
SELECT I.CustomerID, MAX(L.Quantity) AS Q
FROM Sales.InvoiceLines AS L
	JOIN Sales.Invoices AS I
		ON I.InvoiceID = L.InvoiceID
		AND I.InvoiceDate >= @startdate
		AND I.InvoiceDate < @enddate
GROUP BY I.CustomerID;

WITH Invoices AS 
(SELECT Inv.InvoiceDate, Inv.BillToCustomerID, 
	Inv.CustomerID, Inv.SalespersonPersonID, Inv.OrderID, 
	Details.InvoiceID, Details.Quantity, Details.StockItemID
FROM Sales.Invoices AS Inv
	JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID)
SELECT Client.CustomerName, 
	Inv.InvoiceID, 
	Inv.InvoiceDate, 
	Item.StockItemName, 
	Inv.Quantity, 
	TotalItems.Quantity AS TotalItems,
	MaxQuantityPerCustomer.Quantity AS MaxByClient,
	PayClient.CustomerName AS BillForCustomer,
	Pack.PackageTypeName,
	People.FullName AS SalePerson,
	OrdLines.PickedQuantity
FROM Invoices AS Inv
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Inv.StockItemID
	JOIN Sales.Orders AS Ord 
		ON Ord.OrderID = Inv.OrderID
	JOIN Sales.OrderLines AS OrdLines
		ON OrdLines.OrderID = Ord.OrderID
		AND OrdLines.StockItemID = Item.StockItemID
	JOIN Warehouse.PackageTypes AS Pack
		ON Pack.PackageTypeID = OrdLines.PackageTypeID
	JOIN #TotalItems AS TotalItems
		ON TotalItems.StockItemId = Inv.StockItemID
	JOIN #MaxQuantityPerCustomer AS MaxQuantityPerCustomer 
		ON MaxQuantityPerCustomer.CustomerId = Inv.CustomerID
WHERE 
	OrdLines.PickedQuantity > 0 
	AND Inv.InvoiceDate >= @startdate
	AND Inv.InvoiceDate < @enddate
	--DATEDIFF(yy, Inv.InvoiceDate, GETDATE())=3
ORDER BY TotalItems DESC, Quantity DESC, CustomerName;

DROP TABLE #MaxQuantityPerCustomer;
DROP TABLE #TotalItems;
