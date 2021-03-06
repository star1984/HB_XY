USE [HBI_gr]
GO
/****** Object:  StoredProcedure [dbo].[K_ETL_yfcf]    Script Date: 02/27/2015 16:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[K_ETL_yfcf] @startTime varchar(10),@endTime varchar(10)  
AS  
Begin  
  Select bidate as bidate,  
         yfCode as TD00,yfName as TD01,--药房代码、名称,
         kstype,--科室分类 ('011'普通门诊，'013'普通急诊，'022'普通住院，'023' 急诊住院)
         kscode,--科室代码 
         Count(distinct Case when kstype like '01%' then CFID else null End) as TD02,--门诊处方数  
         Sum(Case when kstype like '01%'  then cfje else 0 End) as TD03,--门诊药物金额  
         Count(distinct Case when kstype like '02%'  then CFID else null End) as TD04,--住院处方数  
         Sum(Case when kstype like '02%'  then cfje else 0 End) as TD05,--住院药物金额  
         Sum(Case when isXy=1 then cfje else 0 End) xyje, --西药销售金额  
         Sum(Case when kstype like '01%'  And isXy=1 then cfje else 0 End) MZxyje, --门诊药房西药销售金额  
         Sum(Case when kstype like '02%' And isXy=1 then cfje else 0 End) Zyxyje, --住院药房西药销售金额  
         Sum(Case when iskss=1 then cfje else 0 End) KSSje, --抗菌药物销售金额  
         Sum(Case when kstype like '01%' And iskss=1 then cfje else 0 End) MZkssje, --门诊抗菌药物销售金额  
         Sum(Case when kstype like '02%' And iskss=1 then cfje else 0 End) ZyKssje,  --住院抗菌药物销售金额   
         Count(distinct Case when kstype like '01%' And iskss=1 then CFID else null End) MzKssCfs,  --门诊抗菌药物处方数据  
         Count(distinct Case when ksType='013' then CFID else null End) Jzcfzs,  --急诊门诊处方总数   
         Count(distinct Case when ksType='013' And iskss=1 then CFID else null End) JzKsscfs,--急诊门诊抗菌药物处方数  
         sflbdm,sflbmc,
         Sum(Case when ksType='011'   then cfje else 0 End) as p_mzypje,--普通门诊药物金额
         Sum(Case when ksType='013'   then cfje else 0 End) as j_mzypje,--急诊门诊药物金额
         Sum(Case when ksType='022'   then cfje else 0 End) as p_zyypje,--普通住院药物金额
         Sum(Case when ksType='023'   then cfje else 0 End) as j_zyypje,--急诊住院药物金额
         SUM(cfje) AS cfje--药物金额         
    Into #temp_cf   
    from K_Ypxx   
   where convert(varchar(10),bidate,120) between @startTime and @endTime  
   Group by bidate,yfCode,yfName,kstype,kscode,sflbdm,sflbmc  
   
  Delete from k_yfcf where convert(varchar(10),bidate,120) between @startTime and @endTime  
    
  Insert into K_yfcf(biyear,biquarter,bimonth,biweek,bidate,TD00,TD01,kstype,kscode,TD02,TD03,TD04,TD05,xyje,MZxyje,Zyxyje,KSSje,MZkssje,ZyKssje,  
                     MzKssCfs,Jzcfzs,JzKsscfs,sflbdm,sflbmc,p_mzypje ,j_mzypje ,p_zyypje,j_zyypje,cfje)       
  Select datepart(Year,bidate) as biyear, datepart(Quarter,bidate) as biquarter,  
         datepart(Month,bidate) as bimonth,datepart(Week,bidate) as biweek,  
         bidate,TD00,TD01,kstype,kscode,TD02,TD03,TD04,TD05,xyje,MZxyje,Zyxyje,KSSje,MZkssje,ZyKssje,  
         MzKssCfs,Jzcfzs,JzKsscfs,sflbdm,sflbmc,p_mzypje ,j_mzypje ,p_zyypje,j_zyypje,cfje
    from #temp_cf  
End  
   
  
  
/*  
 Exec K_ETL_yfcf '2014-11-01','2015-04-13'  
 select * from K_yfcf order by bidate  
 select top 100 * from K_Ypxx  
*/  
   
  
--Select Sum(cfje) from K_Ypxx Where bidate between '2014-01-01' And '2014-01-31' And isxy=1  
--truncate table  K_yfcf
--Select * from K_yfcf Where bidate between '2014-01-01' And '2014-01-31'  
--Select Sum(xyje) from K_yfcf Where bidate between '2014-01-01' And '2014-01-31'  
--Select Sum(xyje) from K_yfcf Where bidate between '2014-01-01' And '2014-01-31' And TD01='门诊西药房' or TD01='' 
-- exec [K_ETL_yfcf] '2015-03-01','2015-04-27'
   
  