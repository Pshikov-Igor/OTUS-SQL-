SET STATISTICS IO, TIME ON

DECLARE @startdate DATE = DATEADD(yy,-3, DATEADD(yy,DATEDIFF(yy,0, GETDATE()),0)),
		@enddate DATE = GETDATE();

WITH Invoices AS 
(SELECT Inv.InvoiceDate, Inv.BillToCustomerID, 
	Inv.CustomerID, Inv.SalespersonPersonID, Inv.OrderID, 
	Details.InvoiceID, Details.Quantity, Details.StockItemID
FROM Sales.Invoices AS Inv
	JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID
WHERE 
	 Inv.InvoiceDate >= @startdate
	AND Inv.InvoiceDate < @enddate)
, Orders AS 
(SELECT Inv.InvoiceID, OrdLines.OrderLineID, OrdLines.PickedQuantity, 
	OrdLines.StockItemID, OrdLines.PackageTypeID
FROM Sales.Orders AS Ord  
	JOIN Sales.Invoices AS Inv
		ON Ord.OrderID = Inv.OrderID
	JOIN Sales.OrderLines AS OrdLines 
		ON OrdLines.OrderID = Ord.OrderID
WHERE 
	OrdLines.PickedQuantity > 0 
	AND Inv.InvoiceDate >= @startdate
	AND Inv.InvoiceDate < @enddate)
SELECT Client.CustomerName, 
	Inv.InvoiceID, 
	Inv.InvoiceDate, 
	Item.StockItemName, 
	Inv.Quantity, 
	SUM(Inv.Quantity) OVER (PARTITION BY Inv.StockItemId) AS TotalItems,
	MAX(Inv.Quantity) OVER (PARTITION BY Inv.CustomerID) AS MaxByClient,
	PayClient.CustomerName AS BillForCustomer,
	People.FullName AS SalePerson,
	Orders.PickedQuantity
FROM Invoices AS Inv
	JOIN Orders AS Orders
		ON Orders.InvoiceId = Inv.InvoiceID
			AND Orders.StockItemID = Inv.StockItemID
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Inv.StockItemID
	JOIN Warehouse.PackageTypes AS Pack
		ON Pack.PackageTypeID = Orders.PackageTypeID
ORDER BY TotalItems DESC, Quantity DESC, CustomerName;




