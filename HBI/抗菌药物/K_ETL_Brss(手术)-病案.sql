USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[K_ETL_Brss]    Script Date: 03/30/2015 10:45:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER ProceDure [dbo].[K_ETL_Brss]    
 @StartDate varchar(10),  
 @EndDate Varchar(10)  
as   
Begin    
   
--Declare @StartDate varchar(10),@EndDate Varchar(10)  
--Set @StartDate='2013-12-01'  
--Set @EndDate='2013-12-31'  
-------------------------------提取患者手术信息----------------------------------------   
  Delete K_SSxx Where bidate between @StartDate And @EndDate   
  Select DATEPART(yy,a.cyrq) biyear,DATEPART(qq,a.cyrq) biquarter,DATEPART(mm,a.cyrq) bimonth,DATEPART(qq,a.cyrq) biweek,  
         convert(varchar(10),a.cyrq,120) bidate,   
         a.cyks_code ssksdm,--手术科室代码  
         a.cyks_name ssksmc,--手术科室名称  
         null ssysdm,--手术医生代码  
         b.CH0A34,--手术医生名称  
         a.blh,  
         a.zyh zyh,  
         a.zycs zycs,  
         c.CH0E08_MC CH0E08_MC,--手术名称  
         c.CH0E08,--手术编码  
         c.CH0E11 CH0E11,--手术日期  
         c.CH0E12 qkdj,--切口等级   
         c.isjrss isJrss,--是否介入手术  
         c.CH0EZ01 CH0EZ01,--是否二次手术  
         c.CH0E07 CH0E07,--手术次数  
         a.hzxm hzxm,--患者姓名  
         a.hzxb hzxb,--患者性别  
         a.ryrq ryrq,--入院日期  
         a.cyks_name cyks_name,--出院科室名称  
         a.cyzd cyzd,--出院诊断名称  
         b.CH0A41_MC CH0A41_MC,--出院转归  
         convert(varchar(10),a.cyrq,120) cyrq,--出院日期   
         convert(varchar,c.ChYear)+convert(varchar,c.Ch0E01)+convert(varchar,c.Ch0E07) ssbh--手术唯一编号   
    into #TempSS  
    from K_Hzjbxx a  
   inner join HBIData..VsCH0A b on a.zyh=b.CH0A00 And a.zycs=convert(int,right(b.CH0A01,2))  
   inner join HBIData..VsCH0E c on b.ChYear=c.ChYear And b.CH0A01=c.CH0E01  
   Where a.bidate between @StartDate And @EndDate    
   
  Select a.ssbh,   
         0 is_yfssKss_xy24,--I类切口是否预防使用抗菌药物<24小时  
         max(Case When yfzl='预防' And qkdj=1 And datediff(hh,a.CH0E11,yzjssj)>24 Then 1 Else 0 End) is_yfssKss_dy24,--I类切口是否预防使用抗菌药物>24小时  
         max(Case When yfzl='预防' And qkdj=1 And datediff(hh,a.CH0E11,yzjssj)>48 Then 1 Else 0 End) is_yfsykss_dy48,--I类切口是否预防使用抗菌药物>48小时  
         0 is_yfsykss_xy48,--I类切口是否预防使用抗菌药物<48小时  
         max(Case When yszt Like '%术前%' And sqkssmd is not null Then 1 Else 0 End) is_Sqbxs_Sykss,--I类切口是否术前0.5小时预防使用抗菌药物  
         max(Case When sqkssmd is not null then 1 Else 0 End) isSykss,--是否使用抗菌药物  
         max(Case When yfzl='预防' Then 1 Else 0 End) isYfsykss,--是否预防使用抗菌药物  
         max(Case When datediff(hh,a.CH0E11,yzjssj)<0 or yszt Like '%术前%' Then 1 Else 0 End) isSqgy,--是否术前给药   
         0 YfsykssTs--预防用药天数  
    into #TempSSyy   
    from #TempSS a  
   inner join (  
     Select Distinct yzid,ss.blh,a.yzcjsj,a.yzjssj,a.yznr,a.Issqsykss isSqyy,--是否术前用药  
         Case When a.sqkssmd=1 Then '治疗' When a.sqkssmd=2 Then '预防' Else '其他' End yfzl,  
         yszt,--提取术前半小时   
         a.sqkssmd--可判断是否抗菌药物  
    from #TempSS ss                                     --病人基本信息  
      Inner join HBIData.dbo.infoBryz a on ss.blh=a.brid    --医嘱基本信息   
      INNER JOIN HBIData.dbo.WB_YPZD b ON a.zlxmdm=b.YPPZDM  --抗菌药物医嘱
      Where ss.bidate between @StartDate And @EndDate And yzztmc<>'作废' And yzlbmc Like '%药%' AND b.IsKSS=1
      ) b on a.blh=b.blh    
   group by ssbh  
  --手术预防用药天数    
   Select  ss.ssbh, 
           sum(case when  convert(varchar(10),CH0E11,120) between  convert(varchar(10),yzcjsj,120)  and convert(varchar(10),yzjssj,120) then   
                Case When datediff(day,yzcjsj,yzjssj)=0 Then 1 Else  datediff(day,yzcjsj,yzjssj) End else 0 end ) yyts  
   into #TmpYyts             
   from #TempSS ss                                     --病人基本信息  
    Inner join HBIData.dbo.infoBryz a on ss.blh=a.brid    --医嘱基本信息   
    INNER JOIN HBIData.dbo.WB_YPZD b ON a.zlxmdm=b.YPPZDM  
    Where ss.bidate between @StartDate And @EndDate And yzztmc<>'作废' And a.sqkssmd=2 AND b.IsKSS=1 
    group by ss.ssbh

     
    
    Update #TempSSyy Set YfsykssTs=yyts from #TmpYyts Where #TempSSyy.ssbh=#TmpYyts.ssbh  
   
  Insert into K_SSxx(biyear,biquarter,bimonth,biweek,bidate,kscode,ksname,ssys_code,ssys_name,blh,zyh,zycs,ss_Name,  
                     ss_ICCM,sssj,qkdj,isjrss,isEcss,sscs,hzxm,hzxb,ryrq,cyks,cyzd,cyzg,cyrq,ssbh,  
                     is_yfssKss_xy24,is_yfssKss_dy24,  
                     is_yfsykss_dy48,is_yfsykss_xy48,is_Sqbxs_Sykss,isSykss,isYfsykss,isSqgy,YfsykssTs)  
  Select a.*,b.is_yfssKss_xy24,b.is_yfssKss_dy24,b.is_yfsykss_dy48,b.is_yfsykss_xy48,b.is_Sqbxs_Sykss,b.isSykss,  
         b.isYfsykss,b.isSqgy,b.YfsykssTs  
    from #TempSS a  
   left join #TempSSyy b on a.ssbh=b.ssbh   
    
