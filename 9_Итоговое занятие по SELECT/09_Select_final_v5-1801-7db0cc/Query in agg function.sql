  SET STATISTICS IO,TIME ON;
  with SessionResult as(
		select UserID,
			   Session,
			   Success,
			   Count(*) Count 
		from Calculate.UsersResult
		group by UserID,Session,Success
	)
  	select
			Cast(us.ResultDateStamp as nvarchar(Max)) [����],
			Cast(us.Time as nvarchar(Max)) [������������ �����������],
			Cast(isnull(srS.Count,0) as nvarchar(Max)) [���������� ���������� �������],
			Cast(isnull(srF.Count,0)+isnull(srS.Count,0) as nvarchar(Max)) [����� ��������]
	from [Calculate].[UsersScore] us
	join Users.Main um on um.Id=us.UserId
	left join SessionResult srF on srF.UserId=us.UserId and srF.Session=us.Session and srF.Success=0
	left join SessionResult srS on srS.UserId=us.UserId and srS.Session=us.Session and srS.Success=1
	where us.UserID=1
	order by us.ResultDateStamp desc
	
	select s.ResultDateStamp [����],
		   s.Time [������������ �����������], 
		   s.score [���������� ���������� �������], 
		   sum(CASE WHEN (r.success = 0 or r.Success is null) THEN 0 ELSE 1 END) [���������� ���������� �������], 
		   --sum(IIF(isnull(r.success,0)=0,0,1)) [���������� ���������� �������], 
		   --sum(f.x) [���������� ���������� �������], 
		   count(r.EquationId) [����� ��������] 
	from Calculate.UsersScore s 
	left join Calculate.UsersResult r on s.session = r.session 
	--cross apply (select 
	--					CASE WHEN (r.success = 0 or r.Success is null) 
	--					THEN 0 ELSE 1 
	--			 END) f(x)
	where s.UserId = 1
	group by s.[ResultDateStamp], s.[Time], s.score
	order by s.ResultDateStamp desc
