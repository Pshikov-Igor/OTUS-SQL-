use WideWorldImporters;

-------���������� �������
----������ � ������ �� �������
SELECT	Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, 
		trans.CustomerId, trans.TransactionAmount
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
--and Invoices.CustomerID IN ( 958, 121)
ORDER BY Invoices.CustomerID, trans.TransactionAmount DESC

--
SELECT	Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, 
		trans.CustomerId, trans.TransactionAmount
		, SUM(trans.TransactionAmount) OVER () as sum_all
		, SUM (trans.TransactionAmount) OVER (PARTITION BY trans.CustomerId) as sum_cust
		, SUM(trans.TransactionAmount) 
			OVER (PARTITION BY trans.CustomerId, month(Invoices.InvoiceDate)) as sum_cust_month
		, SUM(trans.TransactionAmount) 
			OVER (PARTITION BY trans.CustomerId, month(Invoices.InvoiceDate)) /
		  SUM(trans.TransactionAmount) OVER (PARTITION BY trans.CustomerId) as sum_percent
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
ORDER BY Invoices.CustomerID, Invoices.InvoiceDate

---
SELECT SupplierID, ColorId, StockItemID, StockItemName,
	UnitPrice,
	SUM(UnitPrice) OVER() AS Total,
	SUM(UnitPrice) OVER(ORDER BY UnitPrice) AS RunningTotal,
	SUM(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID) AS RunningTotalSort,
	SUM(UnitPrice) OVER(ORDER BY StockItemID) AS RunningTotalSortBySID,
	AVG(UnitPrice) OVER() AS Total,
	AVG(UnitPrice) OVER(ORDER BY UnitPrice) AS RunningAvg,
	AVG(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID) AS RunningAvgSort,
	COUNT(UnitPrice) OVER() AS Total,
	COUNT(UnitPrice) OVER(ORDER BY UnitPrice) AS RunningTotal,
	COUNT(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID) AS RunningTotalSort
FROM Warehouse.StockItems
WHERE SupplierID in (5, 7)
ORDER By UnitPrice, StockItemID;



----����������� �������
SELECT InvoiceId, CustomerID
		, ROW_NUMBER() OVER (ORDER BY CustomerID)
		, RANK() OVER (ORDER BY CustomerID) as rank_order
		, DENSE_RANK() OVER (ORDER BY CustomerID) as dense_rank_order
FROM Sales.Invoices;


--� ���������� �� �����
SELECT InvoiceId, InvoiceDate, CustomerID
, RANK() OVER (PARTITION BY month(InvoiceDate) ORDER BY InvoiceDate)
, DENSE_RANK() OVER (PARTITION BY year(InvoiceDate), month(InvoiceDate) ORDER BY InvoiceDate)
FROM Sales.Invoices
order by InvoiceDate;

-- ��������� �� �������
SELECT InvoiceId, InvoiceDate, CustomerID, 
	NTILE(20) OVER (ORDER BY CustomerID) as ntile_20
FROM Sales.Invoices
order by ntile_20;


--������ � ������ �� ������� � ������������ ������ �� ��� (����������)
--  � �����������
SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount,
	(SELECT MAX(inr.TransactionAmount) --���������������/��������� ��������� �� ������� CustomerTransactions
	FROM Sales.CustomerTransactions AS inr
	JOIN Sales.Invoices AS InvoicesInner ON 
		InvoicesInner.InvoiceID = inr.InvoiceID
	WHERE inr.CustomerID = trans.CustomerId -- ���� �� �������� ������� ������� �� ����
		AND InvoicesInner.InvoiceDate < '2014-01-01') AS MaxPerCustomer
FROM Sales.Invoices AS Invoices
JOIN Sales.CustomerTransactions AS trans
	ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate

--������ � ������ �� ������� � ������������ ������ �� ���
SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount,
	--��� ����������, �.�.max
	MAX(trans.TransactionAmount) OVER (PARTITION BY trans.CustomerId) AS MaxPerCustomer 
FROM Sales.Invoices AS Invoices
JOIN Sales.CustomerTransactions AS trans
	ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate

-- ��������� � PIVOT
SELECT * FROM 
	(
	SELECT YEAR(ord.OrderDate) as SalesYear,
			L.UnitPrice*L.Quantity as TotalSales
	 FROM Sales.Orders AS ord 
		 JOIN Sales.OrderLines L ON ord.OrderID = L.OrderID
	) AS Sales
PIVOT (SUM(TotalSales)
FOR SalesYear IN ([2013],[2014],[2015],[2016]))
as PVT;

SELECT YEAR(ord.OrderDate) as SalesYear,
        L.UnitPrice*L.Quantity as TotalSales,
		SUM(L.UnitPrice*L.Quantity) OVER (PARTITION BY YEAR(ord.OrderDate))
 FROM Sales.Orders AS ord 
     JOIN Sales.OrderLines L ON ord.OrderID = L.OrderID
