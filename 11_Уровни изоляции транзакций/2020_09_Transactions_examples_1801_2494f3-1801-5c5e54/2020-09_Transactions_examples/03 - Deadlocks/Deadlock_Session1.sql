USE WideWorldImporters
GO

-- ������ People, ����� Orders

-- 0. �������, ��� ���������� ��� (Locks.sql)

-- SET DEADLOCK_PRIORITY LOW

-- 1. �������� ���������� � ��������� SELECT
BEGIN TRAN

SELECT PersonId, FullName, PreferredName,  PhoneNumber
FROM Application.People
WHERE FullName = 'Kayla Woodcock'
AND IsEmployee = 1;

-- 2. �������� ������ ���������� >>>>>

-- 3. UPDATE People
UPDATE Application.People
SET PreferredName = 'Kaila'
WHERE PersonID = 2;

-- ������� ����������

-- 4. UPDATE Orders � ������ ���������� >>>>

-- 5. UPDATE Orders

UPDATE Sales.Orders
SET SalespersonPersonID = 16
WHERE SalespersonPersonID = 2
	AND OrderId IN (73535, 73537, 73545);
 
-- 6. UPDATE People � ������ ���������� >>>>

-- !!! deadlock

SELECT XACT_STATE() as XACT_STATE
ROLLBACK

-- ��������� SET DEADLOCK_PRIORITY LOW