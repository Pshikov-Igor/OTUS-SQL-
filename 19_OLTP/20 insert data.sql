 use WideWorldImporters;
 declare @rowcount  INT = 1000000;

 DECLARE @i INT = 1;  
 BEGIN TRAN
  WHILE @i <= @rowcount  
  BEGIN;  
    INSERT INTO Sales.OrdersDisk
		(OrderLineID, OrderId, StockItemID, Quantity) 
		VALUES (@i, @i, @i, @i*10);  
    SET @i += 1;  
  END;  
  COMMIT


/*
	UPDATE Sales.OrdersDisk
	SET Quantity = 10; 
*/
--DELETE FROM Sales.OrdersDisk;