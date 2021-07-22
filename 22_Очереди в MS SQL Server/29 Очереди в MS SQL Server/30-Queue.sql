USE WideWorldImporters;

--создаем очередь
CREATE QUEUE TargetQueueWWI;

--создаем сервис обслуживающий очередь
CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetQueueWWI
       ([//WWI/SB/Contract]);
GO


CREATE QUEUE InitiatorQueueWWI;

CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorQueueWWI
       ([//WWI/SB/Contract]);
GO

--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/create-queue-transact-sql?view=sql-server-ver15
