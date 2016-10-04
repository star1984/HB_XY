USE [HBI_GR]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter ProceDure [dbo].[xn_hz_ypje_fb]   
 @StartDate varchar(10),
 @EndDate varchar(10),
 @je int

as
Begin 
--select  top 1000 * from K_Ypxx where yp05<0

--将处方中有退药的药品信息过滤掉
select kstype,cfid,blh,ypid  into #cfyp from K_Ypxx
where convert(varchar(10),bidate,120) between @StartDate and @EndDate 
group by kstype,cfid,blh,ypid
having sum(cfje)<>0


select a.kscode, a.blh,a.biyear,a.biquarter,a.bimonth,a.biweek,a.bidate  into #hz from K_Ypxx a,#cfyp b
where a.kstype=b.kstype and a.cfid=b.cfid and a.blh=b.blh and a.ypid=b.ypid
group by a.kscode, a.blh,a.biyear,a.biquarter,a.bimonth,a.biweek,a.bidate
having sum(a.cfje) >@je
       


select  a.biyear,a.biquarter,a.bimonth,a.biweek, a.bidate,a.kscode, a.blh 
from #hz a




end