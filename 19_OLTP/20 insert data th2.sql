use WideWorldImporters;

exec Sales.OrdersMem_Insert @rowcount = 1000000;

Delete from Sales.OrdersMem;


MERGE Sales.InvoiceTotals AS target 
	USING (SELECT DATEADD(mm,DATEDIFF(mm,0,I.InvoiceDate),0) AS InvoiceMonth, 
				Count(I.InvoiceId), Count(IL.InvoiceLineID), 
				SUM(IL.Quantity), Sum(IL.UnitPrice), SUM(IL.TaxAmount), SUM(IL.ExtendedPrice)
		FROM Sales.InvoiceLines AS IL
			join Sales.Invoices AS I
				ON I.InvoiceID = IL.InvoiceID
		WHERE I.InvoiceDate >= '20130101'
			AND I.InvoiceDate < '20130301'
		GROUP BY DATEADD(mm,DATEDIFF(mm,0,InvoiceDate),0) 
		) 
		AS source (InvoiceMonth, InvoiceAmount, InvoiceLineAmount, TotalQuantity, TotalUnitPrice, TotalTaxAmount, TotalExtendedPrice) 
		ON
	 (target.TotalDate = source.InvoiceMonth) 
	WHEN MATCHED 
		THEN UPDATE SET InvoiceAmount = source.InvoiceAmount,
						InvoiceLineAmount = source.InvoiceLineAmount,
						TotalQuantity = source.TotalQuantity,
						TotalUnitPrice = source.TotalUnitPrice,
						TotalTaxAmount = source.TotalTaxAmount,
						TotalExtendedPrice = source.TotalExtendedPrice
	WHEN NOT MATCHED 
		THEN INSERT (TotalDate, InvoiceAmount, InvoiceLineAmount, TotalQuantity, TotalUnitPrice, TotalTaxAmount, TotalExtendedPrice) 
			VALUES (source.InvoiceMonth, source.InvoiceAmount, source.InvoiceLineAmount, source.TotalQuantity, source.TotalUnitPrice, source.TotalTaxAmount, source.TotalExtendedPrice) 
	OUTPUT deleted.*, $action, inserted.*;

MERGE 
 [Sales].[OrdersMem]  AS target 
USING (SELECT 20 AS OrderLineId, 20 AS OrderId, 20 AS StockItem, 200 AS Quantity)
	AS source (OrderLineId, OrderId, [StockItemID], Quantity)
	ON (target.OrderLineId = source.OrderLineId)
WHEN MATCHED 
		THEN UPDATE SET
			Quantity = Source.Quantity
WHEN NOT MATCHED 
		THEN INSERT
		(OrderLineID, OrderId, StockItemID, Quantity) 
		VALUES (Source.OrderLineID, Source.OrderId, Source.StockItemID, Source.Quantity)
OUTPUT deleted.*, $action, inserted.*;

MERGE 
 [Sales].[OrdersDisk]  AS target 
USING (SELECT *
FROM [Sales].[OrdersMem]
WHERE OrderLineId = 200)
	AS source (OrderLineId, OrderId, [StockItemID], Quantity)
	ON (target.OrderLineId = source.OrderLineId)
WHEN MATCHED 
		THEN UPDATE SET
			Quantity = Source.Quantity
WHEN NOT MATCHED 
		THEN INSERT
		(OrderLineID, OrderId, StockItemID, Quantity) 
		VALUES (Source.OrderLineID, Source.OrderId, Source.StockItemID, Source.Quantity)
OUTPUT deleted.*, $action, inserted.*;

/*
	UPDATE Sales.OrdersMem
	SET Quantity = 50; 
*/

--
--DELETE FROM Sales.OrdersMem;