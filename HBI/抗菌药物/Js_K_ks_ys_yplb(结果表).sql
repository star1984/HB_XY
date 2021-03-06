USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[Js_K_ks_ys_yplb]    Script Date: 03/11/2015 15:54:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter ProceDure [dbo].[Js_K_ks_ys_yplb]   
 @StartDate varchar(10),
 @EndDate Varchar(10)
as
Begin
  delete K_ks_ys Where bidate between @StartDate And @EndDate

  Insert into K_ks_ys(biyear,biquarter,bimonth,biweek,bidate,kscode,ksName,yscode,
                      ysname,blh,hzxm,hzxb,a.hznl,a.nldw,ryrq,cyrq,isLhyy2,isLhyy3,kstype,yplb,ypid,iskss,
                      ys06,ys07,
                      yp21,xyzfy,kssxssl,tskssje,ypcbfy,kssddds) 
  Select DATEPART(yy,a.bidate) biyear,DATEPART(qq,a.bidate) biquarter,DATEPART(mm,a.bidate) bimonth,DATEPART(qq,a.bidate) biweek,a.bidate,
         a.cyks_code,a.cyks_name,a.zgys_code,a.zgys_name,a.blh,a.hzxm,a.hzxb,a.hznl,a.nldw,a.ryrq,a.cyrq,a.isLhyy2,a.isLhyy3,a.kstype,--科室分类--('011'普通门诊，'013'普通急诊，'022'普通住院，'023' 急诊住院) 
         b.yplb,b.YPID,b.iskss, --是否抗生素
         sum(isnull(b.cfje,0)) ys06, --药物费用
         Sum(Case When b.iskss=1 Then isnull(b.cfje,0) Else 0 End) ys07,--抗菌药物费用
         sum(Case When b.isjbyw=1 Then isnull(b.cfje,0) Else 0 End) yp21,--基本药物金额   
         Sum(Case When b.isXy=1 Then isnull(b.cfje,0) Else 0 End) xyzfy,--西药费用 
         sum(case when b.iskss=1 then b.xssl else 0 end),  --抗生素销售数量(片)
         SUM(CASE WHEN b.iskss=1 AND b.kssdj=3 THEN ISNULL(b.cfje,0) ELSE 0 end),  --特殊抗菌药物金额
         sum(isnull(b.ypjj,0)*isnull(b.xssl,0)),    --药品成本费用 
         sum(case when b.iskss=1 and (b.yongfa Like '%静脉%' or b.yongfa Like '%口服%' or b.yongfa Like '%肌内注射%' or b.yongfa Like '%术中用%' or b.yongfa Like '%微量泵%') then isnull(b.xssl,0) else 0 end)*max(b.DDDvalue)    --抗菌药品DDDS
    from K_Hzjbxx a  left join K_Ypxx b on a.MZID=b.MZID
    where a.bidate between @StartDate And @EndDate 
    group by a.bidate,a.cyks_code,a.cyks_name,a.zgys_code,a.zgys_name,a.blh,a.hzxm,a.hzxb,a.hznl,a.nldw,a.ryrq,a.cyrq,a.isLhyy2,a.isLhyy3,a.kstype,b.yplb,b.YPID,b.iskss
    

   
    
    
   -- (Select a.blh,b.bidate,a.yplb,a.YPID,a.iskss,
   --                   Sum(isnull(cfje,0)) ywzfy,--药物总费用
   --                   sum(Case When isjbyw=1 Then isnull(cfje,0) Else 0 End) jbywje,--基本药物金额
   --                   Sum(Case When iskss=1 Then isnull(cfje,0) Else 0 End) Kssfy,--抗菌药物总费用
   --                   Sum(Case When isXy=1 Then isnull(cfje,0) Else 0 End) xyfy,--西药总费用
   --                   sum(case when a.iskss=1 then a.xssl else 0 end) kssxssl,  --抗生素销售数量  这个字段只用于KSS的xssl，用来算DDDS的，Kss发药都是按片发
   --                   SUM(CASE WHEN a.iskss=1 AND a.kssdj=3 THEN ISNULL(cfje,0) ELSE 0 end) tskssje,--特殊抗菌药物金额
   --                   sum(a.ypjj*xssl) ypcbfy,--药物成本费用
   --                   sum(case when a.iskss=1 and (yongfa Like '%静脉%' or yongfa Like '%口服%' or yongfa Like '%肌内注射%' or yongfa Like '%术中用%' or yongfa Like '%微量泵%') then a.xssl else 0 end)*max(a.DDDvalue) KSSDDDS--抗菌药品消耗量DDDS
   --              from K_Ypxx a
   --             inner join K_Hzjbxx b on a.MZID=b.MZID
   --             Where b.bidate between @StartDate And @EndDate
   --             group by a.blh,b.bidate,a.yplb,a.YPID,a.iskss
   --            ) b  on a.blh=B.blh  and a.bidate=b.bidate 
   --Where a.bidate between @StartDate And @EndDate  
   --group by a.bidate,cyks_code,cyks_name,zgys_code,zgys_name,kstype ,b.yplb,b.YPID,b.iskss
   

   
   
End 

--select top 1000 * from K_ks_ys where tskssje>0 order by bidate
--exec [Js_K_ks_ys_yplb] '2015-01-01','2015-06-04'