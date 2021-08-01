SET STATISTICS IO, TIME ON

DECLARE @startdate DATE = DATEADD(yy,-5, DATEADD(yy,DATEDIFF(yy,0, GETDATE()),0)),
		@enddate DATE = GETDATE();

DECLARE @InvoiceStart INT, 
		@InvoiceEnd INT

SELECT @InvoiceStart = MIN(InvoiceId),@InvoiceEnd = MAX(InvoiceId)
FROM Sales.Invoices
WHERE InvoiceDate >= @startdate
AND InvoiceDate < @enddate;

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
	SUM(Inv.Quantity) OVER (PARTITION BY Inv.StockItemId) AS TotalItems,
	MAX(Inv.Quantity) OVER (PARTITION BY Inv.CustomerID) AS MaxByClient,
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
WHERE 
	OrdLines.PickedQuantity > 0 
	AND Inv.InvoiceId >= @InvoiceStart
	AND Inv.InvoiceId <= @InvoiceEnd
	--DATEDIFF(yy, Inv.InvoiceDate, GETDATE())=3
ORDER BY TotalItems DESC, Quantity DESC, CustomerName;

--DROP TABLE #MaxQuantityPerCustomer;
--DROP TABLE #TotalItems;
