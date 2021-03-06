USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[p_Tshzdj_Etl]    Script Date: 06/30/2016 16:57:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[p_Tshzdj_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
begin
--事实表    4930712d-15e4-4b2e-bba3-1acbae3e33a7    
--患者类型维表 6b57adee-110a-4417-b43a-ac14a7a98bb6
TRUNCATE TABLE W_Tshzdj_hztype
INSERT INTO W_Tshzdj_hztype(xh,dm,mc)
select ROW_NUMBER() over(order by WBCode) xh ,WBCode,WBName from MPEHR..TWordBook 
where WBTypeCode=27571

                                     

Delete from T_Tshzdj where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Tshzdj(biyear,biquarter,bimonth,biweek,bidate,gid,hzxm,sex,nl,hztype,wctbdyg,shr,iscl)
select DATEPART(YY,a.wctbDate) biyear,DATEPART(QQ,a.wctbDate) biquarter,DATEPART(MM,a.wctbDate) bimonth,DATEPART(WW,a.wctbDate) biweek,
       CONVERT(varchar(10),a.wctbDate,120) bidate,a.pkid,a.hzname,CASE WHEN hzSex=1 THEN '男' 
                                                                       WHEN hzSex=2 THEN '女' ELSE NULL END,hzAge nl,
       a.hzType,a.wctbdyg,b.shr,CASE WHEN b.shzt=1 OR b.shzt=2 THEN 1 ELSE 0 END iscl 
                                                
from MPEHR..TSF_Tshzqkdj a LEFT JOIN   MPEHR.dbo.T_shyj b ON a.gid=b.gid
where CONVERT(varchar(10),a.wctbDate,120) between @startDate and @endDate 

end
/*
	exec p_Tshzdj_Etl '2016-09-01','2016-09-30'
	select * from T_Tshzd
*/
