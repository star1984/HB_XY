USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[p_Kyylqxblsjbg_Etl]    Script Date: 06/30/2016 16:57:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[p_Kyylqxblsjbg_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
begin


--select  * from mpehr..TSF_Qyxx
--SELECT * FROM mpehr..TSF_Kyylqxblsjbg  
--SELECT * FROM  MPEHR.dbo.T_shyj  WHERE gid='C5701AC1-1569-439F-80A5-8CE8FEC2A544'                                         
--可疑器械不良事件上报(临床)
Delete from T_Kyylqxblsjbg where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Kyylqxblsjbg(biyear,biquarter,bimonth,biweek,bidate,id,hzxm,bgks,shr)
select DATEPART(YY,a.bgrq) biyear,DATEPART(QQ,a.bgrq) biquarter,DATEPART(MM,a.bgrq) bimonth,DATEPART(WW,a.bgrq) biweek,
       CONVERT(varchar(10),a.bgrq,120) bidate,a.id,a.hzxm,a.bgks,a.shr                                              
from mpehr..TSF_Kyylqxblsjbg  a LEFT JOIN   MPEHR.dbo.T_shyj b ON a.id=b.gid
where CONVERT(varchar(10),a.bgrq,120) between @startDate and @endDate 

end
/*
	exec p_Kyylqxblsjbg_Etl '2016-09-01','2016-09-30'
	select * from T_Kyylqxblsjbg
*/
