--можем партиции переключать между таблицами
-- http://lasmart.ru/index.php?id=sekcionirovanie-i-rabota-s-sekcionirovannymi-tablicami
--ALTER TABLE Orders SWITCH PARTITION 1 TO Orders_Work PARTITION 1 

--смерджим 2 пустые секции
Alter Partition Function fnYearPartition() MERGE RANGE ('20120101');

--разделим секцию
Alter Partition Function fnYearPartition() SPLIT RANGE ('20140701');	

Alter Partition Function fnYearPartition() MERGE RANGE ('20140701');

--разделим секцию
Alter Partition Function fnYearPartition() SPLIT RANGE ('20120101');	

--странкейтим партицию 
TRUNCATE TABLE Sales.InvoicesYears
WITH (PARTITIONS (1));

-- переключить схему хранения для последующих партиций
ALTER PARTITION SCHEME [schmYearPartition]  
NEXT USED [YearData]; 