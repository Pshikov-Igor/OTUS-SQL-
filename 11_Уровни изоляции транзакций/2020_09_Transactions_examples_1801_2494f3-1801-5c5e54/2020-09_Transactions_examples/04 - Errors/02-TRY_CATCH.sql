USE WideWorldImporters
SET XACT_ABORT OFF;

DROP TABLE IF EXISTS [test];
GO
CREATE TABLE [dbo].[test](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[dateCreated] [datetime] NULL,
	[valueX] [decimal](19, 4) NULL,
	[valueZ] [decimal](19, 4) NULL,
	[valueY] [decimal](19, 4) NULL
)
GO

-- При ошибке (деление на ноль) сразу сообщение пользователю
DECLARE @x DECIMAL(19,4),
		@y DECIMAL(19,4),
		@z DECIMAL(19,4)

SET @x = 10
SET @z = 0

SET @y = @x / @z;
	
SELECT 'success y = '+ CAST(@y AS VARCHAR(10));
SELECT 'error z = ' + CAST(@z AS VARCHAR(10));
GO


-- TRY/CATCH - можем обработать ошибку 

DECLARE @x DECIMAL(19,4),
		@y DECIMAL(19,4),
		@z DECIMAL(19,4)

BEGIN TRY 
	SET @x = 10
	SET @z = 0

	SET @y = @x / @z;
	
	SELECT 'success y = '+ CAST(@y AS VARCHAR(10));
END TRY
BEGIN CATCH
	SELECT 'error z = ' + CAST(@z AS VARCHAR(10));
END CATCH
GO

-- пример выше - так хорошо или плохо делать?

-- RAISEERROR
-- CATCH обрабатывает ошибки с severity > 10
BEGIN TRY 
	RAISERROR('some error', 10, 1);
	SELECT 'success';
END TRY
BEGIN CATCH
	SELECT 'error';
END CATCH
GO

BEGIN TRY 
	RAISERROR('Processing Employee from TRY', 1, 1)
	RAISERROR('Processing Employee from TRY', 1, 1) WITH LOG;


	RAISERROR('some error', 11, 1);
	SELECT 'success';
END TRY
BEGIN CATCH
	SELECT 'error';
END CATCH
GO


DECLARE @x DECIMAL(19,4),
		@y DECIMAL(19,4),
		@z DECIMAL(19,4),
		@id INT;

BEGIN TRY
	BEGIN TRAN 
	SET @x = 10
	SET @z = 0

	INSERT INTO dbo.test (valueX, valueZ) VALUES (@x, @z)

	SET @id = SCOPE_IDENTITY()
	SET @y = @x / @z;

	UPDATE dbo.test SET valueY = @y WHERE id = @id
	
	SELECT 'success y = '+ CAST(@y AS VARCHAR(10));
	COMMIT
END TRY
BEGIN CATCH
	DECLARE @errorCode INT,
			@errorMessage NVARCHAR(1000);

	SELECT XACT_STATE() as [XACT_STATE];

	IF @@TRANCOUNT > 0 
		ROLLBACK TRANSACTION;

	SELECT XACT_STATE() as [XACT_STATE];

	SET @errorCode = ERROR_NUMBER();
	SET @errorMessage = 
		'Server: ' + @@SERVERNAME + 
		', Error: '+ ERROR_MESSAGE() +
		', ErrorNumber: ' + CAST(@errorCode AS VARCHAR(10)) +
		', ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(),'') +
		', ErrorLine: ' + CAST(ERROR_LINE() AS VARCHAR(10));

	RAISERROR (@errorMessage, 16, 1)
END CATCH
GO


-- В таблице пусто (транзакция откатилась)
SELECT * FROM dbo.test;

-- А если убрать ROLLBACK TRANSACTION ?

-- THROW
DECLARE @x DECIMAL(19,4),
		@y DECIMAL(19,4),
		@z DECIMAL(19,4),
		@id INT;

BEGIN TRY
	BEGIN TRAN 
	SET @x = 10
	SET @z = 0
	INSERT INTO dbo.test (valueX, valueZ)
	VALUES (@x, @z)

	SET @id = SCOPE_IDENTITY()
	SET @y = @x / @z;

	UPDATE dbo.test SET valueY = @y WHERE id = @id
	
	SELECT 'success y = '+ CAST(@y AS VARCHAR(10));
	COMMIT
END TRY
BEGIN CATCH

	SELECT XACT_STATE();
	IF @@TRANCOUNT > 0 
		ROLLBACK TRANSACTION;

	THROW;
END CATCH
GO

SELECT * FROM dbo.test;