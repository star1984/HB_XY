USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[K_ETL_brjbxx]    Script Date: 04/08/2015 17:01:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER ProceDure [dbo].[K_ETL_brjbxx]      
 @StartDate varchar(10),   
 @EndDate Varchar(10)   
as   
Begin   
      
  -- Declare @StartDate varchar(10),@EndDate Varchar(10)   
  --Set @StartDate='2014-01-01'   
  --Set @EndDate='2014-02-28'  
   
  Delete K_Hzjbxx Where  convert(Varchar(10),bidate,120) between @StartDate And @EndDate    
   
 --住院数据   
  Select distinct DATEPART(yy,CH0A27) biyear,DATEPART(qq,CH0A27) biquarter,DATEPART(mm,CH0A27) bimonth,DATEPART(ww,CH0A27) biweek,convert(varchar(10),CH0A27,120) bidate,   
         b.Gid blh,   
         a.CH0A00 zyh,   
         convert(int,right(a.CH0A01,2)) zycs,   
         a.CH0A02,--姓名   
         a.CH0A03_MC,--性别   
         a.CH0A06,--年龄   
         cast(a.Ch0AA1 as varchar(20)) Ch0AA1,--年龄单位   
         a.CH0A24,--入院日期   
         a.CH0A27,--出院日期   
         b.cyksdm,--出院科室   
         b.cyksmc,--出院科室名称   
         b.zgysdm,--主管医生   
         b.zgysxm,--主管医生姓名   
         a.CH0A38_MC,--出院诊断名称   
         a.CH0A38,--诊断代码   
         a.Ch0AN3,--入院体重   
         cast(0 as decimal(20,4)) ylzfy,--医疗总费用   
         0 isByxSj,--是否病原学送检   
         Case when b.cyksmc Like '%急诊%' Then '023' Else '022' End   kstype, --('011'普通门诊，'013'普通急诊，'022'普通住院，'023' 急诊住院)   
         CASE WHEN datediff(day,CH0A24,CH0A27)=0 THEN 1 ELSE datediff(day,CH0A24,CH0A27) end zyts,--患者住院天数   
         b.Gid MZID,   --blh ，如100021_1
         Case When isnull(c.CH0EZ01,0)=0 Then 0 Else 1 End isEcss,--是否二次手术   
         cast(0 as decimal(20,4))  ypzfy--药品总费用   
    into #Tempbrjbxx    
    from HBIData..VsCH0A a   
   inner join HBIData..infoRYDJB b on a.CH0A00=b.zyh And b.zycs=convert(int,right(a.CH0A01,2))    
    left join HBIData..VsCH0E c on a.ChYear=c.ChYear And a.CH0A01=c.CH0E01   
   Where convert(varchar(10),CH0A27,120) between @StartDate And @EndDate    and b.cyksdm is not null 
   union  
 --门急诊数据   
  Select DATEPART(yy,ghsj) biyear,DATEPART(qq,ghsj) biquarter,DATEPART(mm,ghsj) bimonth,DATEPART(ww,ghsj) biweek,   
         convert(varchar(10),ghsj,120) bidate,   
         a.brid+'_'+cast(a.gid as varchar) blh,    --取得是挂号表的gid，如100001
         a.brid+'_'+cast(a.gid as varchar) zyh,    
         0 zycs,   
         hzxm,    
         Case When hzxb=1 Then '男' else '女' End,--性别   
         Hznl,--年龄   
         Nldw,--年龄单位   
         convert(varchar(10),ghsj,120),--挂号时间（入院时间）   
         convert(varchar(10),ghsj,120),--挂号时间（出院时间）   
         ghksdm,--科室代码   
         ghksmc,--科室名称   
         ghysdm,--医生代码   
         ghysxm,--医生姓名   
         null,--出院诊断名称   
         null,--诊断代码   
         null,--入院体重   
         cast(0 as decimal(20,4)) ,--医疗总费用   
         null,--是否病原学送检   
         Case when ghksmc Like '%急诊%' Then '013' Else '011' End kstype,   --('011'普通门诊，'013'普通急诊，'022'普通住院，'023' 急诊住院)
         CAST(1 AS SMALLINT)  zyts,   
         Gid MZID,      --取得是挂号表的gid，如100001
         null isEcss,   
         cast(0 as decimal(20,4))  ypzfy--药品总费用   
    From HBIData..infoMZGH a    
   Where convert(varchar(10),ghsj,120) between @StartDate And @EndDate And isnull(brid,'')!=''   and (a.zxzt=1 or a.zxzt=2)
         
  --更新住院病人病案中的年龄单位
  update  #Tempbrjbxx 
  set Ch0AA1=replace(replace(replace(ch0AA1,'Y','岁'),'M','月'),'D','天')
  where kstype like '02%'
  
 
 
 --更新是否病原学送检   
   Select b.Brid,Max(Case When jylbmc='微生物' Then 1 Else 0 End) issj   
     into #TempByxsj   
     from #Tempbrjbxx a   
    inner join HBIData..infoJyjbxx b on a.blh=b.Brid   
    group by b.Brid    
    
   Update #Tempbrjbxx Set isByxSj=issj from #TempByxsj a Where #Tempbrjbxx.blh=a.Brid  
   

 
 
        
       
 --更新门诊医疗总费用，药品总费用   
   Select a.blh,Sum(isnull(je,0)) allje,Sum(Case When ypid is not null Then je Else 0 End) ypje into #TempFy from #Tempbrjbxx a   
    inner join HBIData..infoMZSF b on a.blh=(cast(isnull(b.BRID,'') as varchar)+'_'+cast(isnull(b.mzid,'') as varchar))   
     left join HBIData..WB_YPZD c on b.sfxmdm=c.YPID    
    group by blh   
    union  
 --更新住院医疗总费用，药品总费用   
   Select a.blh,Sum(isnull(je,0)) allje,Sum(Case When ypid is not null Then je Else 0 End) ypje from #Tempbrjbxx a   
    inner join HBIData..infoZYSF b on a.blh=b.BRID   
     left join HBIData..WB_YPZD c on b.sfxmdm=c.YPID    
    group by blh    
        
   Update #Tempbrjbxx set ylzfy=allje,YpZfy=ypje from #TempFy a Where #Tempbrjbxx.blh=a.blh   
   

       
  --更新住院患者用药数据   
   Select br.blh,a.yzcjsj,a.yzjssj,a.yznr,a.sqkssmd yfzl,YPDLMc,YPFLMC,YpID,d.iskss,YPPZMC,a.yzid,   
          d.KSSXZLB kssdj,--1非限制类/2限制类抗菌药物/3特殊类抗菌药物    
          d.IsJBYW,--是否基本药物   
          d.JXMC,--剂型名称   
          ROW_NUMBER() OVER(PARTITION BY br.blh ORDER BY a.yzcjsj) num,   
          case when d.IsJBYW=1 and d.iskss=1 then 1 else 0 end isjbkss,
          a.gyfsmc
     into #Tempyymx   
     from #Tempbrjbxx br                                  --病人基本信息   
    Inner join HBIData.dbo.infoBryz a on br.blh=a.brid    --医嘱基本信息   
    Inner Join hbidata..infoYZZX b on a.YZID=b.YZID       --医嘱执行表   
     Left Join hbidata..infoZYSF c on  b.ZXID=c.yzzxid     --医嘱收费表   
    Inner Join hbidata..WB_YPZD d on c.sfxmdm=d.YPID      --药品字典表   
    Where br.bidate between @StartDate And @EndDate And yzztmc<>'作废' And charindex('皮试',yznr)=0  and br.kstype like '02%'
    
      
 --更新患者用药数据  
          --max(Case When num=1 then yznr Else null End) yznr,--医嘱内容   
          --max(Case When num=1 then yzcjsj Else null End) yzcjsj,--医嘱开始时间 
          --max(Case When num=1 then YPDLMc Else null End) YPDLMc,--医嘱分类（大类） 
          --max(Case When kssdj=1 then '非限制类抗菌素' When kssdj=2 then '限制类抗菌素' when kssdj=3 then '特殊类抗菌素' Else null End) YPFLMC,--医嘱分类（小类） 
   Select blh,  
          max(Case When yfzl=1 Then 1 Else 0 End) isZlyy,--治疗用药   
          max(Case When yfzl=2  then 1 Else 0 End) isYfyy,--预防用药 
          convert(varchar(200),null) yznr,--医嘱内容  
          min(yzcjsj) yzcjsj,--医嘱开始时间 
          convert(varchar(200),null) YPDLMc,--医嘱分类（大类）   
          convert(varchar(200),null) YPFLMC,--医嘱分类（小类）    
          max(Case When kssdj=3 Then 1 Else 0 End) isSyTskss,--是否使用特殊抗菌药物   
          max(Case When kssdj=2 Then 1 Else 0 End) isSyXzkss,--限制类抗菌药物    
          max(Case When kssdj=3  And JXMC Like '%注射%' Then 1 Else 0 End) isTsKssZj, --是否特殊抗菌药物使用针剂   
          count(distinct YPPZMC) KssYypzs, --用药品种数   
          max(Case When kssdj=3 And yfzl=1 Then 1 Else 0 End) isZlSyTsKss, --是否治疗使用特殊抗菌药物   
          max(Case When kssdj=2 And yfzl=1 Then 1 Else 0 End) isZlSyxzkss --是否治疗使用限制抗菌药物      
     into #Tempyy   
     from #Tempyymx    
    Where iskss=1    
    group by blh 
    
    --根据患者最早使用抗生素时间(yzcjsj)，更新最早使用抗生素名称(yznr)、最早使用抗生素品种(YPDLMc)、最早使用抗生素级别(YPFLMC)
    update #Tempyy 
    set yznr=a.yznr,YPDLMc=a.ypdlmc,
        YPFLMC=Case When kssdj=1 then '非限制类抗菌素' When kssdj=2 then '限制类抗菌素' when kssdj=3 then '特殊类抗菌素' Else null End
    from #Tempyymx a
    where #Tempyy.blh=a.blh and a.yzcjsj=#Tempyy.yzcjsj and a.iskss=1
    

 Select blh,   
        max(Case When iskss=1 Then 1 Else 0 End) isSykss,--是否使用抗菌药物   
        Count(distinct Case When IsJBYW=1 Then YPPZMC Else null End) jbywpzs, --病人基本药物品种数   
        max(Case When IsJBYW=1 Then 1 Else 0 End) Issyjbyw, --是否使用基本药物   
        count(distinct YPPZMC) yypzs, --用药品种数   
        max(Case When JXMC Like '%注射%' Then 1 Else 0 End) isSyzsj,--是否使用注射剂   
        max(Case When JXMC Like '%注射%' And iskss=1 Then 1 Else 0 End) isKsssyzj,--抗菌药物使用针剂人次  
        max(Case When isjbkss=1  Then 1 Else 0 End) isjbkss,--是否使用基本抗菌药物 
        max(case when gyfsmc like '%静脉%' and gyfsmc not like '%推注%' and gyfsmc not like '%注射%' then 1 else 0 end) isjmsy,--是否静脉脉输液
        max(case when gyfsmc like '%静脉%' and gyfsmc not like '%推注%' and gyfsmc not like '%注射%' and iskss=1 then 1 else 0 end) isjmsykss--是否静脉脉输液抗菌药品
   into #Tempyp   
   from #Tempyymx   
  group by blh    
       
 
   
  Insert into K_Hzjbxx(biyear,biquarter,bimonth,biweek,bidate,blh,zyh,zycs,hzxm,   
         hzxb,hznl,nldw,ryrq,cyrq,cyks_Code,cyks_name,zgys_Code,zgys_Name,   
         cyzd,cyzd_Code,tz,ylzfy,isByxSj,kstype,zyts,MZID,isEcss,ypzfy,isZlyy,isYfyy,   
         scSyKssSj,ScSyKssPz,ScSyKssMc,ScSyKssLb,HzYyPzs,isSykss,isSyTskss,isSyXzkss,iszlsykss,   
         jbywpzs,Issyjbyw,yypzs,isSyzsj,isKsssyzj,isTsKssZj,isZlSyTsKss,isZlSyxzkss,isjbkss,isjmsy,isjmsykss)   
  Select a.*,b.isZlyy,b.isYfyy,b.yzcjsj,b.YPDLMc,b.yznr,b.YPFLMC,b.KssYypzs,   
         c.isSykss,b.isSyTskss,b.isSyXzkss,iszlsykss,c.jbywpzs,c.Issyjbyw,c.yypzs,c.isSyzsj,   
         c.isKsssyzj,b.isTsKssZj,b.isZlSyTsKss,b.isZlSyxzkss,c.isjbkss,isjmsy,isjmsykss   
    from #Tempbrjbxx a   
    left join #Tempyy b on a.blh=b.blh    
    left join #Tempyp c on a.blh=c.blh   
    
       --select * from   K_Hzjbxx where blh='65046_2'
    
