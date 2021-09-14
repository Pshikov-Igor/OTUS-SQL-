-----------------------------------
-- SMK - SERVICE MASTER KEY
-----------------------------------

-- backup SMK
BACKUP SERVICE MASTER KEY TO FILE = 'D:\otus\mssql\smk.key' 
ENCRYPTION BY PASSWORD = 'P@ssw0rd';

-- restore SMK
RESTORE SERVICE MASTER KEY FROM FILE = 'D:\otus\mssql\smk.key' 
DECRYPTION BY PASSWORD = 'P@ssw0rd';

-----------------------------------
-- TDE - прозрачное шифрование
-----------------------------------
-- нужно создать DMK (DATABASE MASTER KEY) и сертификат и master
USE master;

DROP MASTER KEY;

CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'MasterP@ssw0rd';

-- бэкап ключа
--BACKUP MASTER KEY TO FILE = 'D:\otus\mssql\SQL2012_master.dmk' 
--ENCRYPTION BY PASSWORD = 'P@ssw0rd';

CREATE CERTIFICATE DemoTdeCertificate 
WITH SUBJECT = 'DemoTdeCertificate';

USE master
ALTER DATABASE EncryptedDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS EncryptedDB;
GO 
CREATE DATABASE EncryptedDB;
GO

USE EncryptedDB;
GO

-- ключ для БД
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_192
ENCRYPTION BY SERVER CERTIFICATE DemoTdeCertificate;

-- включаем шифрование
ALTER DATABASE EncryptedDB
SET ENCRYPTION ON;

-- metadata 
SELECT name 
FROM sys.databases
WHERE is_encrypted = 1;

SELECT *
FROM sys.dm_database_encryption_keys;

-- для восстановления на другом сервере
-- -- сделать бэкап ключа
BACKUP CERTIFICATE DemoTdeCertificate TO FILE = 'd:\otus\mssql\EncryptedDB.cer' 
	WITH PRIVATE KEY ( 
		FILE  = 'd:\otus\mssql\EncryptedDB.pvk', 
		ENCRYPTION BY PASSWORD = 'P@ssw0rd' 
);
GO

-- -- и восстановить на другом сервере
USE master;
CREATE CERTIFICATE DemoTdeCertificate FROM FILE = 'd:\otus\mssql\EncryptedDB.cer' 
	WITH PRIVATE KEY ( 
		FILE  = 'd:\otus\mssql\EncryptedDB.pvk', 
		DECRYPTION BY PASSWORD = 'P@ssw0rd'
);

-- ------------------------
-- Шифрование бэкапа
-- ------------------------
USE master;

CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'Pa$$word';

BACKUP DATABASE EncryptedDB 
TO DISK = 'd:\otus\mssql\EncryptedDB.bak'
WITH ENCRYPTION 
  (ALGORITHM = AES_256, SERVER CERTIFICATE = DemoTdeCertificate), FORMAT;

  
-- Какие DMK зашифрованы SMK
SELECT name, is_master_key_encrypted_by_server
FROM sys.databases
ORDER BY name;