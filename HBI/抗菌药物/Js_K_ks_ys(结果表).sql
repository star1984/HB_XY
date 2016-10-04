USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[Js_K_ks_ys]    Script Date: 03/11/2015 15:54:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER ProceDure [dbo].[Js_K_ks_ys]   
 @StartDate varchar(10),
 @EndDate Varchar(10)
as
Begin
  delete T_K_ks_ys_fy Where bidate between @StartDate And @EndDate

  Insert into T_K_ks_ys_fy(biyear,biquarter,bimonth,biweek,bidate,kscode,ksName,yscode,
                      ysname,kstype,zyts,
                      ys05,ys06,ys07,
                      yp21,xyzfy,kssxssl,tskssje,ypcbfy,kssddds) 
  Select DATEPART(yy,a.bidate) biyear,DATEPART(qq,a.bidate) biquarter,DATEPART(mm,a.bidate) bimonth,DATEPART(qq,a.bidate) biweek,a.bidate,
         cyks_code,cyks_name,zgys_code,zgys_name,kstype,--科室分类--('011'普通门诊，'013'普通急诊，'022'普通住院，'023' 急诊住院)
         Sum(CASE WHEN datediff(day,ryrq,cyrq)=0 THEN 1 ELSE datediff(day,ryrq,cyrq) end) zyts,--住院天数
         Sum(isnull(a.ylzfy,0)) ys05,--医疗总费用
         sum(isnull(b.ywzfy,0)) ys06, --药物总费用
         sum(isnull(b.Kssfy,0)) ys07,--抗菌药物费用
         sum(isnull(b.Jbywje,0)) yp21,--基本药物金额   
         Sum(isnull(b.xyfy,0)) xyzfy,--西药总费用 
         sum(isnull(b.kssxssl,0)) kssxssl,  --抗生素销售数量(片)
         SUM(ISNULL(b.tskssje,0)) tskssje,  --特殊抗菌药物金额
         SUM(ISNULL(b.ypcbfy,0)) ypcbfy,    --药品成本费用 
         SUM(ISNULL(b.KSSDDDS,0)) kssddds   --抗菌药品DDDS
    from K_Hzjbxx a  
    --处方数据
    left join (Select a.blh,b.bidate,
                      max(distinct Case When iskss=1 Then 1 Else 0 End) isSykss,--是否使用抗菌药物
                      max(distinct Case When jx Like '%注射%' Then 1 Else 0 End) isSyzsj,--是否使用使用注射剂
                      max(distinct Case When iskss=1 And kssdj=3 Then 1 Else 0 End) isSyTskss,--是否使用使用特殊抗菌
                      max(distinct Case When iskss=1 And kssdj=2 Then 1 Else 0 End) isSyXzkss,--是否使用使用限制抗菌
                      max(distinct Case When isjbyw=1 Then 1 Else 0 End) syjbyw,--是否使用基本药物
                      sum(Case When isjbyw=1 Then isnull(cfje,0) Else 0 End) jbywje,--基本药物金额
                      max(Case When Yymd=1 And iskss=1 And kssdj=2 Then 1 Else 0 end) XzKssZl,--是否使用限制类抗菌药物使用治疗
                      max(Case When iskss=1 And kssdj=3 Then 1 Else 0 end) SyTsKss,--是否使用特殊类抗菌药物
                      max(Case When Yymd=1 And iskss=1 And kssdj=3 Then 1 Else 0 end) Sytsksszl,--是否使用特殊类抗菌药物使用治疗
                      Sum(isnull(cfje,0)) ywzfy,--药物总费用
                      Sum(Case When iskss=1 Then isnull(cfje,0) Else 0 End) Kssfy,--抗菌药物总费用
                      Sum(Case When isXy=1 Then isnull(cfje,0) Else 0 End) xyfy,--西药总费用
                      sum(case when a.iskss=1 then a.xssl else 0 end) kssxssl,  --抗生素销售数量  这个字段只用于KSS的xssl，用来算DDDS的，Kss发药都是按片发
                      SUM(CASE WHEN a.iskss=1 AND a.kssdj=3 THEN ISNULL(cfje,0) ELSE 0 end) tskssje,--特殊抗菌药物金额
                      sum(a.ypjj*xssl) ypcbfy,--药物成本费用
                      sum(case when a.iskss=1 and (yongfa Like '%静脉%' or yongfa Like '%口服%' or yongfa Like '%肌内注射%' or yongfa Like '%术中用%' or yongfa Like '%微量泵%') then a.xssl else 0 end)*max(a.DDDvalue) KSSDDDS--抗菌药品消耗量DDDS
                 from K_Ypxx a
                inner join K_Hzjbxx b on a.MZID=b.MZID
                Where b.bidate between @StartDate And @EndDate
                group by a.blh,b.bidate
               ) b  on a.blh=B.blh  and a.bidate=b.bidate 
   Where a.bidate between @StartDate And @EndDate  
   group by a.bidate,cyks_code,cyks_name,zgys_code,zgys_name,kstype 
   

   
   
End 

--select top 1000 * from T_K_ks_ys_fy where tskssje>0 order by bidate
--exec [Js_K_ks_ys] '2015-04-01','2015-07-19'