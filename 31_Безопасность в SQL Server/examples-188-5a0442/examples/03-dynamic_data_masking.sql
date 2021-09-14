-- -------------------------------
-- Dynamic Data Masking (DDM)
-- -------------------------------
USE master
ALTER DATABASE DdmDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS DdmDemo
GO

CREATE DATABASE DdmDemo
GO

USE DdmDemo
GO

CREATE TABLE Users(
	ID int IDENTITY PRIMARY KEY,
	FullName nvarchar(100) MASKED WITH (FUNCTION = 'partial(2, "...", 2)') NULL,
	Phone nvarchar(50)     MASKED WITH (FUNCTION = 'default()') NULL,
	Email nvarchar(100)    MASKED WITH (FUNCTION = 'email()') NULL,
	Age int                MASKED WITH (FUNCTION = 'random(20, 70)') NULL
)
GO

-- Заполняем данными
INSERT INTO Users (FullName, Phone, Email, Age) 
VALUES 
('Ivanov Ivan',  '8(900) 123-34-67', 'ivan@somedomain.com', 30),
('Petrov Petr',  '8(900) 123-42-89', 'petd@somedomain.ro',  30),
('Sidorov Alex', '8(900) 123-12-75', 'alex@somedomain.org', 30)
GO

-- У пользователя dbo есть разрешение UNMASK
SELECT * FROM Users
GO

-- Создаем пользоваля без разрешения UNMASK 
CREATE USER TestUser WITHOUT LOGIN
GRANT SELECT ON Users TO TestUser
GRANT SHOWPLAN TO TestUser
GO

-- TestUser - данные маскированы
EXECUTE AS USER = 'TestUser'
	SELECT * FROM Users
REVERT
GO

-- Даем разрешение UNMASK
GRANT UNMASK TO TestUser
GO

EXECUTE AS USER = 'TestUser'
	SELECT * FROM Users
REVERT 
GO

-- Убираем UNMASK 
REVOKE UNMASK FROM TestUser
GO

EXECUTE AS USER = 'TestUser'
	SELECT ID, FullName, Phone, Email, Age, Age, Age FROM Users
REVERT 
GO
