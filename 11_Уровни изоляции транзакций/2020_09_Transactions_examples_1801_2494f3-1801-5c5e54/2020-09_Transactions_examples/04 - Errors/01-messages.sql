
-- Msg 8134, Level 16, State 1, Line 2
-- Divide by zero error encountered.
select 1 / 0

-- код последней ошибки
select @@ERROR;
GO

SELECT * 
FROM sys.messages
WHERE message_id = 8134

-- RAISERROR 

-- msg_id | msg_str | @local_variable
-- severity
-- state

-- Можно писать произвольный текст
RAISERROR('Cannot process Employee', 16, 1);

RAISERROR('Processing Employee', 1, 1);

RAISERROR('Processing Employee', 1, 1) WITH LOG;


-- Можно использовать готовые сообщения из sys.messages

EXEC sp_addmessage 
    @msgnum=50002,
	@severity=16,
	@msgtext='Cannot process Employee with ID=%s'
GO

RAISERROR(50002, 16, 1, '12345');
GO

SELECT * 
FROM sys.messages
WHERE message_id = 50002

EXEC sp_dropmessage @msgnum=50002 
GO


