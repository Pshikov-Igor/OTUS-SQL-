SELECT
	Invoices.InvoiceID,
	Invoices.InvoiceDate,
	(
		SELECT People.FullName
		--—отрудники
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice,
	(
		--«аказы (строки)
		SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId
									--«аказы
									FROM Sales.Orders
									WHERE Orders.PickingCompletedWhen IS NOT NULL
											AND Orders.OrderId = Invoices.OrderId)
	) AS TotalSummForPickedItems
--—чета‘актуры
FROM Sales.Invoices
	JOIN (SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
		  --—троки—чет‘актур
		  FROM Sales.InvoiceLines
		  GROUP BY InvoiceId
		  HAVING SUM(Quantity*UnitPrice) > 27000
		 ) AS SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;
----------------------------------------------------------------------------------------------------------------
--—оберем «аказы
with tablePickedItems as (
							SELECT Orders.OrderId, 
								SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) as Summa
							FROM Sales.OrderLines
							JOIN Sales.Orders ON OrderLines.OrderId = Orders.OrderId
							WHERE Orders.PickingCompletedWhen IS NOT NULL
							GROUP BY Orders.OrderId
						 ),
--—чета‘актуры
    tableSalesTotals as (
							SELECT Invoices.InvoiceID, Invoices.OrderId, Invoices.SalespersonPersonID, Invoices.InvoiceDate, SUM(Quantity*UnitPrice) AS TotalSumm
							--—троки—чет‘актур
							FROM Sales.Invoices 
							JOIN Sales.InvoiceLines ON Invoices.InvoiceID = InvoiceLines.InvoiceID
							GROUP BY Invoices.InvoiceID, Invoices.OrderId, Invoices.SalespersonPersonID, Invoices.InvoiceDate
							HAVING SUM(Quantity*UnitPrice) > 27000
						 )

Select	tableSalesTotals.InvoiceID,
		tableSalesTotals.InvoiceDate,
		People.FullName AS SalesPersonName,
		tableSalesTotals.TotalSumm AS TotalSummByInvoice,
		tablePickedItems.Summa AS TotalSummForPickedItems
FROM Application.People 
JOIN tableSalesTotals on People.PersonID = tableSalesTotals.SalespersonPersonID
JOIN tablePickedItems on tableSalesTotals.OrderId = tablePickedItems.OrderId
ORDER BY TotalSumm DESC;