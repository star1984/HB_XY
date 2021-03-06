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
--select * from K_SSxx
-------------------------------提取患者手术信息---------------------------------------- 
  
  Delete K_SSxx Where convert(varchar(10),bidate,120) between @StartDate And @EndDate   
  Select DATEPART(yy,b.cysj) biyear,DATEPART(qq,b.cysj) biquarter,DATEPART(mm,b.cysj) bimonth,DATEPART(qq,b.cysj) biweek,  
         convert(varchar(10),b.cysj,120) bidate,   
         a.ksdm ssksdm,--手术科室代码  
         a.ksmc ssksmc,--手术科室名称  
         null ssysdm,--手术医生代码  
         replace(replace(replace(a.ssysxm,char(10),''),char(13),''),' ','') ssysname,--手术医生名称  
         a.brid blh,  
         a.zyh zyh,  
         a.zycs zycs,  
         a.ssmc,--手术名称  
         a.ssid,--手术编码
         a.kssj sskssj,--手术开始时间
         a.jssj ssjssj,--手术结束时间
         datediff(n,a.kssj,a.jssj) sssj,--手术持续时间  
         isnull(a.qkdj,0) qkdj,--切口等级     
         b.IsHQMSV07 isEcss,--是否重返手术室二次手术  
         cast(0 as int) sscs,--手术次数  
         b.hzxm hzxm,--患者姓名  
         case when b.hzxb='1' then '男'
              when b.hzxb='2' then '女' else  null end  hzxb,--患者性别  
         cast(b.hznl as varchar(10))+nldw hznl,--患者年龄
         convert(varchar(10),b.rysj,120) ryrq,--入院日期  
          b.cyksmc  cyks_name,--出院科室名称 
          c.CH0A38_MC cyzd,--出院诊断名称  
          c.CH0A41_MC CH0A41_MC,--出院转归 
          convert(varchar(10),b.cysj,120) cyrq,--出院日期   
         a.ssid ssbh--手术唯一编号 
           
    into #TempSS  
    from hbidata..infoBRSMJL a inner join hbidata..infoRYDJB b on a.brid=b.gid 
                               left join HBIData..VsCH0A c on a.zyh=c.CH0A00 And a.zycs=convert(int,right(c.CH0A01,2))  
                    
   Where convert(varchar(10),b.cysj,120) between @StartDate And @EndDate and b.cysj is not null  and a.ssmc is not null
   
--由于临汾人民医院多次修改his里的科室名称，而麦迪斯顿中与his的对应科室表没有更新，因此用dlgr.his_zkxx_js更新科室select * from hbidata..infoRYDJB 
update #TempSS 
set ssksdm=a.szks,ssksmc=b.deptname
from dlgr..his_zkxx_js a,hbidata..wb_dept b
where #TempSS.blh=a.blh and #TempSS.sskssj between a.rksj and a.cksj and a.szks=b.deptid

--临汾人民医院，由于中联抗生素医嘱中存在用药目的为空的记录，因此将用药目的为空的默认为预防

  --更新在科信息里没有病人信息，而又作了手术的病人
