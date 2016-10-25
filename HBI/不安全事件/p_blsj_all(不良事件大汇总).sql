USE [HBI_hmi]
GO
/****** Object:  StoredProcedure [dbo].[p_blsj_all]    Script Date: 07/03/2016 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[p_blsj_all]
@startDate varchar(10),
@endDate varchar(10)
as
BEGIN 



--��Ϊ�ʿذ�Ҫȫ�����ܣ�����Ϊ�����¼��ۺϱ����͸�ר�ⱨ��������Ҫ�ٴκϲ�
--�����¼����� :ҽ�ơ�����Ժ�С��ΰ������ڡ���Ϣ    
truncate table W_blsj_dl_all
Insert into W_blsj_dl_all(xh,dm,mc)
SELECT 1,'01','ҽ�ư�ȫ�����¼�'
UNION 
SELECT 2,'02','����ȫ�����¼�'
UNION 
SELECT 3,'03','ְҵ��¶�����ڸ�Ⱦ��ز����¼�'
UNION 
SELECT 4,'04','�ΰ��˺��¼�' 
UNION 
SELECT 5,'05','���ڷ�������¼�' 
UNION 
SELECT 6,'06','��Ϣϵͳ��ز����¼�' 
UNION 
SELECT 7,'07','�����豸��ȫ�����¼�' 
UNION 
SELECT 8,'08','ҩƷ������Ӧ�¼�' 

--�ۺϱ�������+�������¼�(��ר��)+��Ⱦ+ְҵ��¶
truncate table W_blsj_dl2_all

SELECT  dm,mc INTO #blsj_dl2_all   FROM W_xyblsj_dl --�ۺϱ�������
UNION ALL
--�����˹�����
SELECT '001' dm,'��ҩ����' mc 
union all 
SELECT '002' dm,'�ѹ��¼�' mc 
union all 
SELECT '003' dm,'�걾�¼�' mc
union all 
SELECT '004' dm,'��Ϣ���ݴ���' mc
union all 
SELECT '005' dm,'��Ѫ�¼�' mc
union all 
SELECT '006' dm,'���������¼�' mc
union all 
SELECT '007' dm,'��ʳ�¼�' mc
union all 
SELECT '008' dm,'����Ϊ�¼�' mc
union all 
SELECT '009' dm,'ѹ��' mc
union all 
SELECT '010' dm,'����' mc
union all 
SELECT '011' dm,'׹��' mc
union all 
SELECT '012' dm,'��Һ��Ӧ' mc
union all 
SELECT '013' dm,'���Ѫ˨' mc
union all 
SELECT '014' dm,'����' mc
union all 
SELECT '015' dm,'����' mc 
UNION 
--�Զ������
SELECT '100' dm,'Ժ�ڸ�Ⱦ' mc 
UNION 
SELECT '101' dm,'ְҵ��¶' mc 
UNION 
SELECT '102' dm,'�����豸��ȫ�����¼�' mc 
UNION 
SELECT '103' dm,'ҩƷ������Ӧ�¼�' mc

Insert into W_blsj_dl2_all(xh,dm,mc)
SELECT  ROW_NUMBER() over(order by dm) xh ,dm,mc FROM #blsj_dl2_all


SELECT a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,a.blsjlb,a.blsjlbxl,a.fgbm INTO #zhblsj FROM  mpehr..TSf_blsj_XY a INNER JOIN MPEHR.dbo.T_shyj b ON a.id=b.gid 
WHERE b.shzt=1  AND CONVERT(VARCHAR(10),a.sjfsrq,120) BETWEEN @startDate AND @endDate 

--ҽ��
SELECT  '01' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy sjyy,a.cxgjcs zgcs,a.blsjdj,a.sjfsrq,a.blsjlb INTO #blsj_all FROM  #zhblsj a 
WHERE a.fgbm IN ('01','03','04','09') 
UNION all
--����
SELECT  '02' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy,a.cxgjcs,a.blsjdj,a.bidate,a.lb blsjlb FROM  T_blsjtj_hlb a 
WHERE CONVERT(VARCHAR(10),a.bidate,120) BETWEEN @startDate AND @endDate 
UNION all 
--��Ⱦ
SELECT  '03' lb,a.kscode ks, b.zyh,b.hzxm,NULL sjjg,NULL dzsjdknyy,NULL  cxgjcs,NULL blsjdj,a.bidate,'100' blsjlb  from  Gr_GrInfo a LEFT JOIN HBIDATA..infoRYDJB b ON a.zyh=RIGHT(b.zyh,6) AND a.zycs=b.zycs
WHERE CONVERT(VARCHAR(10),a.bidate,120) BETWEEN @startDate AND @endDate 
UNION all 
--ְҵ��¶
SELECT '03' lb,a.fsks,NULL zyh,a.name,NULL sjjg,NULL dzsjdknyy,NULL  cxgjcs,NULL blsjdj,a.bidate,'101' blsjlb FROM   T_zybl a
WHERE CONVERT(VARCHAR(10),a.bidate,120) BETWEEN @startDate AND @endDate 
UNION all 
--�ΰ�
SELECT  '04' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy sjyy,a.cxgjcs zgcs,a.blsjdj,a.sjfsrq,a.blsjlb  FROM  #zhblsj a 
WHERE a.fgbm='07' 
UNION all 
--����
SELECT  '05' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy sjyy,a.cxgjcs zgcs,a.blsjdj,a.sjfsrq,a.blsjlb  FROM  #zhblsj a 
WHERE a.fgbm='06'
UNION all 
--��Ϣ
SELECT  '06' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy sjyy,a.cxgjcs zgcs,a.blsjdj,a.sjfsrq,a.blsjlb  FROM  #zhblsj a 
WHERE a.fgbm='05' 
UNION all 
--�����豸��ȫ�����¼�
SELECT  '07' lb,a.bgks,a.zyh,a.hzxm,a.sjcs sjjg,a.sjfscbyyfx sjyy,a.sjcbclqg zgcs,NULL blsjdj,a.bgrq sjfsrq,'102' blsjlb  FROM  mpehr..TSF_Kyylqxblsjbg a 
WHERE  CONVERT(VARCHAR(10),a.bgrq,120) BETWEEN @startDate AND @endDate 
UNION all 
--ҩƷ������Ӧ�¼�
SELECT  '08' lb,a.ks,a.mzh zyh,a.hzxm,a.blms sjjg,null sjyy,null zgcs,NULL blsjdj,a.blfssj sjfsrq,'103' blsjlb  FROM  mpehr..TSF_ypblfybg_M a 
WHERE  CONVERT(VARCHAR(10),a.blfssj,120) BETWEEN @startDate AND @endDate 



--�����¼����ܱ�
Delete from T_blsj_all where CONVERT(varchar(10),bidate,120) between @startDate and @endDate 

INSERT INTO [HBI_HMI].[dbo].[T_blsj_all]
           ([biyear]
           ,[biquarter]
           ,[bimonth]
           ,[biweek]
           ,[bidate]
           ,[lb]
           ,[sbks]
           ,[zyh]
           ,[hzxm]
           ,[sjjg]
           ,[sjyy]
           ,[zgcs]
           ,[blsjdj]
           ,[blsjlb])
SELECT DATEPART(YY,a.sjfsrq) biyear,DATEPART(QQ,a.sjfsrq) biquarter,DATEPART(MM,a.sjfsrq) biMonth,DATEPART(WW,a.sjfsrq) biweek,
       a.sjfsrq bidate,a.lb,a.ks sbks ,a.zyh,a.hzxm,a.sjjg,a.sjyy,a.zgcs,a.blsjdj,a.blsjlb               
FROM  #blsj_all a
WHERE CONVERT(VARCHAR(10),a.sjfsrq,120) BETWEEN @startDate AND @endDate 



end
/*
	exec p_blsj_all '2016-01-01','2016-10-24'
	select * from T_blsj_all


*/

--


