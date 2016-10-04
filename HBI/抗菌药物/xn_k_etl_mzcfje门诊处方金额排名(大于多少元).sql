USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[K_ETL_Cf]    Script Date: 03/20/2015 09:30:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM K_Ypxx WHERE bidate BETWEEN '2015-01-01' AND '2015-01-31'
--exec [K_ETL_Cf] '2015-01-01','2015-03-30'
alter ProceDure [dbo].[xn_K_ETL_mzcfje]   
 @StartDate VARCHAR(10),
 @EndDate VARCHAR(10),
 @je int
as
Begin 
--select top 1000  * from K_Ypxx order by bidate desc


select  cfid INTO #cf from K_Ypxx 
where CONVERT(VARCHAR(10),bidate,120) between @StartDate and @EndDate AND kstype LIKE '01%'
group by cfid
having sum(xssl) <>0


SELECT a.cfid into #cf2 FROM  K_Ypxx a
WHERE EXISTS (SELECT 1 FROM #cf WHERE a.cfid=#cf.cfid) and kstype LIKE '01%'
GROUP BY a.cfid
HAVING SUM(cfje)>@je


SELECT biyear,biquarter,bimonth,biweek, bidate,kscode,cfid,ypid,ypmc,iskss ,SUM(cfje),ksname FROM  K_Ypxx a
WHERE EXISTS (SELECT 1 FROM #cf2 WHERE a.cfid=#cf2.cfid)   and kstype like '01%'
GROUP BY biyear,biquarter,bimonth,biweek, bidate,kscode,ksname,cfid,ypid,ypmc,iskss,ksname






end