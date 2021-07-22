-- ------------
-- OPEN XML
---------------
-- Этот пример запустить сразу весь по [F5]

-- Переменная, в которую считаем XML-файл
DECLARE @xmlDocument  xml

-- Считываем XML-файл в переменную
-- !!! измените путь к XML-файлу
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'D:\otus\ms-sql-server\2021-03\08-xml_json_hw\examples\02-open_xml.xml', 
 SINGLE_CLOB)
as data 

-- Проверяем, что в @xmlDocument
SELECT @xmlDocument as [@xmlDocument]

DECLARE @docHandle int
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument

-- docHandle - это просто число
SELECT @docHandle as docHandle

SELECT *
FROM OPENXML(@docHandle, N'/Orders/Order')
WITH ( 
	[ID] int  '@ID',
	[OrderNum] int 'OrderNumber',
	[CustomerNum] int 'CustomerNumber',
	[City] nvarchar(10) 'Address/City',
	[Address] nvarchar(100) 'Address',
	[OrderDate] date 'OrderDate')

-- можно вставить в таблицу
DROP TABLE IF EXISTS #Orders

CREATE TABLE #Orders(
	[ID] int,
	[OrderNumber] int,
	[CustomerNumber] int,
	[City] nvarchar(100),
	[OrderDate] date
)

INSERT INTO #Orders
SELECT *
FROM OPENXML(@docHandle, N'/Orders/Order')
WITH ( 
	[ID] int  '@ID',
	[OrderNum] int 'OrderNumber',
	[CustomerNum] int 'CustomerNumber',
	[City] nvarchar(10) 'Address/City',
	[OrderDate] date 'OrderDate')	

-- Надо удалить handle
EXEC sp_xml_removedocument @docHandle

SELECT * FROM #Orders

DROP TABLE IF EXISTS #Orders
GO
