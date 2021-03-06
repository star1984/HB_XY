USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[K_ETL_Cf]    Script Date: 08/12/2016 09:04:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM K_Ypxx WHERE bidate BETWEEN '2015-01-01' AND '2015-01-31'
--exec [K_ETL_Cf] '2015-01-01','2015-03-30'
ALTER ProceDure [dbo].[K_ETL_Cf]   
 @StartDate datetime,
 @EndDate datetime
as
Begin 
  
Delete K_Ypxx Where convert(varchar(10),bidate,120) between convert(varchar(10),@StartDate,120) And convert(varchar(10),@EndDate,120)   
--门诊 select top 1000 * from hbidata..infomzsf  where sflbdm='002'   select top 1000 * from hbidata..infoMZYFFYJL
  Insert into K_Ypxx(biyear,biquarter,bimonth,biweek,bidate,yfCode,yfName,kscode,ksname,  
                     yscode,ysname,kstype,CFID,blh,hzxm,hzxb,hznldw,CFMC,cfje,CFmxID,YPID,ypmc,iskss,yplb,  
                     isjbyw,DDDValue,DDDUnit,jx,gg,sccj,ggDW,iszj,isXy,DJ,kssdj,yptym,ypjj,lydw,  
                     gx,Yymd,DDDHsz,xssl,xssl_he,bzcs,jlzt,jlbz,jlxz,MZID,  
                     Ypdlfl,YpDlflcode,kjywpzdm,kjywpz_mc,sflbdm,sflbmc,yongfa,yzid,sfjlid,isyb,isnh)   
  Select DATEPART(yy,a.fysj) biyear,DATEPART(qq,a.fysj) biquarter,DATEPART(mm,a.fysj) bimonth,DATEPART(qq,a.fysj) biweek,convert(varchar(10),a.fysj,120) bidate,  
         a.yfdm ,a.yfmc ,--药房名称、代码  
         b.kcfksdm,b.kcfksmc,--处方科室代码、名称  
         b.kcfysdm,b.kcfysxm ,--开处方医生代码、名称  
         Case when c.isjz=1 Then '013' Else '011' End kstype,--科室分类('011'普通门诊，'013'普通急诊，'022'普通住院，'023' 急诊住院)  
         a.cfdjh,--处方ID  
         a.brid+'_'+cast(isnull(a.mzid,'') as varchar) brid,--病人ID
         c.hzxm,--患者姓名
         CASE WHEN c.hzxb=1 THEN '男' ELSE '女' end,--患者性别
         Ltrim(c.hznl)+c.nldw hznldw, --患者年龄单位
         null cfmc,--处方名称  
         a.ypje,--处方金额  
         a.cfdjh,--处方明细ID  
         a.YPID,--药品ID  
         d.YPMC,--药品名称  
         d.iskss,--是否抗生素  
         d.YPFLMC,--药品类别  
         d.IsJBYW,--是否基本药物   
         isnull(d.DDDValue,0) DDDValue,--DDD值  
         d.DDDUnit,--DDDUnit  
         d.JXMC,--剂型  
         d.GG,--规格  
         d.SCCJMC,--生产厂家  
         null ggdw,--规格单位  
         d.IsZJ,--是否针剂  
         case When d.YPLX=0 Then 1 Else 0 End isxy,--是西药  
         a.ypdj,--药品单价  
         d.KSSXZLB kssdj,--1非限制类/2限制类抗菌药物/3特殊类抗菌药物   
         d.ypmc1 yptym,--药品通用名  
         d.jj*1.0/d.DDDConvert jj,--进价   
         d.lydw,--领药单位   
         d.GX,--药品功效  
         0 yymd,--用药目的（1、治疗2、预防）  
         d.DDDConvert, --ddd换算单位  
         a.fysl  xssl,--销售数量 dw-售价单位 这个字段只用于KSS的xssl，用来算DDDS的，Kss发药都是按片发
         case when  d.lydw='片'   then  round(a.fysl/d.unitconvert,5)  
              when  d.lydw='枚'   then  round(a.fysl/d.unitconvert,5) 
              when  d.lydw='袋'   then  round(a.fysl/d.unitconvert,5) 
              when  d.lydw='粒'   then  round(a.fysl/d.unitconvert,5) 
              when  d.lydw='丸'   then  round(a.fysl/d.unitconvert,5) 
              when  d.lydw='贴'   then  round(a.fysl/d.unitconvert,5) else a.fysl end xssl_he,    --销售数量按盒统计              
         null bzcs,--包装参数  
         null jlzt, --记录状态  
         null jlbz, --记录标志  
         null jlxz, --记录性质  
         a.mzid MZID,--门诊ID  
         d.ypdlmc DLdLMC,--药品大类名称  
         d.ypdlmc DLdLDM, --药品大类代码  
         d.ypmc dm,--药品品种代码  
         d.ypmc mc, --药品品种名称
         d.YPLX  sflbdm,--药品类型代码 根据这个来分中成药和中草药
         CASE WHEN d.yplx=0 THEN '西药' 
              WHEN d.yplx=1 THEN '中成药'
              WHEN d.yplx=2 THEN '中草药' ELSE NULL end  sflbmc, --药品类型名称
         b.gyfsmc, --用法
         a.yzid,--医嘱ID用于关联
         null, --收费记录id用于关联
         null isyb,
         null isnh
    from hbidata..infoMZYFFYJL a  --门诊发药记录
         left join hbidata..infoMZCF b  on a.yzid=b.cfid  
         LEFT JOIN hbidata..infoMZGH c ON  a.mzid=c.gid 
         left join HBIData..WB_YPZD d on a.ypid=d.YPID
   Where convert(varchar(10),a.fysj,120) between  convert(varchar(10),@StartDate,120) And convert(varchar(10),@EndDate,120)  
   union All  
