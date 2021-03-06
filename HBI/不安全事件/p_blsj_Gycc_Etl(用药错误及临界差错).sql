USE [HBI_LZ]
GO
/****** Object:  StoredProcedure [dbo].[p_blsj_Gycc_Etl]    Script Date: 06/30/2016 15:03:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[p_blsj_Gycc_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
begin
--维表-工作年限
Truncate table W_Gycc_Gznx
Insert into W_Gycc_Gznx(xh,dm,mc)
Select WBCode,WBCode,WBName from MPEHR_HL.dbo.TWordBook where WBTypeCode=27562
--维表-药品字典
Truncate table W_Gycc_ypzd
Select Identity(int,1,1) xh,YPID,YPMC into #yp from MPEHR_HL.dbo.TWB_YPZD
Insert into W_Gycc_ypzd(xh,dm,mc)
select * from #yp
--维表-工作类别
Truncate table W_Gycc_Gzlb
Insert into W_Gycc_Gzlb(xh,dm,mc)
Select WBCode,WBCode,WBName from MPEHR_HL.dbo.TWordBook where WBTypeCode=27563 
--事实表
Delete from T_Gycc where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Gycc(biyear,biquarter,bimonth,biweek,bidate,dsrKs,dsrID,Gznx,Gzlb,ccypName)
select DATEPART(YY,sjfsDate) biyear,DATEPART(QQ,sjfsDate) biquarter,DATEPART(MM,sjfsDate) bimonth,DATEPART(WW,sjfsDate) biweek,
       CONVERT(varchar(10),sjfsDate,120) bidate,zrrSzks,zgys,Gznx,Gzlb,Case when ISNULL(ccypName,'')='' then null else ccypName End
 from MPEHR_HL..TSF_Gycc
Where CONVERT(varchar(10),sjfsDate,120) between @startDate and @endDate
end
/*
	exec p_blsj_Gycc_Etl '2015-01-01','2015-05-30'
	select * from T_Gycc
*/




   
