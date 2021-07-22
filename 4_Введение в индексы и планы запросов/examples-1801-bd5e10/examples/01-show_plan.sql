use WideWorldImporters

-- -----------------------------------------------
-- 1) Что такое план запроса и как его смотреть
-- -----------------------------------------------

-- Действительный план в виде текста
-- Запрос выполняется и отображается его план
SET STATISTICS PROFILE ON

SELECT TOP 10 *
FROM Sales.Orders 

SET STATISTICS PROFILE OFF
GO

-- ------------------------------------------------

-- Действительный план в виде XML
-- Запрос выполняется и отображается его план
SET STATISTICS XML ON

SELECT TOP 10 *
FROM Sales.Orders 

SET STATISTICS XML OFF
GO

-- -----------------------------------------------

-- Предполагаемый (потенциальный, оценочный, estimated) план в виде текста
-- Запрос НЕ выполняется, только отображается его план

SET SHOWPLAN_TEXT ON --  text 
GO

SELECT TOP 10 *
FROM Sales.Orders
GO

SET SHOWPLAN_TEXT OFF
GO

-- -----------------------------------------------

-- Предполагаемый (потенциальный, оценочный, estimated) план в виде текста
-- с дополнительной информацияей.
-- Запрос НЕ выполняется, только отображается его план

SET SHOWPLAN_ALL ON 
GO

SELECT TOP 10 *
FROM Sales.Orders
GO

SET SHOWPLAN_ALL OFF
GO

-- -----------------------------------------------

-- Предполагаемый (потенциальный, оценочный, estimated) план в виде XML
-- Запрос НЕ выполняется, только отображается его план
SET SHOWPLAN_XML ON -- XML
GO

SELECT TOP 10 *
FROM Sales.Orders
GO

SET SHOWPLAN_XML OFF
GO

-- -----------------------------------------------

-- Просмотр планов в SSMS:
--  Предполагаемый план - Меню: Query \ Display Estimated Execution Plan
--  Действительный план - Меню: Query \ Include Actual Execution Plan
--  "Живой" план        - Меню: Query \ Include Live Query Statistics

-- Будет ли разница в следующих запросах?
-- (разный порядок JOIN)

SELECT so.*, li.*
FROM Sales.Orders AS so
JOIN Sales.OrderLines AS li ON so.OrderID = li.OrderID
WHERE so.CustomerID = 832 AND so.SalespersonPersonID = 2

SELECT so.*, li.*
FROM Sales.OrderLines AS li
JOIN Sales.Orders AS so ON so.OrderID = li.OrderID
WHERE so.CustomerID = 832 AND so.SalespersonPersonID = 2
GO

-- Сохранение планов в XML в SSMS: 
-- правой кнопкой на плане -> Save Execution Plan As...

-- Сравнение планов в SSMS: 
-- правой кнопкой на плане -> Compare Showplan

-- SSMS: 
-- панель свойств оператора (выделить оператор в плане и нажать F4)
-- всплывающая подсказка на операторе (навести мышку над оператором)
-- XML

-- Actual vs Estimated значения в свойствах оператора
-- Для стоимости только Estimated

-- А если FORCE ORDER ?

SELECT so.*, li.*
FROM Sales.Orders AS so
JOIN Sales.OrderLines AS li ON so.OrderID = li.OrderID
WHERE so.CustomerID = 832 AND so.SalespersonPersonID = 2
OPTION (FORCE ORDER);

SELECT so.*, li.*
FROM Sales.OrderLines AS li
JOIN Sales.Orders AS so ON so.OrderID = li.OrderID
WHERE so.CustomerID = 832 AND so.SalespersonPersonID = 2
OPTION (FORCE ORDER);
GO

-- Запросы выше из статьи (перевод) "Почему для SQL Server важна статистика" 
-- https://habr.com/ru/company/otus/blog/489366/
