USE WideWorldImporters
GO

-- результат в output-переменную (C# - out SqlInt32 result)
declare @result int;
exec dbo.[Add] 3, 4, @result output;
select @result;
go 

-- Простое использование SqlPipe (аналог print)
print 'hello'
exec dbo.MyPrint 'hello message'
GO

-- Генерирование ResultSet
exec dbo.Fibonacci 2, 3, 5
GO

-- Запрос данных в БД
exec usp_CountOrdersFoDeliveryCity_ExecuteAndSend 242

exec usp_CountOrdersFoDeliveryCity_ExecuteReader 242
GO
