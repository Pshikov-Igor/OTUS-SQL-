SET STATISTICS IO, TIME ON

DECLARE @dt DATETIME = GETDATE()

DECLARE 
@dateBegin DATETIME = DATEFROMPARTS( YEAR( DATEADD(YEAR, -5, GETDATE())), 01, 01),
-- cast(cast(year(dateadd(year, -5, GETDATE())) as varchar(4)) +'0101' as date),@dateEnd DATETIME = DATEFROMPARTS( YEAR( DATEADD(YEAR, -5, GETDATE())), 12, 31)
--cast(cast(year(dateadd(year, -5, GETDATE())) as varchar(4)) +'1231' as date)
--DATEFROMPARTS( YEAR( DATEADD(YEAR, -5, GETDATE())), 01, 01)

--DATEFROMPARTS

​
DECLARE @TotalItems TABLE 
	(StockItemId INT, 
	Quantity INT);
​
DECLARE @MaxQuantityPerCustomer TABLE 
	(CustomerId INT, 
	Quantity INT);
​
INSERT INTO @TotalItems
(StockItemId, Quantity)
SELECT DISTINCT L.StockItemID, SUM(L.Quantity)
FROM Sales.InvoiceLines AS L
	JOIN Sales.Invoices AS I
		ON I.InvoiceID = L.InvoiceID
		AND I.InvoiceDate BETWEEN @dateBegin AND @dateEnd 
GROUP BY L.StockItemId
ORDER BY L.StockItemID;
​
INSERT INTO @MaxQuantityPerCustomer
(CustomerId, Quantity)
SELECT I.CustomerID, MAX(L.Quantity) AS Q
FROM Sales.InvoiceLines AS L
	JOIN Sales.Invoices AS I
		ON I.InvoiceID = L.InvoiceID
		AND I.InvoiceDate BETWEEN @dateBegin AND @dateEnd 
GROUP BY I.CustomerID
ORDER BY Q DESC;
​
WITH Invoices AS 
(SELECT Inv.InvoiceDate, Inv.BillToCustomerID, 
	Inv.CustomerID, Inv.SalespersonPersonID, Inv.OrderID, Details.StockItemID,
	Inv.InvoiceID, Details.Quantity, Details.PackageTypeID
FROM Sales.Invoices AS Inv
	JOIN Sales.InvoiceLines AS Details
		ON Inv.InvoiceID = Details.InvoiceID)
SELECT
    Client.CustomerName, 
	Inv.InvoiceID, 
	Inv.InvoiceDate, 
	Item.StockItemName, 
	Inv.Quantity, 
	(SELECT T.Quantity 
		FROM @TotalItems AS T 
		WHERE T.StockItemID = Inv.StockItemID) AS TotalItems,
	(SELECT C.Quantity 
		FROM @MaxQuantityPerCustomer AS C 
		WHERE C.CustomerId = Inv.CustomerID) AS MaxByClient,
	PayClient.CustomerName AS BillForCustomer,
	Pack.PackageTypeName,
	People.FullName AS SalePerson,
	Inv.Quantity AS PickedQuantity
FROM Invoices AS Inv
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Inv.StockItemID
	JOIN Warehouse.PackageTypes AS Pack
		ON Pack.PackageTypeID = Inv.PackageTypeID
WHERE Inv.InvoiceDate BETWEEN @dateBegin AND @dateEnd 
	 AND Inv.Quantity > 0
ORDER BY TotalItems DESC, Inv.Quantity DESC, Client.CustomerName;
