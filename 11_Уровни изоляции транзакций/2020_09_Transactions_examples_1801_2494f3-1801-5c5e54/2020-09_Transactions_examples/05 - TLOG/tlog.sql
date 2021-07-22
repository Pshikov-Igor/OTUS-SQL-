USE WideWorldImporters

CHECKPOINT
-- BACKUP LOG WideWorldImporters TO DISK='NUL:'
GO
DBCC SHRINKFILE(WWI_Log)
GO

SELECT * 
FROM sys.fn_dblog(NULL,NULL)

-- Смотрим на примере 01 - Transactions\01-Transactions.sql

SELECT 
  Operation, 
  Description,
  [Compression Info], 
  [Compression Log Type], 
  [Lock Information],
  * 
FROM sys.fn_dblog(NULL,NULL)
WHERE [Transaction ID] = '0000:1750091'
