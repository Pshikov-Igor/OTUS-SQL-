USE WideWorldImporters;

-- ====================================================
-- READ UNCOMMITTED
-- ====================================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRAN;

	-- ������ � ������ ����������
	SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	-- >>>>> ��������� ���-�� ����������� >>>>>
	
	-- ������ ����� ������������ ���������
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';

COMMIT;

-- ====================================================
-- READ COMMITTED
-- ====================================================
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SET LOCK_TIMEOUT time  -- ������������, 
-- -1 - ����������, 
-- 0 - �� ����

-- SET LOCK_TIMEOUT 10000
-- SELECT @@LOCK_TIMEOUT

BEGIN TRAN;
	-- ������ � ������ ����������
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	-- >>>>> ��������� ���-�� ����������� >>>>>
		
	-- ������ ����� ������������ ���������
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
COMMIT;


-- ====================================================
-- REPEATABLE READ
-- ====================================================
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRAN;

	-- ������ � ������ ����������
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	-- >>>>> ��������� ���-�� ����������� >>>>>
	
	-- ������ ����� ������������ ���������
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
COMMIT;


-- ====================================================
-- SERIALIZABLE
-- ====================================================
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRAN;

	-- ������ � ������ ����������
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	-- >>>>> ��������� ���-�� ����������� >>>>>
	
	-- ������ ����� ������������ ���������
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
COMMIT;

-- ROLLBACK;

-- ====================================================
-- READ_COMMITTED_SNAPSHOT
-- ====================================================

-- ��������� READ_COMMITTED_SNAPSHOT
ALTER DATABASE WideWorldImporters 
SET READ_COMMITTED_SNAPSHOT ON;
GO

-- ��������, ��� ������� SNAPSHOT
SELECT 
    DB_NAME(database_id), 
    is_read_committed_snapshot_on,
    snapshot_isolation_state_desc     
FROM sys.databases
WHERE database_id = DB_ID();
GO

-- ====================================================
-- READ COMMITTED (with READ_COMMITTED_SNAPSHOT ON)
-- ====================================================
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRAN;

	-- ������ � ������ ����������
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
	
	-- >>>>> ��������� ���-�� ����������� >>>>>
	
	-- ������ ����� ������������ ���������
    SELECT PersonId, FullName, PhoneNumber
	FROM Application.People
	WHERE FullName like 'Kayla Woodcock%';
COMMIT;

-- SNAPSHOT
-- ALTER DATABASE WideWorldImporters 
-- SET ALLOW_SNAPSHOT_ISOLATION ON;