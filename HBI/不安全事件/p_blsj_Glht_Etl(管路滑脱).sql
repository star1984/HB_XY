USE [HBI_LZ]
GO
/****** Object:  StoredProcedure [dbo].[p_blsj_Glht_Etl]    Script Date: 06/30/2016 14:19:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[p_blsj_Glht_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
begin
--事实表
Delete from T_Glht where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Glht(biyear,biquarter,bimonth,biweek,bidate,fsks,dsrID)
select DATEPART(YY,bgrq) biyear,DATEPART(QQ,bgrq) biquarter,DATEPART(MM,bgrq) bimonth,DATEPART(WW,bgrq) biweek,
       CONVERT(varchar(10),bgrq,120) bidate,ks,dsr from MPEHR_HL..TSF_Glhtsb 
WHERE CONVERT(varchar(10),bgrq,120) between @startDate and @endDate
end
/*
	exec p_blsj_Glht_Etl '2015-01-01','2015-03-30'
	select * from TSF_Glhtsb 
	truncate table T_Glht 
	truncate table MPEHR_SZ..TSF_Glhtsb
	
*/
