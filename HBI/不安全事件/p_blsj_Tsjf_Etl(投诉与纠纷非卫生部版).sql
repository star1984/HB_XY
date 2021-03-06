USE [HBI_LZ]
GO
/****** Object:  StoredProcedure [dbo].[p_blsj_Tsjf_Etl]    Script Date: 06/30/2016 15:10:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[p_blsj_Tsjf_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
Begin
--医生职务维表select * from W_tsjfzw
Truncate table W_tsjfzw
  Insert into W_tsjfzw(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode)xh,WBCode,WBName from MPEHR_HL..TWordBook
   Where WBTypeCode=27040
--投诉纠纷地点维表 select * from W_tsjfdd
Truncate table W_tsjfdd
  Insert into W_tsjfdd
  Select ROW_NUMBER() over(order by WBCode)xh,WBCode,WBName from MPEHR_HL..TWordBook
   Where WBTypeCode=27039
--投诉纠纷对患者的伤害程度select * from W_dhzshcd
Truncate table W_dhzshcd
  Insert into W_dhzshcd
  Select ROW_NUMBER() over(order by WBCode)xh,WBCode,WBName from MPEHR_sz..TWordBook
   Where WBTypeCode=27018
--医德医风投诉登记表-科室处理结果 select * from W_tsjfcljg
Truncate table W_tsjfcljg
  Insert into W_tsjfcljg
  Select ROW_NUMBER() over(order by WBCode)xh,WBCode,WBName from MPEHR_sz..TWordBook
   Where WBTypeCode=27020
--纠纷处理情况及分析-纠纷处理结果 select * from W_tsjfJjjg
Truncate table W_tsjfJjjg
  Insert into W_tsjfJjjg
  Select ROW_NUMBER() over(order by WBCode)xh,WBCode,WBName from MPEHR_HL..TWordBook
   Where WBTypeCode=27068

--投诉纠纷一览表select * from T_Tsjf  drop table T_Tsjf
Delete from T_Tsjf where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Tsjf(biyear,biquarter,bimonth,biweek,bidate,tsks,tsys,yszw,fsdd,dhzshcd,cljg,fxjjjc,ksType)
Select DATEPART(YY,sjfsrq) biyear,DATEPART(QQ,sjfsrq) biquarter,DATEPART(MM,sjfsrq) bimonth,DATEPART(WW,sjfsrq) biweek,
       CONVERT(varchar(10),sjfsrq,120) bidate,sjbm,a.xm,zyzl,a.sjfsdd,case when sjfsshzzk_y=1 then ISNULL(ysh,6) else 0 End 'dhzshcd',
       sjcljg,1 fxjjjc,b.ksType from MPEHR_HL..TSF_Tsjf a 
 Inner join 同煤科室维表 b on a.sjbm=b.代码
 Where CONVERT(varchar(10),sjfsrq,120) between @startDate and @endDate
End

/*
	exec p_blsj_Tsjf_Etl '2015-01-01','2015-03-30' 
	select sjfsshzzk_y,* from MPEHR_sz..TSF_Tsjf 
	
*/