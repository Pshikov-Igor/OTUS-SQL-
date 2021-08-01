DROP TABLE IF EXISTS [Sales].InvoicesPartitioned;

DROP TABLE IF EXISTS [Sales].InvoiceLinesPartitioned;

DROP TABLE  [Sales].[InvoicesYears];

DROP TABLE [Sales].[InvoiceLinesYears];

DROP  PARTITION SCHEME [schmYearPartition];

DROP PARTITION FUNCTION [fnYearPartition];

ALTER DATABASE [WideWorldImporters]  REMOVE FILE [Years];
GO
ALTER DATABASE [WideWorldImporters] REMOVE FILEGROUP [YearData];

