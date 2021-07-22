-- ��������� �������� �� ����� ������ � ��������� ��� ��� �������� � ������������� ������
--��������� �� � �������������������� �����, �������� ���������
USE master
GO
ALTER DATABASE WideWorldImporters SET SINGLE_USER WITH ROLLBACK IMMEDIATE

USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER;	-- ���������� �������� service broker. !���������� �� ������ � ������������ ������
					-- �������������� � ������������ ������ ���� ����� �� ALTER DATABASE

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; -- � ��������� ���������� �����������
-- ��������� �������� �� ����� ������
select DATABASEPROPERTYEX ('WideWorldImporters','UserAccess');
SELECT is_broker_enabled FROM sys.databases WHERE name = 'WideWorldImporters';

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa]; -- ������� ����������� ��� sa, ��� ������� � ������ ��������

ALTER DATABASE WideWorldImporters SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO

--������� ���� � �������, � ������� ����� ������ ��������� �� �������
use WideWorldImporters;
ALTER TABLE Sales.Invoices
ADD InvoiceConfirmedForProcessing DATETIME;

-- ������ ������, ���� �� �������� ����������� ��� SA
--An exception occurred while enqueueing a message in the target queue. Error: 33009, State: 2. 
--The database owner SID recorded in the master database differs from the database owner SID recorded in database 'WideWorldImporters'. 
--You should correct this situation by resetting the owner of database 'WideWorldImporters' using the ALTER AUTHORIZATION statement.