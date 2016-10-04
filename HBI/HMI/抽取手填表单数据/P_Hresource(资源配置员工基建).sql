
/****** Object:  StoredProcedure [dbo].[P_Hresource]    Script Date: 11/27/2015 16:26:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[P_Hresource] 
@startDate datetime,
@EndDate datetime
AS
BEGIN 

DELETE  FROM T_hresource 
WHERE DATEPART(yy,bidate)=DATEPART(yy,@startDate) OR DATEPART(yy,bidate)=DATEPART(yy,@EndDate)

INSERT INTO T_hresource(bidate,ygzs,yss,hlrys,yjrs,yyjzmj)
SELECT  rq,MAX(CASE WHEN zdid='A279' THEN sz ELSE 0 end) ygzs,MAX(CASE WHEN zdid='A199' THEN sz ELSE 0 end) yss,
        MAX(CASE WHEN zdid='A233' THEN sz ELSE 0 end) hlrys,MAX(CASE WHEN zdid='A226' THEN sz ELSE 0 end) yjrs,
        MAX(CASE WHEN zdid='A010' THEN sz ELSE 0 end) yyjzmj
        from mpehr_hl..[TBmsj_Value] --≤Â»Î÷µ±Ì 
WHERE zdid IN ('A010','A279','A199','A226','A233') 
      AND (DATEPART(yy,rq)=DATEPART(yy,@startDate) OR DATEPART(yy,rq)=DATEPART(yy,@EndDate))
GROUP BY rq 
      


end 
/*
 exec [P_Hresource] '2015-09-01','2016-07-06' 
 
 select * from T_hresource 
 
--delete from T_hresource

*/





