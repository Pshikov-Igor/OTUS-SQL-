--����� �������� ����������� ����� ���������
-- http://lasmart.ru/index.php?id=sekcionirovanie-i-rabota-s-sekcionirovannymi-tablicami
--ALTER TABLE Orders SWITCH PARTITION 1 TO Orders_Work PARTITION 1 

--�������� 2 ������ ������
Alter Partition Function fnYearPartition() MERGE RANGE ('20120101');

--�������� ������
Alter Partition Function fnYearPartition() SPLIT RANGE ('20140701');	

Alter Partition Function fnYearPartition() MERGE RANGE ('20140701');

--�������� ������
Alter Partition Function fnYearPartition() SPLIT RANGE ('20120101');	

--����������� �������� 
TRUNCATE TABLE Sales.InvoicesYears
WITH (PARTITIONS (1));

-- ����������� ����� �������� ��� ����������� ��������
ALTER PARTITION SCHEME [schmYearPartition]  
NEXT USED [YearData]; 