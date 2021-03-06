USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[p_blsjtj_hlb]    Script Date: 10/18/2016 19:59:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[p_blsjtj_hlb]
@startDate varchar(10),
@endDate varchar(10)
as
begin
  
--护理部不良事件类别维表
SELECT '001' dm,'给药错误' mc INTO #W_hlb_blsjlb
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
union all 
SELECT '50' dm,'其他' mc  


--mpehr科室科目维表
TRUNCATE TABLE W_mpehr_km 
INSERT INTO W_mpehr_km(xh,dm,mc) 
SELECT ROW_NUMBER() OVER(ORDER BY wbcode) xh,wbcode,wbname FROM mpehr..TWordBook
WHERE WBTypeCode=62

TRUNCATE TABLE W_hlb_blsjlb
INSERT INTO W_hlb_blsjlb(xh,dm,mc)
SELECT  ROW_NUMBER() over(order by dm) xh ,dm,mc FROM #W_hlb_blsjlb


SELECT a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,a.blsjlb,a.blsjlbxl,a.fgbm INTO #hlblsj FROM  mpehr..TSf_blsj_XY a INNER JOIN MPEHR.dbo.T_shyj b ON a.id=b.gid 
WHERE b.shzt=1 AND a.fgbm='02' AND CONVERT(VARCHAR(10),a.sjfsrq,120) BETWEEN @startDate AND @endDate 



--给药错误001
SELECT CASE WHEN  a.blsjlb='02' OR (a.blsjlb='03' AND a.blsjlbxl IN ('0301','0302','0303','0304','0305')) OR (a.blsjlb='04' AND  a.blsjlbxl IN ('0403','0404')) THEN '001' ELSE '0000' END lb,a.blsjlbxl,
       a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
into #hlblsj_fl
from  #hlblsj a  
union all 
--脱管事件002  select *  from  mpehr..TSF_Glhtsb 
SELECT '002' lb,NULL blsjlbxl,
       a.id,a.ks,a.blh zyh,a.hzxm,a.fssj sjfsrq,a.glhtms sjjg,a.bgr bgrqm,a.yyfx dzsjdknyy,a.zgclyj cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
from  MPEHR..TSF_Glhtsb a  INNER JOIN MPEHR.dbo.T_shyj b ON a.id=b.gid 
WHERE b.shzt=1  AND CONVERT(VARCHAR(10),a.fssj,120) BETWEEN @startDate AND @endDate 
union all 
--标本事件003
SELECT CASE WHEN  a.blsjlb='08' AND a.blsjlbxl IN ('0802','0803') THEN '003' ELSE '0000' END  lb,a.blsjlbxl,
       a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
from  #hlblsj a  
union all 
--信息传递错误004
SELECT CASE WHEN  a.blsjlb='01' AND a.blsjlbxl='0102' THEN '004' ELSE '0000' END  lb,a.blsjlbxl,
       a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
from  #hlblsj a 
union all  
--输血事件005
SELECT CASE WHEN  a.blsjlb='05' AND a.blsjlbxl IN ('0501','0502','0504') THEN '005' ELSE '0000' END  lb,a.blsjlbxl,
       a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
from  #hlblsj a  
union all 
--基础护理事件006
SELECT CASE WHEN  a.blsjlb='09'  THEN '006' ELSE '0000' END  lb,a.blsjlbxl,
       a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
from  #hlblsj a  
union all 
--饮食事件007 
SELECT CASE WHEN  a.blsjlb='10'  THEN '007' ELSE '0000' END  lb,a.blsjlbxl,
       a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
from  #hlblsj a  
union all 
--不作为事件008 
SELECT CASE WHEN  a.blsjlb='17'  THEN '008' ELSE '0000' END  lb,a.blsjlbxl,
       a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
from  #hlblsj a  
union all 
--压疮009 SELECT * from  MPEHR.dbo.THL_YCSB_M   
SELECT  '009' lb,NULL blsjlbxl,
      a.gid,a.bgks ks,LEFT(a.brbh,14) zyh,c.hzxm,a.sbsj sjfsrq,a.sqjg sjjg,a.hsqm bgrqm,a.yyfx dzsjdknyy,a.zgcs cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
FROM MPEHR.dbo.THL_YCSB_M a INNER JOIN MPEHR.dbo.T_shyj b ON a.gid=b.gid 
                            left JOIN mpehr..THzxxb c ON a.brbh=c.brbh
