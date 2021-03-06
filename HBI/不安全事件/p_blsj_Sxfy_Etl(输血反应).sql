USE [HBI_LZ]
GO
/****** Object:  StoredProcedure [dbo].[p_blsj_Sxfy_Etl]    Script Date: 06/30/2016 14:57:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[p_blsj_Sxfy_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
begin
Delete from T_Sxfy where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Sxfy(biyear,biquarter,bimonth,biweek,bidate,szks,dbzName)
select DATEPART(YY,fsDate) biyear,DATEPART(QQ,fsDate) biquarter,DATEPART(MM,fsDate) bimonth,DATEPART(WW,fsDate) biweek,
       CONVERT(varchar(10),fsDate,120) bidate,dbzDept,dbzName from MPEHR_HL..TSF_SxFy 
WHERE CONVERT(varchar(10),fsDate,120) between @startDate and @endDate
end
/*
	exec p_blsj_Sxfy_Etl '2015-01-01','2015-03-30'
	select * from TSF_SxFy
*/