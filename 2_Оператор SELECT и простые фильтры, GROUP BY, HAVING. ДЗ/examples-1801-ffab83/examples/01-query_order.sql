USE WideWorldImporters

-- Алиас в WHERE
SELECT OrderLineID AS [Order Line ID],
       Quantity,
       UnitPrice,
       (Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
WHERE [TotalCost] > 1000

-- Алиас в ORDER BY
SELECT OrderLineID AS [Order Line ID],
       Quantity,
       UnitPrice,
       (Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
ORDER BY [TotalCost]

-- Алиас в HAVING
SELECT OrderID,
       count(*) AS [OrderLinesCount]
FROM Sales.OrderLines
GROUP BY OrderID
HAVING OrderLinesCount > 3

-- А как можно переписать запрос, чтобы все-таки использовать алиас? (см. ниже)



SELECT *
FROM
(
    SELECT OrderID,
           count(*) AS [OrderLinesCount]
    FROM Sales.OrderLines
    GROUP BY OrderID
) as Orders
WHERE OrderLinesCount > 3





