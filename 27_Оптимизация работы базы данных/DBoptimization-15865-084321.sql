
-- Built-in Functions 
SELECT @@CPU_BUSY * CAST(@@TIMETICKS AS float) AS 'CPU microseconds',   
   GETDATE() AS 'As of' ;  

SELECT GETDATE() AS 'Today''s Date and Time',   
@@CONNECTIONS AS 'Login Attempts';  

SELECT @@IO_BUSY*@@TIMETICKS AS 'IO microseconds',   
   GETDATE() AS 'as of';

SELECT @@TOTAL_READ AS 'Reads', @@TOTAL_WRITE AS 'Writes', GETDATE() AS 'As of';  

--DBBCC commands
DBCC CHECKDB ('WideWorldImporters') ;
DBCC CHECKFILEGROUP ;
DBCC CHECKTABLE('Application.People');
DBCC CHECKALLOC ;
DBCC CHECKCATALOG;

--Extended Events
  CREATE EVENT SESSION [tutorial session]
    ON SERVER 
    ADD EVENT sqlserver.sql_statement_completed
    (
        ACTION(sqlserver.sql_text)
        WHERE
        ( [sqlserver].[like_i_sql_unicode_string]([sqlserver].[sql_text], N'%SELECT%HAVING%')
        )
    )
    ADD TARGET package0.event_file
    (SET
        filename = N'C:\D\tutorial_session.xel',
        max_file_size = (2),
        max_rollover_files = (2)
    )
    WITH (
        MAX_MEMORY = 2048 KB,
        EVENT_RETENTION_MODE = ALLOW_MULTIPLE_EVENT_LOSS,
        MAX_DISPATCH_LATENCY = 3 SECONDS,
        MAX_EVENT_SIZE = 0 KB,
        MEMORY_PARTITION_MODE = NONE,
        TRACK_CAUSALITY = OFF,
        STARTUP_STATE = OFF
    );
GO
--extended events drop
IF EXISTS (SELECT *
      FROM sys.server_event_sessions    -- If Microsoft SQL Server.
      WHERE name = 'YourSession')
BEGIN
    DROP EVENT SESSION YourSession
          ON SERVER;    -- If Microsoft SQL Server.
END
go

-- extended events sample sql
SELECT
        c.name,
        Count(*)  AS [Count-Per-Column-Repeated-Name]
    FROM
             sys.syscolumns  AS c
        JOIN sys.sysobjects  AS o
    
            ON o.id = c.id
    WHERE
        o.type = 'V'
        AND
        c.name like '%event%'
    GROUP BY
        c.name
    HAVING
        Count(*) >= 3   --2     -- Try both values during session.
    ORDER BY
        c.name;

--управление EVENT SESSION
ALTER EVENT SESSION [YourSession]
      ON SERVER
    --ON DATABASE
    STATE = START;   -- STOP;

--получение результатов
SELECT
        object_name,
        file_name,
        file_offset,
        event_data,
        'CLICK_NEXT_CELL_TO_BROWSE_XML RESULTS!'
                AS [CLICK_NEXT_CELL_TO_BROWSE_XML_RESULTS],
    
        CAST(event_data AS XML) AS [event_data_XML]
                -- TODO: In ssms.exe results grid, double-click this xml cell!
    FROM
        sys.fn_xe_file_target_read_file(
            'C:\D\tutorial_session_0_132007396211600000.xel',
            null, null, null
        );

--строка для каждого доступного события, имя которого содержит трехсимвольную строку «sql»
SELECT   -- Find an event you want.
        p.name         AS [Package-Name],
        o.object_type,
        o.name         AS [Object-Name],
        o.description  AS [Object-Descr],
        p.guid         AS [Package-Guid]
    FROM
              sys.dm_xe_packages  AS p
        JOIN  sys.dm_xe_objects   AS o
    
                ON  p.guid = o.package_guid
    WHERE
        o.object_type = 'event'   --'action'  --'target'
        AND
        p.name LIKE '%'
        AND
        o.name LIKE '%sql%'
    ORDER BY
        p.name, o.object_type, o.name;

--DMV
--sys.dm_exec_sessions
--поиск пользователей, подключенных к серверу

SELECT login_name ,COUNT(session_id) AS session_count   
FROM sys.dm_exec_sessions   
GROUP BY login_name; 

--курсоры, которые были открыты более определенного периода времени
USE master;  
GO  
SELECT creation_time ,cursor_id   
    ,name ,c.session_id ,login_name   
FROM sys.dm_exec_cursors(0) AS c   
JOIN sys.dm_exec_sessions AS s   
   ON c.session_id = s.session_id   
WHERE DATEDIFF(mi, c.creation_time, GETDATE()) > 5

--поиск сеансов с открытыми транзакциями и бездействием
SELECT s.*   
FROM sys.dm_exec_sessions AS s  
WHERE EXISTS   
    (  
    SELECT *   
    FROM sys.dm_tran_session_transactions AS t  
    WHERE t.session_id = s.session_id  
    )  
    AND NOT EXISTS   
    (  
    SELECT *   
    FROM sys.dm_exec_requests AS r  
    WHERE r.session_id = s.session_id  
    );

--сбора информации о запросах собственного соединения
 SELECT   
    c.session_id, c.net_transport, c.encrypt_option,   
    c.auth_scheme, s.host_name, s.program_name,   
    s.client_interface_name, s.login_name, s.nt_domain,   
    s.nt_user_name, s.original_login_name, c.connect_time,   
    s.login_time   
FROM sys.dm_exec_connections AS c  
JOIN sys.dm_exec_sessions AS s  
    ON c.session_id = s.session_id  
