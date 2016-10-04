
/****** Object:  StoredProcedure [dbo].[P_Harticle]    Script Date: 11/27/2015 16:26:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[P_Harticle] 
@startDate datetime,
@EndDate datetime
AS
BEGIN 

DELETE  FROM T_Harticle 
WHERE DATEPART(yy,bidate)=DATEPART(yy,@startDate) OR DATEPART(yy,bidate)=DATEPART(yy,@EndDate)

INSERT INTO T_Harticle(
            [bidate]
           ,[gnlws]
           ,[gnlwyycs]
           ,[SCIlwbzcw]
           ,[cdgjkyktbzcw]
           ,[cdsjkyktbzcw]
           ,[hdgjkyjjbzcw]
           ,[hdsjkyjjbzcw])
SELECT  rq,MAX(CASE WHEN zdid='A040' THEN sz ELSE 0 end) gnlws,MAX(CASE WHEN zdid='A365' THEN sz ELSE 0 end) gnlwyycs,
        MAX(CASE WHEN zdid='A196' THEN sz ELSE 0 end) SCIlwbzcw,MAX(CASE WHEN zdid='A235' THEN sz ELSE 0 end) cdgjkyktbzcw,
        MAX(CASE WHEN zdid='A222' THEN sz ELSE 0 end) cdsjkyktbzcw,MAX(CASE WHEN zdid='A110' THEN sz ELSE 0 end) hdgjkyjjbzcw,
        MAX(CASE WHEN zdid='A338' THEN sz ELSE 0 end) hdsjkyjjbzcw
        from mpehr_hl..[TBmsj_Value] --≤Â»Î÷µ±Ì 
WHERE zdid IN ('A040','A196','A365','A222','A235','A110','A338')  
      AND (DATEPART(yy,rq)=DATEPART(yy,@startDate) OR DATEPART(yy,rq)=DATEPART(yy,@EndDate))
GROUP BY rq 
      


end 
/*
 exec [P_Harticle]  '2015-09-01','2016-07-06' 
 
 select * from T_Harticle 
 
delete from T_Harticle  

delete mpehr_hl..[TBmsj_Value]

*/





