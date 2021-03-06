USE [HBIData]
GO
/****** Object:  StoredProcedure [dbo].[P_infoYFSFJL_ETL]    Script Date: 03/17/2015 19:52:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_infoYFSFJL_ETL]
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
  Declare @SQLText varchar(8000)
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)
  Select * into #Fy From infoYFSFJL Where 1=2
  Alter Table #Fy Add MZID varchar(50) -- 抽取门诊发药时需关联到门诊挂号记录因此增加此字段
   Alter Table #Fy Add yongfa varchar(50)  --医嘱用法
   
  --djdm  M 门诊；Z 住院
 Set @SQLText=
  'INSERT INTO #FY
           ([gid],[SFLB],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[djdm],[djmc],[fyrdm],[fyrxm],[fysj]
           ,[fylbdm],[fylbmc],[fysl],[ypdj],[ypje]
           ,[ypjj],[ypcb],[SFJLID],[YZID],[YZZXID]
           ,[yzdjh],[MZID],[sfxmdm],[sfxmmc],[yongfa])
Select * From OpenQuery(DQHIS, ''
  Select cast(a.OUT_BILL_CODE  as varchar(20))||''''_''''||cast(a.SERIAL_CODE as varchar(20)) gid, null SFLB, a.DRUG_DEPT_CODE yfdm,b.dept_name yfmc,
         case when a.OUT_TYPE like ''''M%'''' THEN A.GET_PERSON 
              WHEN a.OUT_TYPE like ''''Z%'''' THEN To_Char(A.GET_PERSON)||''''_''''||To_Char(1) else null end BRID, A.drug_code YPID, A.DRUG_STORAGE_CODE lybmdm, 
         c.dept_name lybmmc, case when a.OUT_TYPE like ''''M%'''' THEN ''''M'''' 
                                  when a.OUT_TYPE like ''''Z%'''' THEN ''''Z'''' else null end  djdm, null djmc,
         a.EXAM_OPERCODE fyrdm, d.empl_name fyrxm,A.EXAM_DATE fysj, null fylbdm,null fylbmc, A.out_num fysl,cast(a.sale_cost*1.0/A.out_num as decimal(18,2)) ypdj, A.sale_cost ypje,cast(A.APPROVE_COST*1.0/A.out_num as decimal(18,2)) ypjj, A.APPROVE_COST ypcb, null SFJLID,  
         case when a.OUT_TYPE like ''''M%'''' THEN f.MO_ORDER 
              WHEN a.OUT_TYPE like ''''Z%'''' THEN g.MO_ORDER else null end YZID,null YZZXID, a.recipe_no yzdjh,
         e.EMR_REGID MZID, A.drug_code sfxmdm, A.trade_name sfxmmc,null yongfa
    From dqhis.pha_com_output a left join dqhis.com_department b on a.DRUG_DEPT_CODE=b.dept_code 
                                left join dqhis.com_department c on a.DRUG_STORAGE_CODE=c.dept_code 
                                left join dqhis.com_employee d on  a.EXAM_OPERCODE=d.empl_code 
                                left join dqhis.fin_opr_register e on a.GET_PERSON=e.CLINIC_CODE and e.TRANS_TYPE = ''''1'''' AND e.VALID_FLAG = ''''1''''
                                left join dqhis.fin_opb_feedetail f on a.recipe_no=f.RECIPE_NO   and a.SEQUENCE_NO=f.SEQUENCE_NO
                                left join dqhis.fin_ipb_medicinelist g on a.recipe_no=g.RECIPE_NO   and a.SEQUENCE_NO=g.SEQUENCE_NO
    Where (a.OUT_TYPE like ''''M%'''' or a.OUT_TYPE like ''''Z%'''') and a.out_state>0 and 
           A.EXAM_DATE>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.EXAM_DATE<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''')
       '')'
  Exec (@SQLText)
  


--更新用法
  --更新门诊处方用法select top 1000 * from  infoMZCF where cfid='88336407'
  UPDATE a 
  SET yongfa=b.gyfsmc
  from #FY a, infoMZCF b
  WHERE a.yzid=b.cfid 
  
  --更新医嘱用法
  UPDATE a 
  SET yongfa=b.gyfsmc
  from #FY a, infoBryz b
  WHERE a.yzid=b.yzid
  
----数据清洗
--DELETE #FY   
--WHERE NOT EXISTS (SELECT 1 FROM infoMZCF a WHERE a.cfid=#FY.yzid )
  
/*
  -- 抽取收发记录truncate table  infoYFSFJL
  Delete infoYFSFJL
    Where Exists(Select 1 From #FY Where #FY.GID=infoYFSFJL.GID)
  
  INSERT INTO infoYFSFJL
           ([gid],[SFLB],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[djdm],[djmc],[fyrdm],[fyrxm],[fysj]
           ,[fylbdm],[fylbmc],[fysl],[ypdj],[ypje]
           ,[ypjj],[ypcb],[SFJLID],[YZID],[YZZXID]
           ,[yzdjh],[sfxmdm],[sfxmmc])
    Select [gid],[SFLB],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[djdm],[djmc],[fyrdm],[fyrxm],[fysj]
           ,[fylbdm],[fylbmc],[fysl],[ypdj],[ypje]
           ,[ypjj],[ypcb],[SFJLID],[YZID],[YZZXID]
           ,[yzdjh],[sfxmdm],[sfxmmc] From #FY
  Exec P_UpdateYSDM @StartDate, @EndDate, 'infoYFSFJL', 'fysj', 'fyrdm', 'fyrxm'
*/







  -- 抽取门诊发药记录truncate table infoMZYFFYJL
  Delete infoMZYFFYJL
    Where Exists(Select 1 From #FY Where #FY.GID=infoMZYFFYJL.GID AND djdm='M')

  INSERT INTO [infoMZYFFYJL]
           ([gid],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[fyrdm],[fyrxm],[fysj]
           ,[fysl],[ypdj],[ypje]
           ,[SFJLID],[YZID],[YZZXID]
           ,[MZID],[cfdjh],[yongfa])
    Select distinct [gid],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[fyrdm],[fyrxm],[fysj]
           ,[fysl],[ypdj],[ypje]
           ,[SFJLID],[YZID],[YZZXID]
           ,[MZID],[yzdjh],[yongfa] From #FY
      Where djdm='M'
  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoMZYFFYJL', 'fysj', 'fyrdm', 'fyrxm'

  -- 抽取住院发药记录truncate table infoZYYFFYJL
  Delete infoZYYFFYJL
    Where Exists(Select 1 From #FY Where #FY.GID=infoZYYFFYJL.GID AND djdm='Z')
  INSERT INTO infoZYYFFYJL
           ([gid],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[fyrdm],[fyrxm],[fysj]
           ,[fysl],[ypdj],[ypje],[ypjj],[ypcb]
           ,[SFJLID],[YZID],[YZZXID]
           ,[yzdjh],[yongfa])
    Select DISTINCT [gid],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[fyrdm],[fyrxm],[fysj]
           ,[fysl],[ypdj],[ypje],[ypjj],[ypcb]
           ,[SFJLID],[YZID],[YZZXID]
           ,[yzdjh],[yongfa] From #FY
      Where djdm='Z'
  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoZYYFFYJL', 'fysj', 'fyrdm', 'fyrxm'
  

End

/*
Exec P_infoYFSFJL_ETL '2016-05-01', '2016-05-31'
Exec P_infoYFSFJL_ETL '2016-07-05', '2016-07-05'
select top 1000 * from infoMZYFFYJL where gid='9768455_3'
drop table aa
*/

