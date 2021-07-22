-- посмотрим свойства БД через студию и попробуем там его включить в НЕэкслюзивном режиме
--переведем БД в однопользовательский режим, отключив остальных
USE master
GO
ALTER DATABASE WideWorldImporters SET SINGLE_USER WITH ROLLBACK IMMEDIATE

USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER;	-- необходимо включить service broker. !Включается он только в эксклюзивном режиме
					-- соответственно у пользователя должны быть права на ALTER DATABASE

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; -- и разрешить доверенные подключения
-- посмотрим свойства БД через студию
select DATABASEPROPERTYEX ('WideWorldImporters','UserAccess');
SELECT is_broker_enabled FROM sys.databases WHERE name = 'WideWorldImporters';

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa]; -- добавим авторизацию для sa, для доступа с других серверов

ALTER DATABASE WideWorldImporters SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO

--добавим поле в таблицу, в которое будем писать изменения из очереди
use WideWorldImporters;
ALTER TABLE Sales.Invoices
ADD InvoiceConfirmedForProcessing DATETIME;

-- пример ошибки, если не включить авторизацию для SA
--An exception occurred while enqueueing a message in the target queue. Error: 33009, State: 2. 
--The database owner SID recorded in the master database differs from the database owner SID recorded in database 'WideWorldImporters'. 
--You should correct this situation by resetting the owner of database 'WideWorldImporters' using the ALTER AUTHORIZATION statement.