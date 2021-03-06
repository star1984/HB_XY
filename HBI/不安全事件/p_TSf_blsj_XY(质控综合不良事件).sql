USE [HBI_hmi]
GO
/****** Object:  StoredProcedure [dbo].[p_TSf_blsj_XY]    Script Date: 07/03/2016 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[p_TSf_blsj_XY]
@startDate varchar(10),
@endDate varchar(10)
as
begin
--综合不良事件级别     
truncate table W_xyblsj_jb
Insert into W_xyblsj_jb(xh,dm,mc)
select ROW_NUMBER() over(order by WBCode) xh ,WBCode,WBName from MPEHR..TWordBook 
where WBTypeCode=100003

--综合不良事件大类     
truncate table W_xyblsj_dl
Insert into W_xyblsj_dl(xh,dm,mc)
select ROW_NUMBER() over(order by WBCode) xh ,WBCode,WBName from MPEHR..TWordBook 
where WBTypeCode=100007

--综合不良事件小类   
truncate table W_xyblsj_xl
Insert into W_xyblsj_xl(xh,dm,mc)
select ROW_NUMBER() over(order by WBCode) xh ,WBCode,WBName from MPEHR..TWordBook 
where WBTypeCode=100008

--综合不良事件发生场所   
truncate table W_xyblsj_fscs
Insert into W_xyblsj_fscs(xh,dm,mc)
select ROW_NUMBER() over(order by WBCode) xh ,WBCode,WBName from MPEHR..TWordBook 
where WBTypeCode=100001

--综合不良事件分管部门
truncate table W_xyblsj_fgbm
Insert into W_xyblsj_fgbm(xh,dm,mc)
select ROW_NUMBER() over(order by WBCode) xh ,WBCode,WBName from MPEHR..TWordBook 
where WBTypeCode=100009


--综合不良事件事实表  SELECT * FROM mpehr..TSf_blsj_XY   SELECT * FROM  MPEHR.dbo.T_shyj where gid='99BDA94C-6290-46D8-AD67-9DADFBE5E627'
Delete from T_zhblsj_xy where CONVERT(varchar(10),bidate,120) between @startDate and @endDate 

INSERT INTO [HBI_HMI].[dbo].[T_zhblsj_xy]
           ([biyear]
           ,[biquarter]
           ,[bimonth]
           ,[biweek]
           ,[bidate]
           ,[id]
           ,[zyh]
           ,[hzxm]
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
           ,[txsj]
           ,[sjjg]
           ,[sjyy]
           ,[gjcs])
SELECT DATEPART(YY,a.sjfsrq) biyear,DATEPART(QQ,a.sjfsrq) biquarter,DATEPART(MM,a.sjfsrq) biMonth,DATEPART(WW,a.sjfsrq) biweek,
       a.sjfsrq bidate,a.id,a.zyh,a.hzxm,a.sjfscs,a.xgks,a.blsjlb blsjjbdl,a.blsjlbxl,a.blsjdj,a.ks sbks,a.bgrqm,
       b.shsj, b.shr,b.shzt,a.fgbm,a.zyclr txr,a.clwcsj txsj,a.sjjg,a.dzsjdknyy,a.cxgjcs
FROM  mpehr..TSf_blsj_XY a LEFT JOIN  MPEHR.dbo.T_shyj b ON a.id=b.gid
WHERE CONVERT(VARCHAR(10),a.sjfsrq,120) BETWEEN @startDate AND @endDate 



end
/*
	exec p_TSf_blsj_XY '2016-01-01','2016-10-23'
	select * from T_zhblsj_xy
	select * from mpehr..TSf_blsj_XY   
	select * from T_Zysh
	

*/

--


