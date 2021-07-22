-- ----------------------
-- OPENJSON
-- ----------------------
-- Этот пример запустить сразу весь по [F5]

-- Считываем JSON-файл в переменную (!!! измените путь к XML-файлу)

DECLARE @json nvarchar(max)

SELECT @json = BulkColumn
FROM OPENROWSET
(BULK 'D:\otus\ms-sql-server\2021-03\08-xml_json_hw\examples\03-open_json.json', 
 SINGLE_CLOB)
as data 

-- Проверяем, что в @json
SELECT @json as [@json]


-- OPENJSON Без структуры

SELECT * FROM OPENJSON(@json)

SELECT * FROM OPENJSON(@json, '$.Suppliers')

-- Type:
--    0 = null
--    1 = string
--    2 = int
--    3 = bool
--    4 = array
--    5 = object

-- OPENJSON Явное описание структуры
SELECT *
FROM OPENJSON (@json, '$.Suppliers')
WITH (
    Id	        int,
    Supplier    nvarchar(100)   '$.SupplierInfo.Name',    
    Contact     nvarchar(max)   '$.Contact' AS JSON,
    City        nvarchar(100)   '$.CityName'
)
