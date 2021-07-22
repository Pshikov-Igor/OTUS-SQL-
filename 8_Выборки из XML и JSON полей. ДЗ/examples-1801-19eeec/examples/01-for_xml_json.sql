USE WideWorldImporters

-- Исходные данные
SELECT TOP 3
    SupplierID,
    SupplierName,
    SupplierCategoryName,
    PrimaryContact,
    AlternateContact,
    WebsiteURL,
    CityName
FROM Website.Suppliers

--------------------------
-- FOR XML/JSON PATH
--------------------------
-- иерархия задается через алиасы колонок 
-- сравним представление одних и тех же данных в JSON и XML

-- FOR JSON PATH
SELECT TOP 3
    SupplierID AS [Id],
    SupplierName AS [SupplierInfo.Name],
    SupplierCategoryName AS [SupplierInfo.Category],
    PrimaryContact AS [Contact.Primary],
    AlternateContact AS [Contact.Alternate],
    WebsiteURL [WebsiteURL],
    CityName AS [CityName]
FROM Website.Suppliers
FOR JSON PATH, ROOT('Suppliers'), INCLUDE_NULL_VALUES

 -- FOR XML PATH
SELECT TOP 3
    SupplierID AS [@Id],
    SupplierName AS [SupplierInfo/Name],
    SupplierCategoryName AS [SupplierInfo/Category],
    PrimaryContact AS [Contact/Primary],
    AlternateContact AS [Contact/Alternate],
    WebsiteURL [WebsiteURL],
    CityName AS [CityName],
	'SupplierReference: ' + SupplierReference as "comment()"
FROM Website.Suppliers
FOR XML PATH('Supplier'), ROOT('Suppliers')
GO

--------------------------
-- FOR XML RAW
--------------------------

-- Простой FOR XML RAW 
SELECT TOP 10 CityID,  CityName
FROM Application.Cities
FOR XML RAW

-- Переименование <row> и корневой элемент
SELECT TOP 10 CityID,  CityName
FROM Application.Cities
FOR XML RAW('City'), ROOT('Cities')

-- ELEMENTS
SELECT TOP 10 CityID,  CityName
FROM Application.Cities
FOR XML RAW('City'), ROOT('Cities'), ELEMENTS;


-- Пример, который был с PATH
SELECT TOP 3
    SupplierID AS [@Id],
    SupplierName AS [SupplierInfo/Name],
    SupplierCategoryName AS [SupplierInfo/Category],
    PrimaryContact AS [Contact/Primary],
    AlternateContact AS [Contact/Alternate],
    WebsiteURL [WebsiteURL],
    CityName AS [CityName],
	'SupplierReference: ' + SupplierReference as "comment()"
FROM Website.Suppliers
FOR XML RAW('Supplier'), ROOT('Suppliers')
GO

-- Можно и подзапросы 
-- Недопустимые символы в XML автоматически экранируются
SELECT * FROM (
   SELECT 123 as CityID, 'test"test' as CityName
   union
   SELECT TOP 10 CityID,  CityName
   FROM Application.Cities) as s
FOR XML RAW


-- string aggregation - STRING_AGG с 2017

-- задача - вывести имя штата и список городов в этом штате (в одной строке)
-- +-----------+-------------------------------------------+
-- | StateName |  Cities                                   |
-- +-----------+-------------------------------------------+
-- | Alabama   | Abanda,  Abbeville,  Aberfoil,  Abernant  |
-- | Alaska    | Adak,  Akhiok,  Akiachak,  Akiak,  Akutan |
-- +-----------+-------------------------------------------+

-- https://habr.com/ru/post/200120/

-- исходная таблица
SELECT TOP 10 
	s.StateProvinceName as [StateName],	
	c.CityName 
FROM Application.Cities c 
JOIN Application.StateProvinces s ON s.StateProvinceID = c.StateProvinceID

-- вывести имя штата и список городов в этом штате (в одной строке)
SELECT TOP 10 
	s.StateProvinceName as [StateName],
	
	(select c.CityName + ', ' as 'data()'
	 from Application.Cities c 
	 where s.StateProvinceID = c.StateProvinceID
	 for xml path('')) as Cities
FROM Application.StateProvinces s 

-- data() - https://docs.microsoft.com/ru-ru/sql/relational-databases/xml/column-names-with-the-path-specified-as-data

-- С SQL Server 2017 есть функция STRING_AGG()
SELECT TOP 10 
	s.StateProvinceName as [StateName],	
	STRING_AGG(cast(c.CityName as nvarchar(max)), ', ') as Cities
FROM Application.Cities c 
JOIN Application.StateProvinces s ON s.StateProvinceID = c.StateProvinceID
GROUP BY s.StateProvinceName


-- Про другие варианты (FOR XML/JSON AUTO, FOR XML EXPLICIT)
-- изучите самостоятельно
-- XML - https://docs.microsoft.com/ru-ru/sql/relational-databases/xml/for-xml-sql-server
-- JSON -  https://docs.microsoft.com/ru-ru/sql/relational-databases/json/format-query-results-as-json-with-for-json-sql-server?view=sql-server-ver15#option-2---select-statement-controls-output-with-for-json-auto