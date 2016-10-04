USE [HBI_LZ]
GO
/****** Object:  StoredProcedure [dbo].[p_blsj_Yscc_Etl]    Script Date: 06/30/2016 16:57:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[p_blsj_Yscc_Etl]
@startDate varchar(10),

@endDate varchar(10)
as
begin
--事实表
Delete from T_Yscc where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Yscc(biyear,biquarter,bimonth,biweek,bidate,dsrKs,dsrID)
select DATEPART(YY,FsDate) biyear,DATEPART(QQ,FsDate) biquarter,DATEPART(MM,FsDate) bimonth,DATEPART(WW,FsDate) biweek,
       CONVERT(varchar(10),FsDate,120) bidate,DsrDept,DsrName from MPEHR_HL..TSF_Yscc 
where CONVERT(varchar(10),FsDate,120) between @startDate and @endDate

end
/*
	exec p_blsj_Yscc_Etl '2015-01-01','2015-03-30'
	select * from T_Yscc
*/