ORDER BY YEAR(ord.OrderDate);



--������� ��� 3 ������ ��� ������� ���������
--����� ������, �� ����� ������, ��� ��� ������� �� ��� �����������, � ����� ������� ������ 3
SELECT *
FROM 
	(
		SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount,
			ROW_NUMBER() OVER (PARTITION BY Invoices.CustomerId ORDER BY trans.TransactionAmount DESC) AS CustomerTransRank
		FROM Sales.Invoices as Invoices
			join Sales.CustomerTransactions as trans
				ON Invoices.InvoiceID = trans.InvoiceID
	) AS tbl
WHERE CustomerTransRank <= 3
order by CustomerID, TransactionAmount desc

----- ������� ��������
--���������� � ����������� � ������������ ��������
SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID, trans.TransactionAmount
		, LAG(trans.TransactionAmount) OVER (ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) as prev
		, LEAD(trans.TransactionAmount) OVER (ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) as Follow 
		, FIRST_VALUE (trans.TransactionAmount) OVER (ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) as First_v 
		, LAST_VALUE (trans.TransactionAmount) OVER (ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) as Last_v
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
ORDER BY  Invoices.InvoiceId, Invoices.InvoiceDate

--�� �� �����, �� � ������������������
SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID,Invoices.BillToCustomerID, trans.TransactionAmount
	, LAG(trans.TransactionAmount) OVER (PARTITION BY Invoices.CustomerId ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) as prev
	, LEAD(trans.TransactionAmount) OVER (PARTITION BY Invoices.CustomerId ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate) as Follow 
FROM Sales.Invoices as Invoices
	join Sales.CustomerTransactions as trans
		ON Invoices.InvoiceID = trans.InvoiceID
WHERE Invoices.InvoiceDate < '2014-01-01'
and Invoices.CustomerID in (958, 884)
ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate

---- ���������� �����������
SELECT SupplierID, StockItemID, StockItemName,UnitPrice,
	LAG(UnitPrice) OVER (ORDER BY UnitPrice) AS lagv,
	LEAD(UnitPrice) OVER (ORDER BY UnitPrice) AS leadv,
	FIRST_VALUE(UnitPrice) OVER (ORDER BY UnitPrice) AS f,
	--��������� �����
	LAST_VALUE(UnitPrice) OVER (ORDER BY UnitPrice ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS l,
	--��������� �������� �� ������ ������ �� ������ �� ������� ������
	LAST_VALUE(UnitPrice) OVER (ORDER BY UnitPrice) AS l_f, 
	LAST_VALUE(UnitPrice) OVER (ORDER BY UnitPrice ROWS BETWEEN UNBOUNDED PRECEDING  AND CURRENT ROW ) AS l_f2, 
	--LAST_VALUE(UnitPrice) OVER () AS l_f2, --������ ������� ������� �������� ��� order by
	--LAST_VALUE(UnitPrice) OVER (ORDER BY 0) AS l2,
	LAST_VALUE(UnitPrice) OVER (ORDER BY 1/0) AS l2--����� �������� ���� �������
FROM Warehouse.StockItems
WHERE SupplierID = 7
ORDER By UnitPrice;

----
SELECT SupplierID, ColorId, StockItemID, StockItemName,
	UnitPrice,
	SUM(UnitPrice) OVER() AS Total,
	SUM(UnitPrice) OVER(ORDER BY UnitPrice) AS RunningTotal,
	SUM(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID) AS RunningTotalSort,
	SUM(UnitPrice) OVER(Partition BY ColorId ORDER BY UnitPrice) AS RunningTotalByColor
	, SUM(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID ROWS UNBOUNDED PRECEDING) AS TotalBoundP
	, SUM(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID ROWS BETWEEN CURRENT row AND UNBOUNDED Following) AS TotalBoundF
	, SUM(UnitPrice) OVER(ORDER BY UnitPrice DESC, StockItemID DESC) AS TotalBoundF2
	, SUM(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID ROWS 2 PRECEDING) AS TotalBound2
	, SUM(UnitPrice) OVER(ORDER BY UnitPrice, StockItemID ROWS BETWEEN 2 PRECEDING AND 3 Following) AS TotalBound4
	--, SUM(UnitPrice) OVER(ORDER BY UnitPrice RANGE UNBOUNDED PRECEDING) AS TotalBoundRange
	--, SUM(UnitPrice) OVER(ORDER BY UnitPrice RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS TotalBoundRange
FROM Warehouse.StockItems
WHERE SupplierID in (5, 7)
ORDER By UnitPrice, StockItemID;

