USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[Js_K_ks_ys_yp]    Script Date: 03/18/2015 10:08:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER ProceDure [dbo].[Js_K_ks_ys_yp]      
 @StartDate varchar(10),   
 @EndDate Varchar(10) 

as  
Begin  
  delete K_ks_ys_yp Where bidate between @StartDate And @EndDate   
    
  Insert into K_ks_ys_yp(biyear,biquarter,bimonth,biweek,bidate,kscode,yscode,   
                         ksname,ysname,kstype,yp01,yp02,yp03,yp04,yp05,yp06,yp07,   
                         yp08,yp09,yp10,yp11,yp12,yp13,yp15,yp16,yp17,yp18,Yp19,yp20,   
                         yp21,yp22,YP25,YP26,DDDhsz,bzcs,ypdlfl,Ypdlflcode,ywpzdm,ywpzmc,ypslUnitConvert,isyb,isnh)    
  Select DATEPART(yy,a.bidate) biyear,DATEPART(qq,a.bidate) biquarter,DATEPART(mm,a.bidate) bimonth,   
         DATEPART(qq,a.bidate) biweek,a.bidate bidate,   
         a.kscode,a.yscode,a.ksname,a.ysname,a.kstype,
         a.ypmc yp01,--药品名称   
         a.ypid yp02,--药品代码   
         a.yptym yp03,--药通用名   
         a.DJ yp04,--零售价格   
         sum(isnull(Xssl,0)) yp05,--使用数量   
         sum(isnull(Xssl,0))*max(a.DJ) yp06,--销售金额   
         max( Case When iskss=1 Then 1 Else 0 End) yp07,--是否抗菌药物   
         a.yplb yp08,--药品小类分类   
         max( Case When iszj=1 Then 1 Else 0 End) yp09,--是否针剂   
         a.jx yp10,--剂型   
         max( Case When isjbyw=1 Then 1 Else 0 End) yp11,--是否基本药物   
         max( Case When isXy=1 Then 1 Else 0 End) yp12,--中或西药(1西)   
         kssdj yp13,--抗生素级别   
         DDDValue yp15,--DDD成人限定日剂量   
         count(distinct a.blh) yp16,--使用人次   
         gg yp17,--规格   
         lydw yp18,--单位(领要单位)   
         DDDUnit Yp19,--DDD单位    
       --sum(case when   ksname not like '%儿%'  and  (yongfa Like '%静脉%' or yongfa Like '%口服%' or yongfa Like '%肌内注射%' or yongfa Like '%术中用%' or yongfa Like '%微量泵%')
       --         then   Xssl else 0 end)*max(DDDValue) yp20,   --累计DDD数（DDDs）抗菌药物消耗量   因为临汾人民医院在维护DDD值时，是按“DDD=规格/(理论DDD)”维护的
         sum(xssl)*max(DDDValue) yp20,--累计DDD数（DDDs）抗菌药物消耗量   因为临汾人民医院在维护DDD值时，是按“DDD=规格/(理论DDD)”维护的
         ypjj yp21,--药品进价   
         GX yp22,--功效   
         lydw YP25,--领药单位   
         sccj YP26,--生产厂家    
         max(DDDhsz) DDDhsz,--换算率   
         bzcs bzcs,--包装参数   
         Ypdlfl,--大类分类名称   
         YpDlflcode,--大类分类名称    
         YPPZdm,--药品品种代码   
         YPPZMC,--药品品种名称  
         sum(isnull(Xssl_he,0))  ypslUnitConvert,--使用数量
         a.isyb,
         a.isnh  
         
    from K_Ypxx a     
   Where convert(varchar(10),a.bidate,120) between @StartDate And @EndDate  
   group by a.bidate,a.kscode,a.yscode,a.ksname,a.ysname,a.kstype,Ypdlfl,YpDlflcode,a.yplb,a.YPPZdm,a.YPPZMC,a.ypmc,a.ypid,a.yptym,a.DJ,a.jx, a.kssdj,a.DDDValue,a.gg,a.lydw,a.DDDunit,a.ypjj,
            a.gx,a.lydw,a.sccj,a.bzcs,a.isyb, a.isnh
        
            
--因为有同名同姓的医生，统计发药金额数量时，报表上不能体现出来。因此要用科室区分开来，由于一个医生可能存在对应多个科室，因此合并科室到一个字段里         
select distinct  yscode,ksname   into #ysks from K_ks_ys_yp
where convert(varchar(10),bidate,120)  between @StartDate And @EndDate  

Update K_ks_ys_yp Set kscode_stuff= Stuff((Select ','+cast(aa.ksname As Varchar(500)) From #ysks aa      --更新kscode_stuff
									       Where  aa.yscode=K_ks_ys_yp.yscode  and convert(varchar(10),K_ks_ys_yp.bidate,120)  between @StartDate And @EndDate
									For Xml Path('')
									),1,1,'')  
   From #ysks a 
Where  a.yscode=K_ks_ys_yp.yscode and convert(varchar(10),K_ks_ys_yp.bidate,120)  between @StartDate And @EndDate
		
   



     
      
END

--truncate table K_ks_ys_yp 
--exec Js_K_ks_ys_yp '2016-05-01','2016-08-11'