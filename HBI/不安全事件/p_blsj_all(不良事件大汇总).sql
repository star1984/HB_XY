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



--因为质控办要全部汇总，而分为不良事件综合报告表和各专题报告表，因此需要再次合并
--不良事件种类 :医疗、护理、院感、治安、后勤、信息    
truncate table W_blsj_dl_all
Insert into W_blsj_dl_all(xh,dm,mc)
SELECT 1,'01','医疗安全不良事件'
UNION 
SELECT 2,'02','护理安全不良事件'
UNION 
SELECT 3,'03','职业暴露及感内感染相关不良事件'
UNION 
SELECT 4,'04','治安伤害事件' 
UNION 
SELECT 5,'05','后勤服务相关事件' 
UNION 
SELECT 6,'06','信息系统相关不良事件' 
UNION 
SELECT 7,'07','仪器设备安全不良事件' 
UNION 
SELECT 8,'08','药品不良反应事件' 

--综合报告表大类+护理不良事件(含专题)+感染+职业暴露
truncate table W_blsj_dl2_all

SELECT  dm,mc INTO #blsj_dl2_all   FROM W_xyblsj_dl --综合报告表大类
UNION ALL
--护理人工分类
SELECT '001' dm,'给药错误' mc 
union all 
SELECT '002' dm,'脱管事件' mc 
union all 
SELECT '003' dm,'标本事件' mc
union all 
SELECT '004' dm,'信息传递错误' mc
union all 
SELECT '005' dm,'输血事件' mc
union all 
SELECT '006' dm,'基础护理事件' mc
union all 
SELECT '007' dm,'饮食事件' mc
union all 
SELECT '008' dm,'不作为事件' mc
union all 
SELECT '009' dm,'压疮' mc
union all 
SELECT '010' dm,'跌倒' mc
union all 
SELECT '011' dm,'坠床' mc
union all 
SELECT '012' dm,'输液反应' mc
union all 
SELECT '013' dm,'深静脉血栓' mc
union all 
SELECT '014' dm,'外渗' mc
union all 
SELECT '015' dm,'渗出' mc 
UNION 
--自定义分类
SELECT '100' dm,'院内感染' mc 
UNION 
SELECT '101' dm,'职业暴露' mc 
UNION 
SELECT '102' dm,'仪器设备安全不良事件' mc 
UNION 
SELECT '103' dm,'药品不良反应事件' mc

Insert into W_blsj_dl2_all(xh,dm,mc)
SELECT  ROW_NUMBER() over(order by dm) xh ,dm,mc FROM #blsj_dl2_all


SELECT a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,a.blsjlb,a.blsjlbxl,a.fgbm INTO #zhblsj FROM  mpehr..TSf_blsj_XY a INNER JOIN MPEHR.dbo.T_shyj b ON a.id=b.gid 
WHERE b.shzt=1  AND CONVERT(VARCHAR(10),a.sjfsrq,120) BETWEEN @startDate AND @endDate 

--医疗
SELECT  '01' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy sjyy,a.cxgjcs zgcs,a.blsjdj,a.sjfsrq,a.blsjlb INTO #blsj_all FROM  #zhblsj a 
WHERE a.fgbm IN ('01','03','04','09') 
UNION all
--护理
SELECT  '02' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy,a.cxgjcs,a.blsjdj,a.bidate,a.lb blsjlb FROM  T_blsjtj_hlb a 
WHERE CONVERT(VARCHAR(10),a.bidate,120) BETWEEN @startDate AND @endDate 
UNION all 
--感染
SELECT  '03' lb,a.kscode ks, b.zyh,b.hzxm,NULL sjjg,NULL dzsjdknyy,NULL  cxgjcs,NULL blsjdj,a.bidate,'100' blsjlb  from  Gr_GrInfo a LEFT JOIN HBIDATA..infoRYDJB b ON a.zyh=RIGHT(b.zyh,6) AND a.zycs=b.zycs
WHERE CONVERT(VARCHAR(10),a.bidate,120) BETWEEN @startDate AND @endDate 
UNION all 
--职业暴露
SELECT '03' lb,a.fsks,NULL zyh,a.name,NULL sjjg,NULL dzsjdknyy,NULL  cxgjcs,NULL blsjdj,a.bidate,'101' blsjlb FROM   T_zybl a
WHERE CONVERT(VARCHAR(10),a.bidate,120) BETWEEN @startDate AND @endDate 
UNION all 
--治安
SELECT  '04' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy sjyy,a.cxgjcs zgcs,a.blsjdj,a.sjfsrq,a.blsjlb  FROM  #zhblsj a 
WHERE a.fgbm='07' 
UNION all 
--后勤
SELECT  '05' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy sjyy,a.cxgjcs zgcs,a.blsjdj,a.sjfsrq,a.blsjlb  FROM  #zhblsj a 
WHERE a.fgbm='06'
UNION all 
--信息
SELECT  '06' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy sjyy,a.cxgjcs zgcs,a.blsjdj,a.sjfsrq,a.blsjlb  FROM  #zhblsj a 
WHERE a.fgbm='05' 
UNION all 
--仪器设备安全不良事件
SELECT  '07' lb,a.bgks,a.zyh,a.hzxm,a.sjcs sjjg,a.sjfscbyyfx sjyy,a.sjcbclqg zgcs,NULL blsjdj,a.bgrq sjfsrq,'102' blsjlb  FROM  mpehr..TSF_Kyylqxblsjbg a 
WHERE  CONVERT(VARCHAR(10),a.bgrq,120) BETWEEN @startDate AND @endDate 
UNION all 
--药品不良反应事件
SELECT  '08' lb,a.ks,a.mzh zyh,a.hzxm,a.blms sjjg,null sjyy,null zgcs,NULL blsjdj,a.blfssj sjfsrq,'103' blsjlb  FROM  mpehr..TSF_ypblfybg_M a 
WHERE  CONVERT(VARCHAR(10),a.blfssj,120) BETWEEN @startDate AND @endDate 



--不良事件汇总表
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