--更新门诊病人用药品种数等数据
   select a.blh,count(distinct Case When b.iskss=1 Then yppzdm Else null End) kssyypzs,
                count(distinct b.yppzdm) yypzs, 
                count(distinct Case When b.isjbyw=1 Then b.yppzdm Else null End) jbyypzs,
                max(case when b.iskss=1 then 1 else 0 end ) isSykss, 
                max(case when b.iszj=1 then 1 else 0 end ) isSyzsj,
                max(case when b.yongfa like '%静脉%' and b.yongfa not like '%推注%' and b.yongfa not like '%注射%' then 1 else 0 end) isjmsy  
           into #mzpzs_tj from #Tempbrjbxx a,K_Ypxx b 
   where a.blh=b.blh and a.kstype like '01%' 
   group by a.blh 
   
   update K_Hzjbxx 
   set yypzs=a.yypzs,jbywpzs=a.jbyypzs,HzYyPzs=a.kssyypzs,issykss=a.issykss,issyzsj=a.isSyzsj,isjmsy=a.isjmsy
   from #mzpzs_tj a
   where K_Hzjbxx.blh=a.blh  
   
--更新住院患者静脉脉输液使用量(袋或瓶)
Select blh,SUM(xssl) jmsysl into #zyjmsyxx from K_Ypxx 
   Where blh in(Select blh from #Tempbrjbxx where kstype like '02%') 
         AND jx='注射液'
         AND (yongfa Like '%静脉%' and yongfa not like '%推注%' and yongfa not like '%注射%' )
 group by blh 
 
 update K_Hzjbxx 
 set jmsysl=#zyjmsyxx.jmsysl
 from #zyjmsyxx 
 where K_Hzjbxx.blh=#zyjmsyxx .blh


   
   
--更新患者抗菌药物使用强度   
--Drop table #Tempypxx,#Temp2,#TempDDDs   
  Select * into #Tempypxx from K_Ypxx 
   Where blh in(Select blh from #Tempbrjbxx) 
         AND 
         (yongfa Like '%静脉%' or yongfa Like '%口服%' or 
          yongfa Like '%肌内注射%' or yongfa Like '%术中用%' or yongfa Like '%微量泵%') and iskss=1

   
         --(yongfa not Like '%皮试%' or yongfa not Like '%雾化%' or yongfa not Like '%皮试%' or 
         -- yongfa not Like '%点眼%' or yongfa not Like '%外用%' or yongfa not Like '%鞘内注射%' or
         -- yongfa not Like '%胸腔内注射%')  
   
  Select sum(isnull(Xssl,0)*DDDValue) DDDs,   
         blh,ypid   
    into #Temp2   
    from #Tempypxx 
   group by ypid,blh   
             
  Select blh,max(Case When b.iskss=1 Then 1 Else 0 End) iskss, --是否使用抗生素    
         Sum(Case When b.KSSXZLB=1 Then DDDs Else 0 End) FTsDDDs, --非限制抗菌药物消耗量   
         Sum(Case When b.KSSXZLB=3 Then DDDs Else 0 End) TsDDDs, --特殊抗菌药物消耗量   
         Sum(Case When b.KSSXZLB=2 Then DDDs Else 0 End) XzDDDs,  --限制抗菌药物消耗量   
         Sum(Case When b.iskss=1 Then DDDs Else 0 End)DDDs,--抗菌药物消耗量   
         count(distinct b.yppzmc) KssYypzs                  --将 count(distinct a.ypid)KssYypzs   改为count(distinct b.yppzmc)KssYypzs
    into #TempDDDs   
    from #Temp2 a   
   inner join HBIData..WB_YPZD b on a.ypid=b.YPID   
   group by blh    
             
  --更新每位患者抗菌药物消耗量     
    Update K_Hzjbxx Set kssDDDs=DDDs,TsKssDDDs=TsDDDs,XzKssDDDs=XzDDDs,FXzKssDDDs=FTsDDDs 
      from #TempDDDs Where K_Hzjbxx.blh=#TempDDDs.blh   
       
       
--计算抗菌药物连用情况   
 --drop table  #yply,#Tempkss,#test,#T,#R,#Temp   
--计算抗菌药物连用情况   
Select blh, YPPZMC,yzcjsj,yzjssj into #yply from #Tempyymx    
  Where iskss=1      
      
    Create Table #Tempkss(blh varchar(50),ypfl varchar(1000),Cdate Varchar(10))       
     Declare @blh varchar(50),@YPPZMC varchar(40),@yz_kssj datetime,@yz_jssj datetime,@i int,@j int      
     Set @j=0       
     Declare kss_Cur Scroll Cursor For     
             Select blh,YPPZMC,yzcjsj,yzjssj   
               from #yply    
  Open kss_Cur         
   Fetch First From kss_Cur Into @blh,@YPPZMC,@yz_kssj,@yz_jssj       
   While @@Fetch_Status=0 Begin       
     Set @i=datediff(day,@yz_kssj,isnull(@yz_jssj,Getdate()))       
     print @i       
     While(@j<=@i) Begin      
       Insert into #Tempkss       
       Select @blh,@YPPZMC,convert(varchar(10),DateAdd(day,@j,@yz_kssj),120)        
       Set @j=@j+1       
     End      
     Set @j=0       
   Fetch Next From kss_Cur Into @blh,@YPPZMC,@yz_kssj,@yz_jssj     
  End        
 Close kss_Cur DealloCate kss_Cur    
     
 Select blh,count(distinct ypfl) yyzs into #tem from #Tempkss group by cdate,blh   
     
 Select blh,case When max(yyzs)>=2 Then 1 Else 0 End el,   
            case When max(yyzs)>2 Then 1 Else 0 End sl   
   into #R   
   from #tem    
  group by blh    
   
 Update K_Hzjbxx Set isLhyy2=el,isLhyy3=sl from #R Where K_Hzjbxx.blh=#R.blh   
  
        
END