--住院  
  Select DATEPART(yy,a.fysj) biyear,DATEPART(qq,a.fysj) biquarter,DATEPART(mm,a.fysj) bimonth,DATEPART(qq,a.fysj) biweek,convert(varchar(10),a.fysj,120) bidate,  
         a.yfdm,a.yfmc,--药房名称、代码  
         b.kyzksdm,b.kyzksmc,--开药科室代码、名称  
         b.kyzysdm,b.kyzysxm,--开处方医生代码、名称
         Case when b.kyzksmc Like '%急诊%' Then '023' Else '022' End  kstype,--科室分类('011'普通门诊，'013'普通急诊，'022'普通住院，'023' 急诊住院)  
         a.yzdjh,--处方ID
         a.brid,--病人ID 
         c.hzxm,--患者姓名
         CASE WHEN c.hzxb=1 THEN '男' ELSE '女' end hzxb,--患者性别
         Ltrim(c.hznl)+c.nldw hznldw , --患者年龄单位
         null cfmc,--处方名称  
         a.ypje,--处方金额 
         a.yzdjh,--处方明细ID 
         a.YPID,--药品ID  
         d.YPMC,--药品名称  
         d.iskss,--是否抗生素  
         d.YPFLMC,--药品类别  
         d.IsJBYW,--是否基本药物   
         isnull(d.DDDValue,0) DDDValue,--DDD值  
         d.DDDUnit,--DDDUnit  
         d.JXMC,--剂型  
         d.GG,--规格  
         d.SCCJMC,--生产厂家  
         null ggdw,--规格单位  
         d.IsZJ,--是否针剂  
         case When d.YPLX=0 Then 1 Else 0 End isxy,--是西药  
         a.ypdj,--药品单价   
         d.KSSXZLB kssdj,--1非限制类/2限制类抗菌药物/3特殊类抗菌药物   
         d.ypmc1 yptym,--药品通用名  
         a.ypjj jj,--进价(成本价格)  
         d.lydw,--领药单位   
         NULL GX,--药品功效  
         0 yymd,--用药目的（1、治疗2、预防）  
         d.DDDConvert, --ddd换算单位  
         a.fysl   xssl,--销售数量 dw-售价单位 这个字段只用于KSS的xssl，用来算DDDS的，Kss发药都是按片发
         case when  d.lydw='片'   then  round(a.fysl/d.unitconvert,5)  
              when  d.lydw='枚'   then  round(a.fysl/d.unitconvert,5) 
              when  d.lydw='袋'   then  round(a.fysl/d.unitconvert,5) 
              when  d.lydw='粒'   then  round(a.fysl/d.unitconvert,5) 
              when  d.lydw='丸'   then  round(a.fysl/d.unitconvert,5) 
              when  d.lydw='贴'   then  round(a.fysl/d.unitconvert,5) else a.fysl end xssl_he,    --销售数量按盒统计   
         null bzcs,--包装参数  
         null jlzt, --记录状态  
         null jlbz, --记录标志  
         null jlxz, --记录性质  
         a.brid brid,--病案号 
         d.ypdlmc DLdLMC,--药品大类名称  
         d.ypdlmc DLdLDM, --药品大类代码  
         d.YPMC dm,--药品品种代码  
         d.YPMC  mc, --药品品种名称
         d.YPLX  sflbdm,--药品类型代码 根据这个来分中成药和中草药
         CASE WHEN d.yplx=0 THEN '西药' 
              WHEN d.yplx=1 THEN '中成药'
              WHEN d.yplx=2 THEN '中草药' ELSE NULL end  sflbmc, --药品类型名称 
         b.gyfsmc, --用法
         a.yzid,--医嘱ID用于关联
         null sfjlid,  --收费记录id 用于关联
         null isyb,
         null isnh
    from hbidata..infoZYYFFYJL a   --住院发药记录  
         left join HBIData..infoBryz b on  a.yzid=b.yzid
         LEFT JOIN HBIData..infoRYDJB c ON a.brid=c.gid
         left join HBIData..WB_YPZD d on a.ypid=d.YPID   --药品字典
   Where convert(varchar(10),a.fysj,120) between convert(varchar(10),@StartDate,120) And convert(varchar(10),@EndDate,120) --住院  
   
