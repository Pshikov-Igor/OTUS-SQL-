use WideWorldImporters

-- Чистим от предыдущих экспериментов
DROP FUNCTION IF EXISTS dbo.fn_SayHello
GO
DROP PROCEDURE IF EXISTS dbo.usp_SayHello
GO
DROP ASSEMBLY IF EXISTS SimpleDemoAssembly
GO

-- Включаем CLR
exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO

exec sp_configure 'clr enabled', 1;
exec sp_configure 'clr strict security', 0 
GO

-- clr strict security 
-- 1 (Enabled): заставляет Database Engine игнорировать сведения PERMISSION_SET о сборках 
-- и всегда интерпретировать их как UNSAFE. По умолчанию, начиная с SQL Server 2017.

reconfigure;
GO

-- Для возможности создания сборок с EXTERNAL_ACCESS или UNSAFE
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; 

-- Подключаем dll 
CREATE ASSEMBLY SimpleDemoAssembly
FROM 'D:\otus\mssql\clr-2020-09\01-SimpleDemo\bin\Debug\SimpleDemo.dll'
WITH PERMISSION_SET = SAFE;  

-- DROP ASSEMBLY SimpleDemoAssembly

-- Файл сборки (dll) на диске больше не нужен, она копируется в БД

-- Подключить функцию из dll - AS EXTERNAL NAME
CREATE FUNCTION dbo.fn_SayHello(@Name nvarchar(100))  
RETURNS nvarchar(100)
AS EXTERNAL NAME [SimpleDemoAssembly].[ExampleNamespace.DemoClass].SayHelloFunction;
GO 

-- Без namespace будет так:
-- [SimpleDemoAssembly].[DemoClass].SayHelloFunction

-- Используем функцию
SELECT dbo.fn_SayHello('OTUS Student')

-- Подключить процедуру из dll - AS EXTERNAL NAME 
CREATE PROCEDURE dbo.usp_SayHello  
(  
    @Name nvarchar(50)
)  
AS EXTERNAL NAME [SimpleDemoAssembly].[ExampleNamespace.DemoClass].SayHelloProcedure;  
GO 

-- Используем ХП
exec dbo.usp_SayHello @Name = 'OTUS Student';

-- --------------------------

-- Как посмотреть зарегистрированные сборки 

-- SSMS
-- <DB> -> Programmability -> Assemblies 

-- Посмотреть подключенные сборки (SSMS: <DB> -> Programmability -> Assemblies)
SELECT * FROM sys.assemblies

-- Проверяем, что создали ХП и функцию
SELECT * FROM sys.assembly_modules

-- Посмотреть "код" сборки
-- SSMS: <DB> -> Programmability -> Assemblies -> Script Assembly as -> CREATE To