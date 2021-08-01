use WideWorldImporters;

--создадим файловую группу
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [YearData]
GO

--добавляем файл БД
ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Years', FILENAME = N'D:\1\mssql\Yeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO

--создаем функцию партиционирования по годам - по умолчанию left!!
CREATE PARTITION FUNCTION [fnYearPartition](DATE) AS RANGE RIGHT FOR VALUES
('20120101','20130101','20140101','20150101','20160101', '20170101',
 '20180101', '20190101', '20200101', '20210101');																																																									
GO

--CREATE PARTITION SCHEME [schmYearPartition] AS PARTITION [fnYearPartition] 
--ALL TO ([PRIMARY])


-- партиционируем, используя созданную нами функцию
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
--создаем наши секционированные таблицы
SELECT * INTO Sales.InvoicesPartitioned
FROM Sales.Invoices;

SELECT * INTO Sales.InvoiceLinesPartitioned 
FROM Sales.InvoiceLines;

-- на существующей таблице удалить кластерный индекс и создать новый кластерный индекс с ключом секционирования
-- посмотрим через свойства таблицы -> хранилище

-- но так как у нас в табличке Sales.InvoicesLines нет поля invoiceData - посмотрим следующий скрипт


/*
DROP TABLE IF EXISTS [Sales].[Sales.InvoicesPartitioned];
DROP TABLE IF EXISTS [Sales].[InvoiceLinesYears];
DROP TABLE IF EXISTS [Sales].[InvoicesYears];
DROP PARTITION SCHEME [schmYearPartition];
DROP PARTITION FUNCTION [fnYearPartition];
*/