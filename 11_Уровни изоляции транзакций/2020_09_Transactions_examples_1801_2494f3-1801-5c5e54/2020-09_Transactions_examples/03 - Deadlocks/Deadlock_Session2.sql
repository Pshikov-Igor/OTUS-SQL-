USE WideWorldImporters
GO

-- ������ Orders, ����� People

-- 2. �������� ���������� � ��������� SELECT
BEGIN TRAN

SELECT PersonId, FullName, PreferredName,  PhoneNumber
FROM Application.People
WHERE FullName = 'Kayla Woodcock'
AND IsEmployee = 1;

-- 3. <<<<< UPDATE People � ������ ����������

-- 4. UPDATE Orders 
UPDATE Sales.Orders
SET Comments = 'Deadlock simulation orders'
WHERE SalespersonPersonID = 2
	AND OrderId IN (73535, 73537, 73545);

-- ������� ����������

-- 5. <<<<< UPDATE Orders � ������ ����������

-- 6. UPDATE People 

UPDATE Application.People
SET PhoneNumber = '(495) 777-0304'
WHERE PersonID = 2;

-- !!! deadlock

SELECT * 
FROM Application.People
WHERE PersonID = 2;

SELECT *
FROM Sales.Orders
WHERE OrderId IN (73535, 73537, 73545)

SELECT XACT_STATE() as XACT_STATE

ROLLBACK