
/****** Object:  StoredProcedure [dbo].[p_blsj_Yxcw_Etl]    Script Date: 07/03/2016 11:10:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[p_blsj_Yxcw_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
begin
Delete from T_Yxcw where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Yxcw(biyear,biquarter,bimonth,biweek,bidate,sbzkscode,zbzys)
select DATEPART(YY,sjfssj) biyear,DATEPART(QQ,sjfssj) biquarter,DATEPART(MM,sjfssj) bimonth,DATEPART(WW,sjfssj) biweek,
       CONVERT(varchar(10),sjfssj,120) bidate,sbzbm,sbzxm from MPEHR_HL..TSF_Yxcw 
WHERE CONVERT(varchar(10),sjfssj,120) between @startDate and @endDate
end
/*
	exec p_blsj_Yxcw_Etl '2015-01-01','2015-03-30'
	select * from T_Yxcw
*/