WHERE b.shzt=1 AND CONVERT(VARCHAR(10),sbsj,120) BETWEEN @startDate AND @endDate AND a.ycly='4'
union all 
--跌倒010   襄阳人民医院 发生地点为 外出 的，不作统计  010 select * from  MPEHR.dbo.THL_ddzcbg
SELECT  '010' lb,NULL blsjlbxl,
      a.gid,a.sbks ks,LEFT(a.brbh,14) zyh,c.hzxm,a.fssj sjfsrq,a.ddsqxms sjjg,a.hsz bgrqm,a.yyfx dzsjdknyy,a.zgcs cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
FROM MPEHR.dbo.THL_ddzcbg a INNER JOIN MPEHR.dbo.T_shyj b ON a.gid=b.gid 
                            left JOIN mpehr..THzxxb c ON a.brbh=c.brbh 
                            left join mpehr..TWordBook d  on  a.ddyy=d.WBCode and  WBTypeCode=12052
WHERE b.shzt=1 AND CONVERT(VARCHAR(10),a.fssj,120) BETWEEN @startDate AND @endDate and   a.fsdd<>'6' and (DDORZZ='1' or ISNULL(DDORZZ,'')='')
union all 
--坠床011   襄阳人民医院 发生地点为 外出 的，不作统计  010 select * from  MPEHR.dbo.THL_ddzcbg
SELECT  '011' lb,NULL blsjlbxl,
      a.gid,a.sbks ks,LEFT(a.brbh,14) zyh,c.hzxm,a.fssj sjfsrq,a.ddsqxms sjjg,a.hsz bgrqm,d.WBName dzsjdknyy,a.hlcs cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
FROM MPEHR.dbo.THL_ddzcbg a INNER JOIN MPEHR.dbo.T_shyj b ON a.gid=b.gid 
                            left JOIN mpehr..THzxxb c ON a.brbh=c.brbh 
                            left join mpehr..TWordBook d  on  a.ddyy=d.WBCode and  WBTypeCode=12052
WHERE b.shzt=1 AND CONVERT(VARCHAR(10),a.fssj,120) BETWEEN @startDate AND @endDate and   a.fsdd<>'6' and DDORZZ='2'  
union all 
--输液反应012 select top 1000 * from mpehr..THL_JMZLBLFYSB 
SELECT  '012' lb,NULL blsjlbxl,
      a.gid,a.sbks ks,LEFT(a.brbh,14) zyh,c.hzxm,a.fssj sjfsrq,a.sqjg sjjg,a.sbr bgrqm,a.yyfx dzsjdknyy,a.zgcs cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
FROM MPEHR.dbo.THL_JMZLBLFYSB a INNER JOIN MPEHR.dbo.T_shyj b ON a.gid=b.gid 
                                left JOIN mpehr..THzxxb c ON a.brbh=c.brbh                                 
WHERE b.shzt=1 AND CONVERT(VARCHAR(10),a.fssj,120) BETWEEN @startDate AND @endDate and a.sjlb='1'
union all 
--深静脉血栓 013
SELECT  '013' lb,NULL blsjlbxl,
      a.gid,a.sbks ks,LEFT(a.brbh,14) zyh,c.hzxm,a.fssj sjfsrq,a.sqjg sjjg,a.sbr bgrqm,a.yyfx dzsjdknyy,a.zgcs cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
FROM MPEHR.dbo.THL_JMZLBLFYSB a INNER JOIN MPEHR.dbo.T_shyj b ON a.gid=b.gid 
                                left JOIN mpehr..THzxxb c ON a.brbh=c.brbh                                 
WHERE b.shzt=1 AND CONVERT(VARCHAR(10),a.fssj,120) BETWEEN @startDate AND @endDate and a.sjlb='2'
union all 
--外渗 014
SELECT  '014' lb,NULL blsjlbxl,
      a.gid,a.sbks ks,LEFT(a.brbh,14) zyh,c.hzxm,a.fssj sjfsrq,a.sqjg sjjg,a.sbr bgrqm,a.yyfx dzsjdknyy,a.zgcs cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
FROM MPEHR.dbo.THL_JMZLBLFYSB a INNER JOIN MPEHR.dbo.T_shyj b ON a.gid=b.gid 
                                left JOIN mpehr..THzxxb c ON a.brbh=c.brbh                                 