--由于HIS里存在不开医嘱处方就能收费发药的情况，因此根据门诊收费表和住院收费表更新开单科室为null的数据
UPDATE a 
SET kscode=b.kdksdm,ksname=b.kdksmc,  
    yscode=b.kdysdm,ysname=b.kdysxm
from K_Ypxx a,hbidata..infoMZSF b 
WHERE a.cfid=b.cfdjh AND ISNULL(a.kscode,'')=''


UPDATE a 
SET kscode=b.kdksdm,ksname=b.kdksmc,  
    yscode=b.kdysdm,ysname=b.kdysxm
from K_Ypxx a,hbidata..infoZYSF b 
WHERE a.cfid=b.cfdjh AND ISNULL(a.kscode,'')=''




   
/*
   --根据医生姓名及医生所在科室更新医生代码
   Update K_Ypxx 
   Set yscode=(select top 1 b.userid from HBIData..WB_Doctor b ,HBIData..WB_dept c
               where  K_Ypxx.ysname=replace(replace(replace(b.TName,char(10),''),char(13),''),' ','') AND b.DeptID=c.DeptID
                      AND  K_Ypxx.ksname LIKE '%'+LEFT(c.DeptName,1)+'%' and K_Ypxx.yscode is null)  
   where K_Ypxx.yscode is NULL AND CONVERT(VARCHAR(10),bidate,120) BETWEEN convert(varchar(10),@StartDate,120) And convert(varchar(10),@EndDate,120)
  --根据医生姓名更新医生代码 
     Update K_Ypxx 
   Set yscode=(select top 1 b.userid from HBIData..WB_Doctor b 
               where  K_Ypxx.ysname=replace(replace(replace(b.TName,char(10),''),char(13),''),' ','') and K_Ypxx.yscode is null)  
   where K_Ypxx.yscode is NULL AND CONVERT(VARCHAR(10),bidate,120) BETWEEN convert(varchar(10),@StartDate,120) And convert(varchar(10),@EndDate,120)
  */ 


     
 /*  

--更新年龄 
   --更新门诊
   update K_Ypxx
   set hzxm=a.hzxm,hzxb=case when a.hzxb=1 then '男' 
                             when a.hzxb=2 then '女' else null end ,
       hznldw=cast(a.hznl as varchar(10))+a.nldw,
       mzh=a.mzh
   from (select brid,mzh,hzxm,hzxb,hznl,nldw,max(ghsj) ghsj from HBIData..infoMZGH 
         group by brid,mzh,hzxm,hzxb,hznl,nldw) a
   where   substring(K_Ypxx.blh,1,charindex('_',K_Ypxx.blh)-1)=a.brid
          and datepart(yy,K_Ypxx.bidate)=datepart(yy,a.ghsj) 
          and convert(varchar(10),K_Ypxx.bidate,120) between convert(varchar(10),@StartDate,120) And convert(varchar(10),@EndDate,120) 
          
   
   
   --更新门诊病人诊断描述,处方1天内有效，每晚中联会自动删除超过24小时的处方
   --时间标志取挂号表的发生时间，因为病人可以在不挂号的情况下回诊，即不新挂号而发药。
     --获取时间范围起始日期3天前的挂号数据，且每天的挂号记录取最后一条门诊诊断不为空的记录
   select * into #mzgh from HBIData..infoMZGH a
    where (a.zxzt=1 or a.zxzt=2) 
          and a.ghsj=(select max(ghsj) from HBIData..infoMZGH b 
                      where a.mzh=b.mzh and b.mzzd_mc is not null and convert(varchar(10),a.ghsj,120)=convert(varchar(10),b.ghsj,120)  )
          and convert(varchar(10),a.ghsj,120) between convert(varchar(10),dateadd(day,-3,@StartDate),120) And convert(varchar(10),@EndDate,120)
   
   
   update K_Ypxx
   set  mzzd_mc=a.mzzd_mc
   from #mzgh a
   where K_Ypxx.mzh=a.mzh and datediff(dd,a.fssj,k_ypxx.bidate)<=1  and k_ypxx.kstype like '01%'
         and convert(varchar(10),K_Ypxx.bidate,120) between convert(varchar(10),@StartDate,120) And convert(varchar(10),@EndDate,120) 
  

   --更新住院
   update K_Ypxx
   set hzxm=a.hzxm,hzxb=case when a.hzxb=1 then '男' 
                             when a.hzxb=2 then '女' else null end ,
       hznldw=cast(a.hznl as varchar(10))+a.nldw
   from hbidata..infoRYDJB a
   where    K_Ypxx.blh=a.gid  and convert(varchar(10),K_Ypxx.bidate,120) between convert(varchar(10),@StartDate,120) And convert(varchar(10),@EndDate,120)
   
    
*/
		
   
       
