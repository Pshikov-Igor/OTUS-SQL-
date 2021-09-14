-----------------------------------
-- HASH
-----------------------------------
-- https://docs.microsoft.com/ru-ru/sql/t-sql/functions/hashbytes-transact-sql?view=sql-server-2017
-- <algorithm>::= MD2 | MD4 | MD5 | SHA | SHA1 | SHA2_256 | SHA2_512   

SELECT HASHBYTES('SHA2_512', N'123456')

-----------------------------------
-- SYMMETRIC KEY
-----------------------------------
USE WideWorldImporters;
GO

SELECT p.FullName, p.PhoneNumber
FROM [Application].People p
GO

CREATE SYMMETRIC KEY PeopleKey 
WITH ALGORITHM = AES_256
ENCRYPTION BY PASSWORD = 'P@ssw0rd';
GO

SELECT *
FROM sys.symmetric_keys;
GO

-- Открываем ключ, а потом закрываем
-- Дешифрование работает при открытом ключе
OPEN SYMMETRIC KEY PeopleKey 
DECRYPTION BY PASSWORD = 'P@ssw0rd';

	SELECT * FROM sys.openkeys;

	SELECT 
		p.FullName, 
		p.PhoneNumber,
		ENCRYPTBYKEY(KEY_GUID('PeopleKey'), CAST(p.PhoneNumber as NVARCHAR(20))) as WhoKnows
	FROM [Application].People p
	GO

CLOSE SYMMETRIC KEY PeopleKey;

-- если ключ закрыт, то данные зашифрованы
SELECT * FROM sys.openkeys;
GO

SELECT 
	p.FullName, 
	p.PhoneNumber,
	ENCRYPTBYKEY(KEY_GUID('PeopleKey'), CAST(p.PhoneNumber as NVARCHAR(20))) as WhoKnows
FROM [Application].People p
GO

-----------------------------------
-- ASYMMETRIC KEY
-----------------------------------
USE WideWorldImporters;
GO
CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'P@ssw0rd';

DROP SYMMETRIC KEY PeopleKey;
DROP ASYMMETRIC KEY PeopleAsymKey;

CREATE ASYMMETRIC KEY PeopleAsymKey 
WITH ALGORITHM = RSA_2048;

CREATE SYMMETRIC KEY PeopleKey 
WITH ALGORITHM = AES_256
ENCRYPTION BY ASYMMETRIC KEY PeopleAsymKey;

OPEN SYMMETRIC KEY PeopleKey 
DECRYPTION BY ASYMMETRIC KEY PeopleAsymKey;

SELECT * FROM sys.openkeys;

SELECT 
	p.FullName, 
	p.PhoneNumber,
	ENCRYPTBYKEY(KEY_GUID('PeopleKey'), CAST(p.PhoneNumber as NVARCHAR(20))) as WhoKnows
FROM [Application].People p
GO

CLOSE SYMMETRIC KEY PeopleKey;