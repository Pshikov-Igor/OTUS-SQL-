--https://blogs.msdn.microsoft.com/hanspo/2016/01/20/partitioning-of-temporal-tables-in-sql-server-2016/

use WideWorldImporters;
DROP TABLE if EXISTS MyTempTable;
DROP TABLE if EXISTS MyTempStaging;

CREATE TABLE MyTempTable (
  Id int ,
  Created DATE,
  Data nvarchar(1000) NULL,
  CONSTRAINT [PK_MyTempTable] PRIMARY KEY CLUSTERED 
(
	ID ASC,
	Created ASC
)
) ON [schmYearPartition] (Created)

CREATE TABLE MyTempStaging (
  Id int ,
  Created DATE,
  Data nvarchar(1000) NULL,
  CONSTRAINT [PK_MyTempStage] PRIMARY KEY CLUSTERED 
(
	ID ASC,
	Created ASC) 
) ON [schmYearPartition] (Created);

--наполним табличку
--посмотрим, что внутри таблицы
SELECT $PARTITION.fnYearPartition(Created) AS Partition,   
COUNT(*) AS [COUNT], MIN(Created),MAX(Created) 
FROM MyTempTable
GROUP BY $PARTITION.fnYearPartition(Created) 
ORDER BY Partition ;  

select * from MyTempTable;

--посмотрим, что внутри таблицы —тейджинг
SELECT $PARTITION.fnYearPartition(Created) AS Partition,   
COUNT(*) AS [COUNT], MIN(Created),MAX(Created) 
FROM [MyTempStaging]
GROUP BY $PARTITION.fnYearPartition(Created) 
ORDER BY Partition ;  

select * from MyTempTable;
select * from MyTempStaging;
truncate table MyTempStaging;

ALTER TABLE MyTempTable SWITCH PARTITION 8 TO [MyTempStaging] PARTITION 8;