WHERE b.shzt=1 AND CONVERT(VARCHAR(10),a.fssj,120) BETWEEN @startDate AND @endDate and a.sjlb='3'
union all 
--渗出 015
SELECT  '015' lb,NULL blsjlbxl,
      a.gid,a.sbks ks,LEFT(a.brbh,14) zyh,c.hzxm,a.fssj sjfsrq,a.sqjg sjjg,a.sbr bgrqm,a.yyfx dzsjdknyy,a.zgcs cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
FROM MPEHR.dbo.THL_JMZLBLFYSB a INNER JOIN MPEHR.dbo.T_shyj b ON a.gid=b.gid 
                                left JOIN mpehr..THzxxb c ON a.brbh=c.brbh                                 
WHERE b.shzt=1 AND CONVERT(VARCHAR(10),a.fssj,120) BETWEEN @startDate AND @endDate and a.sjlb='4'
union all 
--其它事件050
SELECT CASE WHEN  a.blsjlb='50'  THEN '50' ELSE '0000' END  lb,a.blsjlbxl,
       a.id,a.ks,a.zyh,a.hzxm,a.sjfsrq,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,CAST(NULL AS VARCHAR(20)) ksfl
from  #hlblsj a  

DELETE FROM #hlblsj_fl WHERE lb='0000'

/*工作班别规则
白班：08:00-12:00,14:30-17:30
中班：17:30-23:00
夜班：23:00-08:00
中午：12:00-14:30
*/
truncate table w_banbie
INSERT INTO w_banbie
SELECT 1 xh,'01' dm,'白班' mc 
UNION 
SELECT 2 xh,'02' dm,'中班' mc 
UNION 
SELECT 3 xh,'03' dm,'夜班' mc 
UNION 
SELECT 4 xh,'04' dm,'中午' mc 




--更新科室分类 按照MPEHR科室字典的“专业” 与 tworkbook.wbtypecode=62 对应 
UPDATE  a 
SET ksfl=b.WBCode
FROM #hlblsj_fl a,mpehr..TUseKs b 
WHERE a.ks=b.KsCode 



                                    

Delete from T_blsjtj_hlb where CONVERT(varchar(10),bidate,120) between @startDate and @endDate


INSERT INTO [HBI_HMI].[dbo].[T_blsjtj_hlb]
           ([biyear]
           ,[biquarter]
           ,[bimonth]
           ,[biweek]
           ,[bidate]
           ,[lb]
           ,[id]
           ,[ks]
           ,[zyh]
           ,[hzxm]
           ,[sjjg]
           ,[bgr]
           ,[dzsjdknyy]
           ,[cxgjcs]
           ,[blsjdj]
           ,[ndjd]
           ,[ksfl])
select DATEPART(YY,a.sjfsrq) biyear,DATEPART(QQ,a.sjfsrq) biquarter,DATEPART(MM,a.sjfsrq) biMonth,DATEPART(WW,a.sjfsrq) biweek,
       a.sjfsrq bidate,a.lb,a.id,a.ks,a.zyh,a.hzxm,a.sjjg,a.bgrqm,a.dzsjdknyy,a.cxgjcs,a.blsjdj,ltrim(DATEPART(YY,a.sjfsrq))+'第'+ltrim(DATEPART(QQ,a.sjfsrq))+'季度',a.ksfl
from #hlblsj_fl  a         

--更新班别 
UPDATE T_blsjtj_hlb 
SET banbie=CASE WHEN (CONVERT(VARCHAR(20),bidate, 114) >= CAST('08:00' AS time) AND CONVERT(VARCHAR(20),bidate, 114)< CAST('12:00' AS time)) OR (CONVERT(VARCHAR(20),bidate, 114) >= CAST('14:30' AS time) AND CONVERT(VARCHAR(20),bidate, 114)<CAST('17:30' AS time)) THEN '01' 
                WHEN  CONVERT(VARCHAR(20),bidate, 114) >= CAST('17:30' AS time) AND CONVERT(VARCHAR(20),bidate, 114)< CAST('23:00' AS time) THEN '02' 
                WHEN  CONVERT(VARCHAR(20),bidate, 114) >= CAST('23:00' AS time) AND CONVERT(VARCHAR(20),bidate, 114)< CAST('08:00' AS time) THEN '03' 
                WHEN  CONVERT(VARCHAR(20),bidate, 114) >= CAST('12:00' AS time) AND CONVERT(VARCHAR(20),bidate, 114)< CAST('14:30' AS time) THEN '04'  ELSE NULL end
                
           

end
/*
	exec p_blsjtj_hlb '2016-01-01','2016-10-23'
	select * from T_blsjtj_hlb
	

	
*/