--更新手术医生代码  
  Update K_SSxx Set ssys_code=userid from HBIData..WB_Doctor b where K_SSxx.ssys_name=b.TName   
    
--更新同一个病人是否存在大于1的切口等级  
  Update K_SSxx Set IsQkdjdy1=1 Where blh in(select blh from K_SSxx Where qkdj>1)  
--更新小于一类切口预防用药是否小于24小时和小于48小时  
  Update K_SSxx Set is_yfssKss_xy24=1 Where is_yfssKss_dy24!=1 And qkdj=1 And isSykss=1  
  Update K_SSxx Set is_yfsykss_xy48=1 Where is_yfsykss_dy48!=1 And qkdj=1 And isSykss=1  
       
--更新查询条件   
  Update K_SSxx Set Serchtj=''   
  Update K_SSxx Set Serchtj='A1' Where is_yfssKss_dy24=1 And qkdj=1 --I类切口术后预防使用抗生素大于24小时  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A2' Where is_yfsykss_dy48=1 And qkdj=1 --I类切口术后预防使用抗生素大于48小时  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A3' Where is_Sqbxs_Sykss=1 --是否术前0.5小时预防使用抗菌药物  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A4' Where is_Sqbxs_Sykss=0 And qkdj=1 --Ⅰ类手术切口预防使用抗菌药物时间未在术前0.5-2小时病例  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A5' Where isJrss=1 --介入手术  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A6' Where isJrss=1 And isYfsykss=1 --介入手术抗菌药物预防使用病例  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A7' Where qkdj=1 --Ⅰ类切口  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A8' Where qkdj=1 And isYfsykss=0--Ⅰ类切口非预防使用抗菌药物患者  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A9' Where qkdj=1 And isYfsykss=1--Ⅰ类切口预防使用抗菌药物患者  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'B1' Where qkdj=1 And isSykss=1--Ⅰ类切口使用抗菌药物病人  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'B2' Where isEcss=1--二次手术病人   
    
End  