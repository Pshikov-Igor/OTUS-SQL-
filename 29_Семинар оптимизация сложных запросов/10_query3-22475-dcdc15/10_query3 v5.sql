SET STATISTICS IO, TIME ON

DECLARE @dt DATETIME = GETDATE()

DECLARE 
@dateBegin DATETIME = DATEFROMPARTS( YEAR( DATEADD(YEAR, -5, GETDATE())), 01, 01),
-- cast(cast(year(dateadd(year, -5, GETDATE())) as varchar(4)) +'0101' as date),@dateEnd DATETIME = DATEFROMPARTS( YEAR( DATEADD(YEAR, -5, GETDATE())), 12, 31);
--cast(cast(year(dateadd(year, -5, GETDATE())) as varchar(4)) +'1231' as date)
--DATEFROMPARTS( YEAR( DATEADD(YEAR, -5, GETDATE())), 01, 01)

--DATEFROMPARTS
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
	SUM(Inv.Quantity) OVER (PARTITION BY Inv.StockItemID)  AS TotalItems,
	MAX(Inv.Quantity) OVER (PARTITION BY Inv.CustomerID) AS MaxByClient,
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