update #TempSS 
set ssksdm=a.deptid
from hbidata..wb_dept  a
where a.deptname like '%'+#TempSS.ssksmc+'%' and #TempSS.ssksdm is null
 

  Select a.blh,   
         max(Case When b.yz_yzlx='长期' and b.yfzl='预防' And a.qkdj=1 and datediff(ss,isnull(a.ssjssj,getdate()),b.yzkssj)>0 And datediff(n,b.yzkssj,isnull(b.yzjssj,getdate()))<24*60 Then 1 Else 0 End) is_yfssKss_xy24,--I类切口是否预防使用抗菌药物<24小时  
         max(Case When b.yz_yzlx='长期' and b.yfzl='预防' And a.qkdj=1 and datediff(ss,isnull(a.ssjssj,getdate()),b.yzkssj)>0 And datediff(n,b.yzkssj,isnull(b.yzjssj,getdate()))>24*60 Then 1 Else 0 End) is_yfssKss_dy24,--I类切口是否预防使用抗菌药物>24小时  
         max(Case When b.yz_yzlx='长期' and b.yfzl='预防' And a.qkdj=2 and datediff(ss,isnull(a.ssjssj,getdate()),b.yzkssj)>0 And datediff(n,b.yzkssj,isnull(b.yzjssj,getdate()))>48*60 Then 1 Else 0 End) is_yfsykss_dy48,--II类切口是否预防使用抗菌药物>48小时  
         max(Case When b.yz_yzlx='长期' and b.yfzl='预防' And a.qkdj=2 and datediff(ss,isnull(a.ssjssj,getdate()),b.yzkssj)>0 And datediff(n,b.yzkssj,isnull(b.yzjssj,getdate()))<48*60 Then 1 Else 0 End) is_yfsykss_xy48,--II类切口是否预防使用抗菌药物<48小时  
         max(Case When b.yz_yzlx='临时' and b.yfzl='预防' and datediff(n,b.yzzxsj,a.sskssj)>30 and datediff(n,b.yzzxsj,a.sskssj)<=120  Then 1 Else 0 End) is_Sqbxs_Sykss,--是否术前0.5-2小时预防使用抗菌药物 
         max(Case When b.yz_yzlx='临时' and b.yfzl='预防' and  b.yzzxsj>=a.sskssj and b.yzzxsj<=a.ssjssj Then 1 Else 0 End) is_Szyf_Sykss,--是否术中预防使用抗菌药物 
         max(Case When b.yz_yzlx='临时' and b.yfzl='预防' and  (b.yzzxsj>=a.ssjssj and datediff(dd,b.yzzxsj,a.ssjssj)<=1) Then 1 Else 0 End) is_Shyf_Sykss,--是否术后预防使用抗菌药物
         max(Case When b.yz_yzlx='临时' and b.yfzl='预防' and b.kssxzlb=1 and datediff(n,b.yzzxsj,a.sskssj)>30 and datediff(n,b.yzzxsj,a.sskssj)<=120  Then 1 Else 0 End) is_sqfxzyf_sykss,--是否术前0.5-2小时预防非限制使用抗菌药物
         max(Case When b.yfzl='预防' and b.kssxzlb=1 and b.yzzxsj>=a.sskssj and b.yzzxsj<=a.ssjssj  Then 1 Else 0 End) is_szfxzyf_sykss,--是否术中预防非限制使用抗菌药物
         max(Case When b.yfzl='预防' and b.kssxzlb=1 and (b.yzzxsj>=a.ssjssj and datediff(dd,b.yzzxsj,a.ssjssj)<=1)  Then 1 Else 0 End) is_shfxzyf_sykss,--是否术后预防非限制使用抗菌药物
         max(Case When b.iskss=1 then 1 Else 0 End) isSykss,--是否使用抗菌药物  
         max(Case When b.yfzl='预防' Then 1 Else 0 End) isYfsykss,--是否预防使用抗菌药物  
         max(Case When datediff(n,b.yzzxsj,a.sskssj)<=6*60  and  datediff(ss,b.yzzxsj,a.sskssj)>0 and b.iskss=1 Then 1 Else 0 End) isSqgy,--是否术前抗生素给药   
         cast(0 as int) YfsykssTs--预防用药天数  
    into #TempSSyy   
    from #TempSS a  inner join (  
                                  Select Distinct a.yzid,ss.blh,a.yzkssj,a.yzjssj,c.yzzxsj,a.yz_yznr,a.yz_yzlx,
                                         Case When a.sqkssmd=1 Then '治疗' When a.sqkssmd=2 Then '预防' Else '其他' End yfzl,  
                                          a.yszt,--提取术前半小时 
                                          a.iskss ,a.kssxzlb
                                   from #TempSS ss                                      
                                         left join (
                                                     select case when CHARINDEX('_', bb.yz_yzbh) >0 then left(bb.yz_yzbh,CHARINDEX('_', bb.yz_yzbh)-1) else yz_yzbh end as yzid,
                                                            bb.blh,bb.yz_yzzt,bb.yz_yongfa,bb.yz_kssj yzkssj,bb.yz_jssj yzjssj,bb.yz_yznr,bb.yz_commonyp yszt,bb.ypcode,bb.iskss,bb.yz_yymd sqkssmd,bb.yz_yzlx
                                                            ,cc.kssxzlb   --1.非限制级  2.限制级 3.特殊级
                                                              from dlgr..his_yz bb inner join hbidata..wb_ypzd cc on bb.ypcode=cc.ypid
                                                     where  bb.iskss=1 and  bb.yz_yzzt<>'作废'  and  bb.yz_yongfa not like '%皮试%' 
                                                    ) a on ss.blh=a.blh  --医嘱基本信息
		                                  left join HBIData.dbo.infoYZZX c on a.yzid=c.yzid    --医嘱执行信息
                               ) b on a.blh=b.blh  
   group by a.blh 
   -- select * from #TempSS where blh='172859_1'
   --select * from #TempSSyy where blh='172859_1'

  --手术预防用药天数   
   Select blh,Sum(yyts) yyts into #TmpYyts 
   from(  
	   Select Distinct ss.blh,a.yz_kssj,a.yz_jssj,  
			  Case When datediff(dd,a.yz_kssj,isnull(a.yz_jssj,getdate()))=0 Then 1 Else  datediff(dd,a.yz_kssj,isnull(a.yz_jssj,getdate())) End yyts  
	   from #TempSS ss                                 --病人手术基本信息  
		              inner join dlgr..his_yz a on ss.blh=a.blh    --医嘱基本信息   
       Where ss.bidate between @StartDate And @EndDate And a.yz_yzzt<>'作废' and  a.yz_yongfa not like '%皮试%' And a.yz_yymd=2 AND a.IsKSS=1 
    ) b  
   Group by blh  
     
    
    --Update #TempSSyy Set YfsykssTs=yyts from #TmpYyts Where #TempSSyy.ssbh=#TmpYyts.blh
   
  Insert into K_SSxx(biyear,biquarter,bimonth,biweek,bidate,kscode,ksname,ssys_code,ssys_name,blh,zyh,zycs,ss_Name,  
                     ss_ICCM,sskssj,ssjssj,sssj,qkdj,isEcss,sscs,hzxm,hzxb,hznl,ryrq,cyks,cyzd,cyzg,cyrq,ssbh,  
                     is_yfssKss_xy24,is_yfssKss_dy24,  
                     is_yfsykss_dy48,is_yfsykss_xy48,is_Sqbxs_Sykss,isSykss,isYfsykss,isSqgy,YfsykssTs,is_sqfxzyf_sykss,is_szfxzyf_sykss,is_shfxzyf_sykss,is_Szyf_Sykss,is_Shyf_Sykss)  
  Select a.*,b.is_yfssKss_xy24,b.is_yfssKss_dy24,b.is_yfsykss_dy48,b.is_yfsykss_xy48,b.is_Sqbxs_Sykss,b.isSykss,  
         b.isYfsykss,b.isSqgy,isnull(c.yyts,0) YfsykssTs,b.is_sqfxzyf_sykss,b.is_szfxzyf_sykss,b.is_shfxzyf_sykss,b.is_Szyf_Sykss,b.is_Shyf_Sykss 
    from #TempSS a  
   left join #TempSSyy b on a.blh=b.blh
   left join #TmpYyts c on a.blh=c.blh   
    
