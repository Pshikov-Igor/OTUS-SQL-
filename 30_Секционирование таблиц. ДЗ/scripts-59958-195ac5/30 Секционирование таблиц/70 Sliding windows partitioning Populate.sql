USE [WideWorldImporters]
GO

INSERT INTO [dbo].[MyTempTable]
           ([Id]
           ,[Created]
           ,[Data])
     VALUES
           (5
           ,'20180101'
           ,'asdsf')
GO
INSERT INTO [dbo].[MyTempTable]
           ([Id]
           ,[Created]
           ,[Data])
     VALUES
           (11
           ,'20110101'
           ,'asdsf2')
GO


--наполним стейджинг
INSERT INTO [dbo].MyTempStaging
           ([Id]
           ,[Created]
           ,[Data])
     VALUES
           (14
           ,'20150101'
           ,'asdsf')
GO
