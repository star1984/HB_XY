USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[p_Ywyljfsb_Etl]    Script Date: 06/30/2016 16:57:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[p_Ywyljfsb_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
begin
--事实表   E99C2305-AA31-48B4-B22B-5A93E02160ED    CB7A32B3-6D63-462B-B40B-AC912B50C0F6
--患者病情维表
TRUNCATE TABLE W_Ywyljfsb_hzbq
INSERT INTO W_Ywyljfsb_hzbq(xh,dm,mc)
select ROW_NUMBER() over(order by WBCode) xh ,WBCode,WBName from MPEHR..TWordBook 
where WBTypeCode=27591


--select * from  MPEHR..TSF_Ywyljfsb 
--SELECT * FROM  MPEHR.dbo.T_shyj  WHERE gid='CB7A32B3-6D63-462B-B40B-AC912B50C0F6'                                         

Delete from T_Ywyljfsb where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Ywyljfsb(biyear,biquarter,bimonth,biweek,bidate,gid,hzxm,sex,nl,hzjbqk,ylzyqk,bqpg_hzks,bqpg_bq,wctbdyg,shr,iscl)
select DATEPART(YY,a.wctbDate) biyear,DATEPART(QQ,a.wctbDate) biquarter,DATEPART(MM,a.wctbDate) bimonth,DATEPART(WW,a.wctbDate) biweek,
       CONVERT(varchar(10),a.wctbDate,120) bidate,a.pkid,a.hzname,CASE WHEN hzSex=1 THEN '男' 
                                                                       WHEN hzSex=2 THEN '女' ELSE NULL END,hzAge nl,
       a.hzjbqk,a.ylzyqk,a.bqpg_hzks,bqpg_bq,wctbdyg,b.shr,CASE WHEN b.shzt=1 OR b.shzt=2 THEN 1 ELSE 0 END iscl 
                                                
from MPEHR..TSF_Ywyljfsb a LEFT JOIN   MPEHR.dbo.T_shyj b ON a.gid=b.gid
where CONVERT(varchar(10),a.wctbDate,120) between @startDate and @endDate 

end
/*
	exec p_Ywyljfsb_Etl '2016-09-01','2016-09-30'
	select * from T_Ywyljfsb
*/