--更新手术医生代码  
   --根据医生姓名及医生所在科室更新医生代码
   Update K_SSxx 
   Set ssys_code=(select top 1 b.userid from HBIData..WB_Doctor b ,HBIData..WB_dept c
                  where  K_SSxx.ssys_name=replace(replace(replace(b.TName,char(10),''),char(13),''),' ','') AND b.DeptID=c.DeptID
                         AND  K_SSxx.ksname LIKE '%'+LEFT(c.DeptName,1)+'%' and K_SSxx.ssys_code is null)  
   where K_SSxx.ssys_code is NULL AND CONVERT(VARCHAR(10),bidate,120) BETWEEN @StartDate And @EndDate
  --根据医生姓名更新医生代码 
   Update K_SSxx 
   Set ssys_code=(select top 1 b.userid from HBIData..WB_Doctor b 
                  where  K_SSxx.ssys_name=replace(replace(replace(b.TName,char(10),''),char(13),''),' ','') and K_SSxx.ssys_code is null)  
   where K_SSxx.ssys_code is NULL AND CONVERT(VARCHAR(10),bidate,120) BETWEEN @StartDate And @EndDate
    
--更新同一个病人是否存在大于1的切口等级  
  Update K_SSxx Set IsQkdjdy1=1 Where blh in(select blh from K_SSxx Where qkdj>1)  
----更新一类切口预防用药是否小于24小时
--  Update K_SSxx Set is_yfssKss_xy24=1 Where is_yfssKss_dy24!=1 And qkdj=1 And isSykss=1 
----更新二类切口预防用药是否小于48小时   
--  Update K_SSxx Set is_yfsykss_xy48=1 Where is_yfsykss_dy48!=1 And qkdj=2 And isSykss=1  
       
--更新查询条件   
  Update K_SSxx Set Serchtj=''   
  Update K_SSxx Set Serchtj='A1' Where is_yfssKss_dy24=1 And qkdj=1 --I类切口术后预防使用抗生素大于24小时  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A2' Where is_yfsykss_dy48=1 And qkdj=2 --II类切口术后预防使用抗生素大于48小时  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A3' Where is_Sqbxs_Sykss=0 --未在术前0.5小时预防使用抗菌药物  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A4' Where is_Sqbxs_Sykss=0 And qkdj=1 --Ⅰ类手术切口预防使用抗菌药物时间未在术前0.5-2小时病例  
  --Update K_SSxx Set Serchtj=Serchtj+'|'+'A5' Where isJrss=1 --介入手术  
  --Update K_SSxx Set Serchtj=Serchtj+'|'+'A6' Where isJrss=1 And isYfsykss=1 --介入手术抗菌药物预防使用病例  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A7' Where qkdj=1 --Ⅰ类切口  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A8' Where qkdj=1 And isYfsykss=0--Ⅰ类切口非预防使用抗菌药物患者  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'A9' Where qkdj=1 And isYfsykss=1--Ⅰ类切口预防使用抗菌药物患者  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'B1' Where qkdj=1 And isSykss=1--Ⅰ类切口使用抗菌药物病人  
  Update K_SSxx Set Serchtj=Serchtj+'|'+'B2' Where isEcss=1--二次手术病人   

End  