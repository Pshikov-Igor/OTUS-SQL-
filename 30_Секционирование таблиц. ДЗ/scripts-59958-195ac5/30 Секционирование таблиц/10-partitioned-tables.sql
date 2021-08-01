use WideWorldImporters;

--�������� �������� ������
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [YearData]
GO

--��������� ���� ��
ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Years', FILENAME = N'D:\1\mssql\Yeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO

--������� ������� ����������������� �� ����� - �� ��������� left!!
CREATE PARTITION FUNCTION [fnYearPartition](DATE) AS RANGE RIGHT FOR VALUES
('20120101','20130101','20140101','20150101','20160101', '20170101',
 '20180101', '20190101', '20200101', '20210101');																																																									
GO

--CREATE PARTITION SCHEME [schmYearPartition] AS PARTITION [fnYearPartition] 
--ALL TO ([PRIMARY])


-- ��������������, ��������� ��������� ���� �������
CREATE PARTITION SCHEME [schmYearPartition] AS PARTITION [fnYearPartition] 
ALL TO ([YearData])
GO

/*
DROP TABLE IF EXISTS [Sales].InvoicesPartitioned;
DROP TABLE IF EXISTS [Sales].InvoiceLinesPartitioned;
DROP PARTITION SCHEME [schmYearPartition];
DROP PARTITION FUNCTION [fnYearPartition];
*/
SELECT count(*) 
FROM Sales.Invoices;
--������� ���� ���������������� �������
SELECT * INTO Sales.InvoicesPartitioned
FROM Sales.Invoices;

SELECT * INTO Sales.InvoiceLinesPartitioned 
FROM Sales.InvoiceLines;

-- �� ������������ ������� ������� ���������� ������ � ������� ����� ���������� ������ � ������ ���������������
-- ��������� ����� �������� ������� -> ���������

-- �� ��� ��� � ��� � �������� Sales.InvoicesLines ��� ���� invoiceData - ��������� ��������� ������


/*
DROP TABLE IF EXISTS [Sales].[Sales.InvoicesPartitioned];
DROP TABLE IF EXISTS [Sales].[InvoiceLinesYears];
DROP TABLE IF EXISTS [Sales].[InvoicesYears];
DROP PARTITION SCHEME [schmYearPartition];
DROP PARTITION FUNCTION [fnYearPartition];
*/