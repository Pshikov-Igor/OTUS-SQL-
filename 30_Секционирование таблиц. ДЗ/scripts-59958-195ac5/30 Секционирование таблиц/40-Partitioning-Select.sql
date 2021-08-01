use WideWorldImporters;
SET STATISTICS io, time on;

-- посмотрим план запроса
-- все грустно %(
SELECT 
	Inv.InvoiceID, Inv.InvoiceDate, 
	Details.Quantity, Details.UnitPrice
FROM Sales.InvoicesYears AS Inv
	JOIN Sales.InvoiceLinesYears AS Details
		ON Inv.InvoiceID = Details.InvoiceID
			AND Inv.InvoiceDate = Details.InvoiceDate
WHERE Inv.CustomerID = 1;

-- смотрим план
-- используется нужная секция
SELECT 
	Inv.InvoiceID, Inv.InvoiceDate, 
	Details.Quantity, Details.UnitPrice
FROM Sales.InvoicesYears AS Inv
	JOIN Sales.InvoiceLinesYears AS Details
		ON Inv.InvoiceID = Details.InvoiceID
			AND Inv.InvoiceDate = Details.InvoiceDate
WHERE Inv.CustomerID = 1
	AND Inv.InvoiceDate > '20160101'
		AND Inv.InvoiceDate < '20160501';


--космический план
SELECT Client.CustomerName, 
	Inv.InvoiceID, Inv.InvoiceDate, 
	Item.StockItemName, 
	Details.Quantity, Details.UnitPrice, PayClient.CustomerName AS BillForCustomer
FROM Sales.InvoicesYears AS Inv
	JOIN Sales.InvoiceLinesYears AS Details
		ON Inv.InvoiceID = Details.InvoiceID
	JOIN Sales.Customers AS Client 
		ON Client.CustomerID = Inv.CustomerID
	JOIN Application.People AS People
		ON People.PersonID = Inv.SalespersonPersonID
	JOIN Sales.Customers AS PayClient 
		ON PayClient.CustomerID = Inv.BillToCustomerID
	INNER LOOP JOIN Warehouse.StockItems AS Item 
		ON Item.StockItemID = Details.StockItemID
WHERE PayClient.CustomerID = 1;