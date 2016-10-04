USE [HBI_NOSAFE]
GO
/****** Object:  StoredProcedure [dbo].[p_blsj_zybl_Etl]    Script Date: 07/03/2016 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[p_blsj_zybl_Etl]
@startDate varchar(10),
@endDate varchar(10)
as
begin
--工作类别维表
truncate table W_gzlb
   Insert into W_gzlb(xh,dm,mc)
   select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook 
    where WBTypeCode=27520
--暴露伤地点维表
Truncate table W_blsdd
  Insert into W_blsdd(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook 
   where WBTypeCode=27521
--锐器物种类维表
Truncate table W_rqwzl
  Insert into W_rqwzl(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook 
   where WBTypeCode=27522
--操作环节维表
Truncate table W_czhj
  Insert into W_czhj(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook 
   where WBTypeCode=27518
--患者病情维表
Truncate table W_hzbq
  Insert into W_hzbq(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook 
   where WBTypeCode=27527
--暴露后紧急处理-皮肤维表
Truncate table W_blhjjcl
  Insert into W_blhjjcl(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook 
   where WBTypeCode=27528
--暴露后紧急处理-粘膜维表
Truncate table W_blhjjcl_nm
  Insert into W_blhjjcl_nm(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook 
   where WBTypeCode=27529
--是否戴手套维表
Truncate table W_isdst
  Insert into W_isdst(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook 
   where WBTypeCode=27530
--是否用药维表
Truncate table W_isyy
  Insert into W_isyy(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook 
   where WBTypeCode=27532
--暴露前是否接种乙肝疫苗维表  
Truncate table W_isjzygym
  Insert into W_isjzygym(xh,dm,mc)
  Select ROW_NUMBER() over(order by WBCode) xh,WBCode,WBName from MPEHR_HL..TWordBook 
   where WBTypeCode=27517
--职业暴露事实表  select * from T_Zysh
Delete from T_Zysh where CONVERT(varchar(10),bidate,120) between @startDate and @endDate
Insert into T_Zysh(biyear,biquarter,bimonth,biweek,bidate,ksCode,ryName,gzlb,gznx,rySex,blsdd,rqwzl,czhj,
                   hzbq,blfcl_pf,blhcl_nm,isdst,isyy,blqsfjzygym)
Select DATEPART(YY,blssj) biyear,DATEPART(QQ,blssj) biquarter,DATEPART(MM,blssj)biMonth,DATEPART(WW,blssj) biweek,
       CONVERT(varchar(10),blssj,120) bidate,ryDept,ryName,gzlb,case when ryGznx<5 then 1 
                                                                     when ryGznx>=5 and ryGznx<=10 then 2 
                                                                     when ryGznx>10 then 3 else 1 End ryGznx,
       rySex,blsfsdd,dzbldrqwzl,blfssczhj,
       hzbq,blhjjcl_pf,blhjjcl_nmcx,rqctl_s,isyfxyy,blqsfjzygym from MPEHR_HL..TSF_Zybl
 Where CONVERT(varchar(10),blssj,120) between @startDate and @endDate
end
/*
	exec p_blsj_zybl_Etl '2015-01-01','2015-03-12'
	select * from W_czhj
	select * from MPEHR_HL..TSF_Zybl   
	select * from T_Zysh
	

*/

--


