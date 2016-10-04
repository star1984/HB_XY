USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[K_ETL_Cf]    Script Date: 03/20/2015 09:30:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM K_Ypxx WHERE bidate BETWEEN '2015-01-01' AND '2015-01-31'
--exec [K_ETL_Cf] '2015-01-01','2015-03-30'
alter ProceDure [dbo].[xn_K_ETL_mzcf]   
 @StartDate VARCHAR(10),
 @EndDate VARCHAR(10),
 @je int
as
Begin 
--select top 1000  * from K_Ypxx  where mzh=1506010148 order by bidate desc
--select * from hbidata..infoMZCF  where CONVERT(VARCHAR(10),cfcjsj,120) between '2015-01-01' and '2015-06-05' and cflxdm in ('5','6','7') and mzh='1506020474' and cfdjh is null 

--���˴��������ǲ���û���ѣ���cfdjhΪnull
select distinct cfdjh into #cf0 from hbidata..infoMZCF 
where CONVERT(VARCHAR(10),cfcjsj,120) between @StartDate and @EndDate and cflxdm in ('5','6','7')  and cfdjh is  not null 


select  cfid INTO #cf from K_Ypxx 
where exists (select 1 from #cf0 a where a.cfdjh=K_Ypxx.cfid ) and  kstype LIKE '01%'
group by cfid
having sum(xssl) <>0


SELECT a.cfid into #cf2 FROM  K_Ypxx a
WHERE EXISTS (SELECT 1 FROM #cf WHERE a.cfid=#cf.cfid) and kstype LIKE '01%'
GROUP BY a.cfid
HAVING SUM(cfje)>@je

--���˵�һ���������ݺ��У�������ҩ�ļ�¼���緢��5��ҩ������2��ҩ����ô��ʾ������ݺ����3��ҩ����
select kstype+'|'+cfid+'|'+ypid as no ,* into #K_Ypxx_no from  K_Ypxx a
where EXISTS (SELECT 1 FROM #cf2 WHERE a.cfid=#cf2.cfid) and kstype LIKE '01%'
 
select no into #cf3 from #K_Ypxx_no a 
group by no 
having sum(xssl)<>0

--select * from #K_Ypxx_no 
--where no in (select no from #cf3) and cfid='P0434650'

--ʱ�䷶Χ,����ҽ������,ҩƷ�����ѯ,�������
--���ﴦ�����ݺ�,����,��������,�����Ա�,��������,�����(1504270537),��ҽ������,�������,ҩƷ����,���,��ҩ����(��λ),sig(�÷�����),��ҽ��ҽ��,�������,ҩƷ�������,��������

SELECT a.cfid,convert(varchar(10),b.cfcjsj,120) cfcjsj,a.hzxm,a.hzxb,a.hznldw,a.mzh,a.kscode,a.mzzd_mc,a.yplb,b.cfnr ,cast(cast(a.xssl as int) as varchar)+a.lydw as fysl,
       b.gyfsmc,zxpc,a.yscode,a.cfje,a.Ypdlfl,kstype,b.yongliang
FROM  #K_Ypxx_no a,hbidata..infoMZCF b
WHERE a.mzh=b.mzh and  a.cfid=b.cfdjh  and a.yppzdm=b.zlxmdm  and EXISTS (SELECT 1 FROM #cf3 WHERE a.no=#cf3.no)   and a.kstype like '01%' 
   








end