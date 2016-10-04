USE [HBI_GR]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter ProceDure [dbo].[xn_ks_hzypje]   
 @StartDate varchar(10),
 @EndDate varchar(10)


as
Begin 
--select  top 1000 * from K_Ypxx order by bidate desc
--select  top 1000 * from hbidata..infoBrzkjl

--住院患者药费总金额
select kscode,bidate,sum(cfje) cfje into #ksje from K_Ypxx
where convert(varchar(10),bidate,120) between @StartDate  and @EndDate  and kstype like '02%'
group by kscode,bidate

--患者在科日数
select ksdm,zkrq,count(*) daynum into #ksdays from  hbidata..infoBrzkjl
where convert(varchar(10),zkrq,120) between @StartDate  and @EndDate 
group by ksdm,zkrq 

--更新科室
  --普外三区一组改为普外三区
update #ksdays 
set ksdm=165
where ksdm=283
  --呼吸科不再使用，改为呼吸重症医学科
update #ksdays 
set ksdm=47
where ksdm=262
  

--患者日均药费 --case when a.daynum=0 then 0 else isnull(b.cfje,0)*1.0/a.daynum end 
select a.ksdm,a.zkrq,isnull(b.cfje,0),a.daynum from #ksdays a left join #ksje b on a.ksdm=b.kscode and a.zkrq=b.bidate







end