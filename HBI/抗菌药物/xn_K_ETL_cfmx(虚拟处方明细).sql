USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[xn_K_ETL_cfmx]    Script Date: 12/05/2015 11:15:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM K_Ypxx WHERE bidate BETWEEN '2015-01-01' AND '2015-01-31'
--将处方中有退药的药品信息过滤掉
alter ProceDure [dbo].[xn_K_ETL_cfmx]   
 @StartDate datetime,
 @EndDate datetime
as
Begin 
--select top 1000  sflbdm,sflbmc,* from K_Ypxx  where biyear=2015 and bimonth=6 order by cfid

select kstype,cfid,blh,ypid into #cfypid
from K_Ypxx 
where convert(varchar(10),bidate,120) between convert(varchar(10),@StartDate,120) and convert(varchar(10),@EndDate,120)
group by kstype,cfid,blh,ypid 
having sum(xssl) <>0


select  a.bidate,a.kstype,a.cfid,a.ysname,a.yscode,a.kscode,a.ksname,a.ypid,a.ypmc,a.xssl,a.lydw,a.cfje,a.blh,a.hzxm,a.iskss,a.kssdj
from K_Ypxx  a,#cfypid b
where a.kstype=b.kstype and a.cfid=b.cfid and a.blh=b.blh and a.ypid=b.ypid


       



end