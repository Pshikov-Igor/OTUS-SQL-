ALTER DATABASE [WideWorldImporters] ADD FILEGROUP WWI_UserData  
    CONTAINS MEMORY_OPTIMIZED_DATA;  
  
ALTER DATABASE [WideWorldImporters] ADD FILE  
    (name = demoim_file, filename= 'e:\mssql2017\demoim')  
    TO FILEGROUP WWI_UserData;  

DROP TABLE IF EXISTS Sales.OrdersDisk;
DROP PROCEDURE IF EXISTS Sales.OrdersMem_Insert;
DROP TABLE IF EXISTS Sales.OrdersMem;

Create table Sales.OrdersDisk
([OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	CONSTRAINT [PK_Sales_OrderLinesD] PRIMARY KEY CLUSTERED 
	(
		[OrderLineID] ASC
	));

Create table Sales.OrdersMem
([OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	CONSTRAINT [PK_Sales_OrderLinesMO] PRIMARY KEY NONCLUSTERED 
	(
		[OrderLineID] ASC
	))  WITH (MEMORY_OPTIMIZED=ON, DURABILITY = SCHEMA_AND_DATA); --SCHEMA_ONLY

GO
--DELAYED Durability


DROP PROCEDURE IF EXISTS Sales.OrdersMem_Insert;
GO

CREATE PROCEDURE Sales.OrdersMem_Insert
    @rowcount INT 
  WITH NATIVE_COMPILATION, SCHEMABINDING 
  AS   
  BEGIN ATOMIC   
  WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')  
  
  DECLARE @i INT = 1;  
  WHILE @i <= @rowcount  
  BEGIN;  
    INSERT INTO Sales.OrdersMem
		(OrderLineID, OrderId, StockItemID, Quantity) 
		VALUES (@i, @i, @i, @i*10);  
    SET @i += 1;  
  END;  
END;