WHERE c.session_id = @@SPID;  

--live query stats
use WideWorldImporters;

select * from Application.People;

--Query Store.enable
ALTER DATABASE WideWorldImporters SET QUERY_STORE (OPERATION_MODE = READ_WRITE); 

--информация о запросах и планах в хранилище запросов
SELECT Txt.query_text_id, Txt.query_sql_text, Pl.plan_id, Qry.*  
FROM sys.query_store_plan AS Pl  
INNER JOIN sys.query_store_query AS Qry  
    ON Pl.query_id = Qry.query_id  
INNER JOIN sys.query_store_query_text AS Txt  
    ON Qry.query_text_id = Txt.query_text_id ; 
	
-- сделаем хотя бы один запрос
use WideWorldImporters;
select * from  Application.People;

--The mapping of wait categories to wait types is available in 
SELECT * FROM sys.query_store_wait_stats;

--diference bertween Ex Plan and Live Query stats
SELECT 
	i.ColorID
	,Quantity		= SUM(si.Quantity)
	,Price			= SUM(si.UnitPrice)
FROM [Sales].[InvoiceLines]	si
JOIN [Warehouse].[StockItems]	i ON si.StockItemID = i.StockItemID
GROUP BY  i.ColorID;

--SQL Trace

DECLARE @return_code INT;
DECLARE @TraceID INT;
DECLARE @maxfilesize BIGINT;
SET @maxfilesize = 5;
--step 1: create a new empty trace definition
EXEC sp_trace_create
                @traceid OUTPUT
               , @options = 2
               , @tracefile = N'C:\D\LongRunningQueries'
               , @maxfilesize = @maxfilesize
    , @stoptime =NULL
    , @filecount = 2;
-- step 2: add the events and columns
EXEC sp_trace_setevent
                @traceid = @TraceID
               , @eventid = 10 -- RPC:Completed
               , @columnid = 1 -- TextData
               , @on = 1;--include this column in trace
EXEC sp_trace_setevent
                @traceid = @TraceID
               , @eventid = 10 -- RPC:Completed
               , @columnid = 13 --Duration
               , @on = 1;--include this column in trace
EXEC sp_trace_setevent
                @traceid = @TraceID
               , @eventid = 10 -- RPC:Completed
               , @columnid = 15 --EndTime
               , @on = 1;--include this column in trace  
EXEC sp_trace_setevent
                @traceid = @TraceID
               , @eventid = 12 -- SQL:BatchCompleted
               , @columnid = 1 -- TextData
               , @on = 1;--include this column in trace
EXEC sp_trace_setevent
                @traceid = @TraceID
               , @eventid = 12 -- SQL:BatchCompleted
               , @columnid = 13 --Duration
               , @on = 1;--include this column in trace
EXEC sp_trace_setevent
                @traceid = @TraceID
               , @eventid = 12 -- SQL:BatchCompleted
               , @columnid = 15 --EndTime
               , @on = 1;--include this column in trace        
-- step 3: add duration filter
DECLARE @DurationFilter BIGINT;
SET @DurationFilter = 10000000; --duration in microseconds
EXEC sp_trace_setfilter
                @traceid = @TraceID
               , @columnid = 13
               , @logical_operator = 0 --AND
               , @comparison_operator = 4 -- greater than or equal to
               , @value = @DurationFilter; --filter value

SELECT @TraceID AS TraceID;


--чтобы получить имя категории события, чтобы результаты можно 
--было упорядочить в алфавитном порядке по категориям, событиям и столбцам
SELECT  tcat.name AS EventCategoryName ,
        tevent.name AS EventClassName ,
        tcolumn.name AS EventColumn ,
        tevent.trace_event_id AS EventID ,
        tbinding.trace_column_id AS ColumnID ,
        tcolumn.type_name AS DataType
 FROM   sys.trace_categories AS tcat
        JOIN sys.trace_events AS tevent
            ON tevent.category_id = tcat.category_id
        JOIN sys.trace_event_bindings AS tbinding
            ON tbinding.trace_event_id = tevent.trace_event_id
        JOIN sys.trace_columns AS tcolumn
            ON tcolumn.trace_column_id = tbinding.trace_column_id
 ORDER BY tcat.name ,
        EventClassName ,
        EventColumn ;


--Start the trace
SELECT * FROM   sys.traces;

--List traces script
DECLARE @TraceID int ;
SET @TraceID = 2 ; -- specify value from sp_trace_create
EXEC sp_trace_setstatus
    @traceid = @TraceID
  ,@status = 1 ;-- start trace

--Viewing Trace Data
SELECT *
FROM fn_trace_gettable(N'C:\D\LongRunningQueries.trc',DEFAULT);

--https://www.mssqltips.com/sqlservertip/3445/using-the-sql-server-default-trace-to-audit-events/

DECLARE @path NVARCHAR(260)
SELECT @path=path FROM sys.traces WHERE is_default = 1
--анализируем данные
SELECT DatabaseName, TextData, Duration, StartTime, EndTime,
SPID, ApplicationName, LoginName   
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass IN (115) and EventSubClass=1
ORDER BY StartTime DESC

--Stop and Delete the Trace
  DECLARE @TraceID int ;
 SET @TraceID = 2 ; -- specify value from sp_trace_create
 EXEC sp_trace_setstatus
    @traceid = @TraceID
    ,@status = 0 ;-- stop trace
 -- delete the trace
 EXEC sp_trace_setstatus
    @traceid = @TraceID
  ,@status = 2 ;-- delete trace


		






