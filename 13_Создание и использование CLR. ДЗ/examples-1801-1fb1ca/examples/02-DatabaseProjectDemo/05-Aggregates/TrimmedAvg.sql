USE WideWorldImporters
GO
-- TrimmedAvg
DROP TABLE IF EXISTS Table2;
GO
CREATE TABLE Table2 (Col1 decimal)
GO

INSERT INTO Table2
VALUES (1), (2), (4), (10)
GO

SELECT *
FROM Table2

SELECT  
	SUM(Col1) as [Sum],	
	AVG(Col1) as [Avg],
	dbo.TrimmedAvg(Col1) as [TrimmedAvg]
FROM Table2
GO

-- demo: debug 

DROP TABLE Table2