End  
--Select top 100 * from HBIDATA..infoMZYFFYJL
 
 --Select yfname,count(distinct CFID),sum(xssl*DJ*1.0) je
 --  from K_Ypxx 
 -- Where bidate between '2014-11-01' And '2014-11-30' And kstype='02'
 -- group by yfname
 --   Select yfmc,count(distinct cfdjh),sum(sl*ypdj) je from HBIData..infoZYYFFYJL
 -- Where convert(varchar(10),jfsj,120) between '2014-11-01' And '2014-11-30'
 -- group by yfmc
  
 --     Select yfmc,count(distinct cfdjh),sum(xssl*ypdj) je
 --  from #b
 -- Where bidate between '2015-03-01' And '2015-03-31' 
 -- group by yfmc

  --TRUNCATE table  K_Ypxx
  
--  Select yfmc,count(distinct cfdjh),sum(sl*ypdj) je from HBIData..infomzYFFYJL
--  Where convert(varchar(10),jfsj,120) between '2014-11-01' And '2014-11-30'
--  group by yfmc
  
   
  
   -- Select  convert(varchar(10),b.jfsj,120) bidate,  
   --      b.yfdm,b.yfmc,--药房名称、代码  
   --      b.lybmdm,b.lybmmc,--开处方科室代码、名称   
         
   --      b.cfdjh,--处方ID  
        
   --      b.ypdj,--药品单价   
          
   --      b.sl xssl--销售数量   
   -- into #b
   -- from HBIData..infoZYYFFYJL b   --住院发药记录表     
   --left join 
   --inner join HBIData..WB_YPZD c on b.ypid=c.YPID   --药品字典  
   --Where convert(varchar(10),b.jfsj,120) between '2014-11-01' And '2014-11-30' --住院 
    
    
--  Select [yfmc],count(distinct cfdjh),sum(sl*ypdj) from infoZYYFFYJL 
--Where convert(varchar(10),[jfsj],120) between '2014-11-01' And '2014-11-30' group by [yfmc] 
--exec [K_ETL_Cf] '2016-05-01' , '2016-08-11' 
--truncate table K_Ypxx
--SELECT * FROM HBIData..WB_YPZD WHERE iskss=1

--SELECT top 2000 * FROM K_Ypxx where isnh=1