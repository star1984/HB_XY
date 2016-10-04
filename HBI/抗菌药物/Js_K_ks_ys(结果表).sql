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
         cyks_code,cyks_name,zgys_code,zgys_name,kstype,--���ҷ���--('011'��ͨ���'013'��ͨ���'022'��ͨסԺ��'023' ����סԺ)
         Sum(CASE WHEN datediff(day,ryrq,cyrq)=0 THEN 1 ELSE datediff(day,ryrq,cyrq) end) zyts,--סԺ����
         Sum(isnull(a.ylzfy,0)) ys05,--ҽ���ܷ���
         sum(isnull(b.ywzfy,0)) ys06, --ҩ���ܷ���
         sum(isnull(b.Kssfy,0)) ys07,--����ҩ�����
         sum(isnull(b.Jbywje,0)) yp21,--����ҩ����   
         Sum(isnull(b.xyfy,0)) xyzfy,--��ҩ�ܷ��� 
         sum(isnull(b.kssxssl,0)) kssxssl,  --��������������(Ƭ)
         SUM(ISNULL(b.tskssje,0)) tskssje,  --���⿹��ҩ����
         SUM(ISNULL(b.ypcbfy,0)) ypcbfy,    --ҩƷ�ɱ����� 
         SUM(ISNULL(b.KSSDDDS,0)) kssddds   --����ҩƷDDDS
    from K_Hzjbxx a  
    --��������
    left join (Select a.blh,b.bidate,
                      max(distinct Case When iskss=1 Then 1 Else 0 End) isSykss,--�Ƿ�ʹ�ÿ���ҩ��
                      max(distinct Case When jx Like '%ע��%' Then 1 Else 0 End) isSyzsj,--�Ƿ�ʹ��ʹ��ע���
                      max(distinct Case When iskss=1 And kssdj=3 Then 1 Else 0 End) isSyTskss,--�Ƿ�ʹ��ʹ�����⿹��
                      max(distinct Case When iskss=1 And kssdj=2 Then 1 Else 0 End) isSyXzkss,--�Ƿ�ʹ��ʹ�����ƿ���
                      max(distinct Case When isjbyw=1 Then 1 Else 0 End) syjbyw,--�Ƿ�ʹ�û���ҩ��
                      sum(Case When isjbyw=1 Then isnull(cfje,0) Else 0 End) jbywje,--����ҩ����
                      max(Case When Yymd=1 And iskss=1 And kssdj=2 Then 1 Else 0 end) XzKssZl,--�Ƿ�ʹ�������࿹��ҩ��ʹ������
                      max(Case When iskss=1 And kssdj=3 Then 1 Else 0 end) SyTsKss,--�Ƿ�ʹ�������࿹��ҩ��
                      max(Case When Yymd=1 And iskss=1 And kssdj=3 Then 1 Else 0 end) Sytsksszl,--�Ƿ�ʹ�������࿹��ҩ��ʹ������
                      Sum(isnull(cfje,0)) ywzfy,--ҩ���ܷ���
                      Sum(Case When iskss=1 Then isnull(cfje,0) Else 0 End) Kssfy,--����ҩ���ܷ���
                      Sum(Case When isXy=1 Then isnull(cfje,0) Else 0 End) xyfy,--��ҩ�ܷ���
                      sum(case when a.iskss=1 then a.xssl else 0 end) kssxssl,  --��������������  ����ֶ�ֻ����KSS��xssl��������DDDS�ģ�Kss��ҩ���ǰ�Ƭ��
                      SUM(CASE WHEN a.iskss=1 AND a.kssdj=3 THEN ISNULL(cfje,0) ELSE 0 end) tskssje,--���⿹��ҩ����
                      sum(a.ypjj*xssl) ypcbfy,--ҩ��ɱ�����
                      sum(case when a.iskss=1 and (yongfa Like '%����%' or yongfa Like '%�ڷ�%' or yongfa Like '%����ע��%' or yongfa Like '%������%' or yongfa Like '%΢����%') then a.xssl else 0 end)*max(a.DDDvalue) KSSDDDS--����ҩƷ������DDDS
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