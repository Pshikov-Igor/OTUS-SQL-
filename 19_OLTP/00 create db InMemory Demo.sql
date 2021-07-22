CREATE DATABASE imoltp;    --  Transact-SQL  
go  
  
ALTER DATABASE imoltp ADD FILEGROUP [imoltp_mod]  
    CONTAINS MEMORY_OPTIMIZED_DATA;  
  
ALTER DATABASE imoltp ADD FILE  
    (name = [imoltp_dir], filename= 'e:\mssql2017\imoltp_dir')  
    TO FILEGROUP imoltp_mod;  
go  

drop database imoltp;