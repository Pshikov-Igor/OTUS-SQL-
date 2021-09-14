USE WideWorldImporters

-- ------------------------
-- Логины
-- ------------------------

-- windows-аутентификация
-- У вас пользователь "win-rlvkdqgk4c8\vagrant" будет другим
CREATE LOGIN "win-rlvkdqgk4c8\user1" FROM WINDOWS;

-- SQL Server аутентификация
-- DROP LOGIN user1
CREATE LOGIN user1 WITH PASSWORD = 'P@ssw0rd';

-- смотрим список логинов
SELECT * FROM sys.server_principals

-- отключение/включение логин
ALTER LOGIN user1 DISABLE;
ALTER LOGIN user1 ENABLE;

-- добавление к роли
ALTER SERVER ROLE diskadmin ADD MEMBER user1;  

-- кто входит в роль
exec sp_helpsrvrolemember 'diskadmin'

-- все роли и пользователи (уровня инстанса)
exec sp_helpsrvrolemember 

-- удаление из роли
ALTER SERVER ROLE diskadmin DROP MEMBER user1;  

-- проверяем, что роли больше нет
exec sp_helpsrvrolemember 'diskadmin'

-- разрешения ролей
exec sp_srvrolepermission 

-- смотрим как это все выглядит в SSMS

-- ------------------------
-- Пользователи БД
-- ------------------------

USE WideWorldImporters

-- создание пользователя и связь с логином
-- DROP USER user1 
CREATE USER user1 FOR LOGIN user1

-- добавление роли
EXEC sp_addrolemember 'db_datawriter', user1
-- см. SSMS

-- кто входит в роли
exec sp_helprolemember


-- создание роли
-- DROP ROLE CustomRole
CREATE ROLE TableCreatorRole;
GRANT CREATE TABLE TO TableCreatorRole;

-- добавляем к роли
EXEC sp_addrolemember 'TableCreatorRole', user1;

-- sp_change_users_login 
--  для эксперимента удаляем логин user1 и создаем его заново
DROP LOGIN user1
CREATE LOGIN user1 WITH PASSWORD = 'P@ssw0rd';
-- см. SSMS нет связи логина и пользователя

-- исправляем
EXEC sp_change_users_login @Action='Report';
EXEC sp_change_users_login 'Auto_Fix', 'user1'

-- проверяем
EXEC sp_change_users_login @Action='Report';

-- EXEC sp_change_users_login 'Update_One', 'user1' /*user*/, 'user1'; /*login*/

-- можно исправить и так:
ALTER USER user1 WITH LOGIN = user1;

-- смотрим как это все выглядит в SSMS

-- логины 
SELECT * FROM sys.server_principals

-- пользователи
-- sid - ссылка на server_principals.sid
SELECT * FROM sys.database_principals 


