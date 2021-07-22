USE WideWorldImporters

DROP TABLE IF EXISTS dbo.test_calc
GO 

CREATE TABLE dbo.test_calc (
	id INT IDENTITY(1,1), 
	dateCreated DATETIME DEFAULT GETDATE(), 
	valueX DECIMAL(19,4), 
	valueZ DECIMAL(19,4),
	valueY DECIMAL(19,4));
GO

DECLARE @x DECIMAL(19,4),
		@y DECIMAL(19,4),
		@z DECIMAL(19,4),
		@id INT;

BEGIN TRY
	BEGIN TRAN 
	SET @x = 5
	SET @z = 3
	INSERT INTO dbo.test_calc(valueX, valueZ)
	VALUES (@x, @z)

	SET @x = 10
	SET @z = 0
	INSERT INTO dbo.test_calc(valueX, valueZ)
	VALUES (@x, @z)

	SET @id = SCOPE_IDENTITY()

	SET @y = @x / @z;

	UPDATE dbo.test_calc
	SET valueY = @y
	WHERE id = @id
	
	SELECT 'success y = '+ CAST(@y AS VARCHAR(10));
	COMMIT
END TRY
BEGIN CATCH
	PRINT '------------------------------ CATCH ------------------------------'
	DECLARE @errorCode INT,
			@errorMessage NVARCHAR(1000);

	SELECT XACT_STATE() AS tran_state, @@TRANCOUNT;

	IF @@TRANCOUNT > 0 
		ROLLBACK TRANSACTION;

	SELECT XACT_STATE() AS tran_state_after_rollback, @@TRANCOUNT;

	SET @errorCode = ERROR_NUMBER();
	SET @errorMessage = 
		'Server: ' + @@SERVERNAME
		+ ', Error: '+ ERROR_MESSAGE() 
		+ ', ErrorNumber: ' + CAST(@errorCode AS VARCHAR(10))
		+ ', ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(),'')
		+ ', ErrorLine: ' + CAST(ERROR_LINE() AS VARCHAR(10));

	RAISERROR (@errorMessage, 16, 1)
END CATCH

SELECT *
FROM dbo.test_calc;

-- А если убрать ROLLBACK TRANSACTION ?
