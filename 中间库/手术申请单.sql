USE [hbidata]
GO
/****** Object:  StoredProcedure [dbo].[P_infoBrsssqd_ETL]    Script Date: 11/05/2015 10:47:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_infoBrsssqd_ETL]
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
  Declare @SQLText varchar(8000)
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)

CREATE TABLE #ss (
	[SQID] [varchar](50) NOT NULL,
	[BRID] [varchar](50) NULL,
	[bah] [varchar](50) NULL,
	[zyh] [varchar](50) NULL,
	[zycs] [int] NULL,
	[ssxh] [int] NULL,
	[ssrq] [datetime] NULL,
	[kssj] [datetime] NULL,
	[jssj] [datetime] NULL,
	[jxsj] [int] NULL,
	[ssICCM] [varchar](20) NULL,
	[ssmc] [varchar](200) NULL,
	[ssysdm] [varchar](30) NULL,
	[ssysxm] [varchar](130) NULL,
	[yzdm] [varchar](30) NULL,
	[yzxm] [varchar](30) NULL,
	[ezdm] [varchar](30) NULL,
	[ezxm] [varchar](30) NULL,
	[mzysdm] [varchar](30) NULL,
	[mzysxm] [varchar](130) NULL,
	[mzfsdm] [varchar](100) NULL,
	[mzfsmc] [varchar](100) NULL,
	[ASAFJ] [varchar](30) NULL,
	[NNISFJ] [varchar](30) NULL,
	[szkss] [varchar](500) NULL,
	[iszlw] [int] NULL,
	[isjz] [int] NULL,
	[qkdj] [varchar](10) NULL,
	[yhqk] [varchar](10) NULL,
	[ssksdm] [varchar](30) NULL,
	[ssksmc] [varchar](50) NULL,
	[cwdm] [varchar](30) NULL,
	[cwmc] [varchar](30) NULL,
	[ryrq] [datetime] NULL )

/*
有手术名称
  Set @SQLText=
  'INSERT INTO #ss
           ([SQID],[BRID],[bah]
           ,[zyh],[zycs],[ryrq]
           ,[ssxh],[ssrq],[ssmc]
           ,ssysdm,[ssysxm],[mzysxm],[mzfsmc]
           ,[ssksdm],[ssksmc]
           ,[kssj],[jssj],[ASAFJ])
  Select * From OpenQuery(dqhis, ''
    Select a.OPERATIONNO sqid, cast(a.CLINIC_CODE as varchar(12))||''''_''''||cast(1 as varchar(10)) BRID, a.PATIENT_NO  bah, a.CLINIC_CODE zyh, 1 zycs,b.IN_DATE ryrq,
           null ssxh, case when to_char(a.appr_date,''''yyyy-mm-dd'''')<>''''0001-01-01'''' then a.appr_date else null end ssrq,
           c.item_name ssmc,
           a.ops_docd ssysdm, d.empl_name ssysxm, null mzysxm,null mzfsmc, a.dept_code ssksdm, e.dept_name  ssksmc, 
           null kssj, null jssj,null ASAFJ
    From dqhis.met_ops_apply a  left join  dqhis.fin_ipr_inmaininfo b on a.CLINIC_CODE=b.INPATIENT_NO 
                                left join  dqhis.met_ops_operationitem c on a.operationno=c.operationno AND c.ROWNUM=1   
                                left join  dqhis.com_employee d on  a.ops_docd=d.empl_code   
                                left join  dqhis.com_department e on a.dept_code=e.dept_code    
    Where  a.APPLY_DATE+0>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and a.APPLY_DATE+0<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''') 
           and a.YNVALID=1 and a.EXECSTATUS not in (5,6)  '')'
-- print (@SQLText)
  Exec (@SQLText)

*/

--无手术名称
  Set @SQLText=
  'INSERT INTO #ss
           ([SQID],[BRID],[bah]
           ,[zyh],[zycs],[ryrq]
           ,[ssxh],[ssrq],[ssmc]
           ,ssysdm,[ssysxm],[mzysxm],[mzfsmc]
           ,[ssksdm],[ssksmc]
           ,[kssj],[jssj],[ASAFJ])
  Select * From OpenQuery(dqhis, ''
    Select a.OPERATIONNO sqid, cast(a.CLINIC_CODE as varchar(12))||''''_''''||cast(1 as varchar(10)) BRID, a.PATIENT_NO  bah, a.CLINIC_CODE zyh, 1 zycs,b.IN_DATE ryrq,
           null ssxh,case when to_char(a.appr_date,''''yyyy-mm-dd'''')<>''''0001-01-01'''' then a.appr_date else null end ssrq,
           null ssmc,
           a.ops_docd ssysdm, d.empl_name ssysxm, null mzysxm,null mzfsmc, a.dept_code ssksdm, e.dept_name  ssksmc, 
           null kssj, null jssj,null ASAFJ
    From dqhis.met_ops_apply a  left join  dqhis.fin_ipr_inmaininfo b on a.CLINIC_CODE=b.INPATIENT_NO  
                                left join  dqhis.com_employee d on  a.ops_docd=d.empl_code   
                                left join  dqhis.com_department e on a.dept_code=e.dept_code    
    Where  a.APPLY_DATE>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and a.APPLY_DATE<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''') 
           and a.YNVALID=1 and a.EXECSTATUS not in (5,6)  '')'
-- print (@SQLText)
  exec (@SQLText)

  
  
  
  /*
 --根据手术医生姓名更新手术医生代码(工号)
 update #ss
 set ssysdm=a.gh
 from WB_Doctor a
 where #ss.ssysxm=a.tname

  -- 更新进行时间
  Update #ss
    Set jxsj=sj From(Select SQID GID, DateDiff(mi, kssj, jssj) sj From #ss
                       Where kssj is not Null and jssj Is not Null) T
    Where GID=SQID
  ---- 更新是否急诊手术
  --Update #ss
  --  Set isjz=(Case When (kssj-ryrq)>=0 and (kssj-ryrq)<=1 Then 1 Else 0 End)
*/


  Delete infoBrsssqd
    Where Exists (Select 1 From #ss Where infoBrsssqd.sqid=#ss.sqid)



  Insert infoBrsssqd 
      ([SQID],[BRID],[bah]
           ,[zyh],[zycs]
           ,[ssxh],[ssrq],[ssmc]
           ,[ssysdm],[ssysxm],[mzysxm],[mzfsmc]
           ,[ssksdm],[ssksmc],[kssj]
           ,[jssj],[jxsj],[isjz]
           ,ASAFJ,NNISFJ,qkdj,yhqk)
    Select [SQID],[BRID],[bah]
           ,[zyh],[zycs]
           ,[ssxh],[ssrq],[ssmc]
           ,[ssysdm],[ssysxm],[mzysxm],[mzfsmc]
           ,[ssksdm],[ssksmc],[kssj]
           ,[jssj],[jxsj],[isjz]
           ,ASAFJ,NNISFJ,qkdj,yhqk
      From #ss

  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoBrsssqd', 'ssrq', 'ssysdm', 'ssysxm'
  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoBrsssqd', 'ssrq', 'mzysdm', 'mzysxm'
End

/*
Exec P_infoBrsssqd_ETL '2016-05-01', '2016-06-30'
Select * From infoBrsssqd  Where ASAFJ IS NOT NULL
truncate table infoBrsssqd
*/

