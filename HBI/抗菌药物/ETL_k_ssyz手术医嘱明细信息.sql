USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[ETL_k_ssyz]   Script Date: 03/24/2015 16:33:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter ProceDure [dbo].[ETL_k_ssyz]
@startTime varchar(10),
@endTime varchar(10)
As
Begin

  Delete from T_k_ssyzmx where Convert(varchar(10),bidate,120) between @startTime and @endTime 

  Insert into T_k_ssyzmx(biyear,biquarter,bimonth,biweek,bidate,ssmc,qkdj,sskssj,ssjssj,ssks,ssys_code,zyh,zycs,hzxm,yz_yznr,yz_ks,kyzysxm,
                         yzkssj,yzjssj,yzzxsj,sqkssmd,is_yfssKss_xy24,is_yfssKss_dy24,is_yfsykss_xy48,is_yfsykss_dy48,is_Sqbxs_Sykss,isSykss,isYfsykss,
                         is_Szyf_Sykss,is_Shyf_Sykss,is_sqfxzyf_sykss,is_szfxzyf_sykss,is_shfxzyf_sykss)
  select DATEPART(yy,a.bidate),DATEPART(qq,a.bidate),DATEPART(mm,a.bidate),DATEPART(ww,a.bidate),convert(varchar(10),a.bidate,120) bidate,
         a.ss_name,a.qkdj,a.sskssj,a.ssjssj,a.kscode ssks,a.ssys_code,a.zyh,a.zycs,a.hzxm,b.yz_yznr,b.yz_ks,d.kyzysxm,b.yzkssj,b.yzjssj,c.yzzxsj,
         case when b.sqkssmd=1 then 'ÖÎÁÆ'  
              when b.sqkssmd=2 then 'Ô¤·À' 
              when b.sqkssmd=3 then 'Ô¤·ÀÖÎÁÆ' else null end sqkssmd,
         a.is_yfssKss_xy24,a.is_yfssKss_dy24,a.is_yfsykss_xy48,a.is_yfsykss_dy48,a.is_Sqbxs_Sykss,a.isSykss,a.isYfsykss ,
         a.is_Szyf_Sykss,a.is_Shyf_Sykss,a.is_sqfxzyf_sykss,a.is_szfxzyf_sykss,a.is_shfxzyf_sykss                 
  from K_SSxx a left join (
                          select case when CHARINDEX('_', yz_yzbh) >0 then left(yz_yzbh,CHARINDEX('_', yz_yzbh)-1) else yz_yzbh end as yzid,yz_ks,
                                 blh,yz_yzzt,yz_yongfa,yz_kssj yzkssj,yz_jssj yzjssj,yz_yznr,yz_commonyp yszt,ypcode,iskss,yz_yymd sqkssmd  from dlgr..his_yz 
                          where  iskss=1 and yz_yzzt<>'×÷·Ï'  and  yz_yongfa not like '%Æ¤ÊÔ%'
                         ) b on a.blh=b.blh 
                left join HBIData.dbo.infoYZZX c on b.yzid=c.yzid 
                left join HBIData.dbo.infoBryz d on b.yzid=d.yzid
  where convert(varchar(10),a.bidate,120) between  @startTime   and  @endTime and ssys_code is not null


end