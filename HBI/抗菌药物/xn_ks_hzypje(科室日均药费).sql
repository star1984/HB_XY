USE [HBI_GR]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter ProceDure [dbo].[xn_ks_hzypje]   
 @StartDate varchar(10),
 @EndDate varchar(10)


as
Begin 
--select  top 1000 * from K_Ypxx order by bidate desc
--select  top 1000 * from hbidata..infoBrzkjl

--סԺ����ҩ���ܽ��
select kscode,bidate,sum(cfje) cfje into #ksje from K_Ypxx
where convert(varchar(10),bidate,120) between @StartDate  and @EndDate  and kstype like '02%'
group by kscode,bidate

--�����ڿ�����
select ksdm,zkrq,count(*) daynum into #ksdays from  hbidata..infoBrzkjl
where convert(varchar(10),zkrq,120) between @StartDate  and @EndDate 
group by ksdm,zkrq 

--���¿���
  --��������һ���Ϊ��������
update #ksdays 
set ksdm=165
where ksdm=283
  --�����Ʋ���ʹ�ã���Ϊ������֢ҽѧ��
update #ksdays 
set ksdm=47
where ksdm=262
  

--�����վ�ҩ�� --case when a.daynum=0 then 0 else isnull(b.cfje,0)*1.0/a.daynum end 
select a.ksdm,a.zkrq,isnull(b.cfje,0),a.daynum from #ksdays a left join #ksje b on a.ksdm=b.kscode and a.zkrq=b.bidate







end