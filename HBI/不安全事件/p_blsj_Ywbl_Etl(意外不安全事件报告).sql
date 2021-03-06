USE [HBI_LZ]
GO
/****** Object:  StoredProcedure [dbo].[p_blsj_Ywbl_Etl]    Script Date: 07/03/2016 10:49:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[p_blsj_Ywbl_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
begin
--事件类别维表
Truncate table W_sjType
  Insert into W_sjType(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,SUBSTRING(a.WBName,0,charindex('－',a.WBName)) from MPEHR_HL..TWordBook a
  where WBTypeCode=28008
--对患者健康的影响程度维表
Truncate table W_dhzyxcd
  Insert into W_dhzyxcd(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,SUBSTRING(a.WBName,0,charindex('－',a.WBName)) from MPEHR_HL..TWordBook a
  Where WBTypeCode=28039
--预防措施
Truncate table W_yfcs
  Insert into W_yfcs(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook a
  Where WBTypeCode=28053
--发生可能原因的意外
Truncate table W_knfsyy
  Insert into W_knfsyy
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook a
  Where WBTypeCode=28054
--事实表
Delete from T_Ywbl where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Ywbl(biyear,biquarter,bimonth,biweek,bidate,dhzdyxcd,sjType,yfcs,knyy)
select DATEPART(YY,sjfsrq) biyear,DATEPART(QQ,sjfsrq) biquarter,DATEPART(MM,sjfsrq) bimonth,DATEPART(WW,sjfsrq) biweek,
       CONVERT(varchar(10),sjfsrq,120) bidate,hzyxcd,sjlb,yfff,knyy from MPEHR_HL..TSF_Blsjsb_ywblsjbg 
WHERE CONVERT(varchar(10),sjfsrq,120) between @startDate and @endDate
end
/*
	exec p_blsj_Ywbl_Etl '2015-01-01','2015-03-30'
	select * from T_Ywbl
*/

