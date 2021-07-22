USE WideWorldImporters
GO

DROP TABLE IF EXISTS dbo.test
SET IMPLICIT_TRANSACTIONS OFF;
GO

CREATE TABLE dbo.test 
(
	id INT IDENTITY(1,1), 
	[name] VARCHAR(10), 
	amount INT
)
GO

SELECT @@TRANCOUNT AS TransactionCount, XACT_STATE() as XACT_STATE;
GO

-- XACT_STATE():
-- 1  - �������� ����������
-- 0  - ��� �������� ����������
-- -1 - ���� �������� ����������, �� ��������� �����-�� �������

-- �������� ���������� ����������

BEGIN TRAN --  BEGIN TRANSACTION
  SELECT @@TRANCOUNT AS TransactionCount, XACT_STATE() as XACT_STATE;

  INSERT INTO dbo.test (name, amount)
  VALUES ('orange', 10);

  SELECT * FROM dbo.test;

  INSERT INTO dbo.test (name, amount)
  VALUES ('apple', 10);

  SELECT * FROM dbo.test;

COMMIT TRAN -- COMMIT TRANSACTION

SELECT * FROM dbo.test;

-- ����� ����������, ROLLBACK
BEGIN TRAN 

  UPDATE dbo.test
  SET amount = 0 
  WHERE name = 'apple';

  SELECT * FROM dbo.test;

  INSERT INTO dbo.test (name, amount)
  VALUES ('banana', 99);

  SELECT * FROM dbo.test;

ROLLBACK -- ROLLBACK TRANSACTION 

SELECT * FROM dbo.test;

-- autocommit

INSERT INTO dbo.test (name, amount)
VALUES ('banana', 123);

SELECT * FROM dbo.test;

-- ������� ����������
-- �� ������� BEGIN

SET IMPLICIT_TRANSACTIONS ON;
-- ��� ������� INSERT ������� BEGIN TRAN 
	INSERT INTO dbo.test (name, amount)
	VALUES ('lemon', 111);

	SELECT @@TRANCOUNT AS TransactionCount, XACT_STATE() as XACT_STATE;

	SELECT * FROM dbo.test;

ROLLBACK

-- �������, ��� � �������
SELECT * FROM dbo.test;

SET IMPLICIT_TRANSACTIONS OFF;


DROP TABLE IF EXISTS dbo.test
SET IMPLICIT_TRANSACTIONS OFF;
GO