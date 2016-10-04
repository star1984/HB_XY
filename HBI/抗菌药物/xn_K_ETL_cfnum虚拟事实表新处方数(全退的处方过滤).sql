USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[xn_K_ETL_cfnum]    Script Date: 01/27/2016 10:55:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM K_Ypxx WHERE bidate BETWEEN '2015-01-01' AND '2015-01-31'
--exec [K_ETL_Cf] '2015-01-01','2015-03-30'
alter ProceDure [dbo].[xn_K_ETL_cfnum]   
 @StartDate datetime,
 @EndDate datetime
as
Begin 
--select top 1000  sflbdm,sflbmc,* from K_Ypxx  where biyear=2015 and bimonth=4 order by cfid

select kstype,cfid into #cfid
from K_Ypxx 
where convert(varchar(10),bidate,120) between convert(varchar(10),@StartDate,120) and convert(varchar(10),@EndDate,120)
group by kstype,cfid
having sum(xssl) <>0


select a.biyear,a.biquarter,a.bimonth,a.biweek, a.bidate,a.yfcode,a.yfname,a.kstype,
       a.cfid,a.iskss,a.iszj ,a.kscode,a.sflbdm,a.sflbmc,a.ypid,a.yppzdm,a.yppzmc,c.JXMC
from K_Ypxx  a,#cfid b,hbidata..wb_ypzd c
where a.kstype=b.kstype and a.cfid=b.cfid and a.YPID=c.ypid


       



end