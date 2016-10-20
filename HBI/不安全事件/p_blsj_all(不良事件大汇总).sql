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
begin

--因为质控办要全部汇总，而分为不良事件综合报告表和各专题报告表，因此需要再次合并
--不良事件大类 :医疗、护理、院感、治安、后勤、信息    
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

SELECT a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,a.blsjlb,a.blsjlbxl,a.fgbm INTO #zhblsj FROM  mpehr..TSf_blsj_XY a INNER JOIN MPEHR.dbo.T_shyj b ON a.id=b.gid 
WHERE b.shzt=1  AND CONVERT(VARCHAR(10),a.sjfsrq,120) BETWEEN @startDate AND @endDate 


SELECT  '01' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy sjyy,a.cxgjcs zgcs,a.blsjdj,a.sjfsrq FROM  #zhblsj a 
WHERE a.fgbm IN ('01','03','04','09') 
UNION 
SELECT  '02' lb,a.ks,a.zyh,a.hzxm,a.sjjg,a.dzsjdknyy,a.cxgjcs,a.blsjdj,a.bidate FROM  T_blsjtj_hlb a
UNION 





--综合不良事件事实表  SELECT * FROM mpehr..TSf_blsj_XY   SELECT * FROM  MPEHR.dbo.T_shyj where gid='99BDA94C-6290-46D8-AD67-9DADFBE5E627'
Delete from T_zhblsj_xy where CONVERT(varchar(10),bidate,120) between @startDate and @endDate 

INSERT INTO [HBI_HMI].[dbo].[T_zhblsj_xy]
           ([biyear]
           ,[biquarter]
           ,[bimonth]
           ,[biweek]
           ,[bidate]
           ,[id]
           ,[sjfscs]
           ,[xgks]
           ,[blsjjbdl]
           ,[blsjjbxl]
           ,[blsjdj]
           ,[sbks]
           ,[bgrqm]
           ,[shsj]
           ,[shr]
           ,[shzt]
           ,[fgbm]
           ,[txr]
           ,[txsj])
SELECT DATEPART(YY,a.sjfsrq) biyear,DATEPART(QQ,a.sjfsrq) biquarter,DATEPART(MM,a.sjfsrq) biMonth,DATEPART(WW,a.sjfsrq) biweek,
       a.sjfsrq bidate,a.id,a.sjfscs,a.xgks,a.blsjlb blsjjbdl,a.blsjlbxl,a.blsjdj,a.ks sbks,a.bgrqm,
       b.shsj, b.shr,b.shzt,a.fgbm,a.zyclr txr,a.clwcsj txsj
FROM  mpehr..TSf_blsj_XY a LEFT JOIN  MPEHR.dbo.T_shyj b ON a.id=b.gid
WHERE CONVERT(VARCHAR(10),a.sjfsrq,120) BETWEEN @startDate AND @endDate AND b.shzt=1



end
/*
	exec p_TSf_blsj_XY '2016-01-01','2016-10-18'
	select * from W_czhj
	select * from T_zhblsj_xy   
	select * from T_Zysh
	

*/

--


