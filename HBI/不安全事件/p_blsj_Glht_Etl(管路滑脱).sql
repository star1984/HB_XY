USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[p_blsj_Glht_Etl]    Script Date: 06/30/2016 14:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[p_blsj_Glht_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
BEGIN 
--导管类型 
TRUNCATE TABLE W_dglx 
INSERT INTO W_dglx(xh,dm,mc)
SELECT ROW_NUMBER() OVER(ORDER BY wbcode) xh,WBCode,wbname FROM mpehr..TWordBook 
WHERE WBTypeCode=27044 

--处理
TRUNCATE TABLE W_glht_cl 
INSERT INTO W_glht_cl(xh,dm,mc)
SELECT ROW_NUMBER() OVER(ORDER BY wbcode) xh,WBCode,wbname FROM mpehr..TWordBook 
WHERE WBTypeCode=27047 

--脱管原因 
TRUNCATE TABLE W_tgyy
INSERT INTO W_tgyy(xh,dm,mc)
SELECT ROW_NUMBER() OVER(ORDER BY wbcode) xh,WBCode,wbname FROM mpehr..TWordBook 
WHERE WBTypeCode=27045 



--事实表  select * from  MPEHR..TSF_Glhtsb
Delete from T_Glhtsb where CONVERT(varchar(10),bidate,120) between @startDate and @endDate

Insert into T_Glhtsb(biyear,biquarter,bimonth,biweek,bidate,id,ks,dglx,chuli,tgyy)
select DATEPART(YY,bgrq) biyear,DATEPART(QQ,bgrq) biquarter,DATEPART(MM,bgrq) bimonth,DATEPART(WW,bgrq) biweek,
       CONVERT(varchar(10),bgrq,120) bidate,a.id,a.ks,a.dglx,a.cl,a.tgyy from MPEHR..TSF_Glhtsb a INNER JOIN MPEHR.dbo.T_shyj b ON a.id=b.gid 
WHERE b.shzt=1 and CONVERT(varchar(10),bgrq,120) between @startDate and @endDate 

end
/*
	exec p_blsj_Glht_Etl '2016-01-01','2016-10-10'
	select * from TSF_Glhtsb 
	truncate table T_Glht 
	truncate table MPEHR_SZ..TSF_Glhtsb
	
*/
