USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[K_ETL_Nyjg]    Script Date: 06/09/2015 17:17:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER ProceDure [dbo].[K_ETL_Nyjg]  
 @StartDate varchar(10),
 @EndDate Varchar(10)
as 
Begin
  Delete K_xjny Where bidate between @StartDate And @EndDate
  Insert into K_xjny
  Select DATEPART(yy,a.sjrq) biyear,DATEPART(qq,a.sjrq) biquarter,DATEPART(mm,a.sjrq) bimonth,DATEPART(qq,a.sjrq) biweek,convert(varchar(10),a.sjrq,120) bidate,
	     a.brid,--病历号
	     a.bbmc,--标本名称
	     a.sjksdm,--送检科室代码
	     a.sjksmc,--送检科室名称
	     c.bytmc jyjg,--病原体名称
	     c.kssmc ymjg,--抗生素名称
	     Case When nyjg=1 Then '耐药' When nyjg=2 Then '中介' Else '敏感' End  nyjg,--抗生素名称
	     a.jyid
    from HBIData..infoJyjbxx a 
   Inner join hbidata..infoJyjg b on a.JYID=b.JYID
   inner join HBIData..infoYmjg c on c.JGID=b.JGID
   Where convert(varchar(10),a.sjrq,120) between @StartDate And @EndDate 
    
End
