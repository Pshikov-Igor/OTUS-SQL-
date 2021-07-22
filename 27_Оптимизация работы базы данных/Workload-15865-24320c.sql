use Optimization;
SELECT * from [dbo].[Workload] ORDER by WorkloadName;

insert into [dbo].[Workload] values(1,'test');

update [dbo].[Workload] set [WorkloadName] = 'boom'
where [WorloadID]=1;

delete from [dbo].[Workload] where [WorloadID] =1;

select * from [dbo].[Workload];