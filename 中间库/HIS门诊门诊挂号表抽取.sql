/*
 功能 读取HIS住院病人收费表 按收费时间范围读取
 作者 ZMJ
 日期 2013-10-31
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_infoMZGH_ETL' AND type = 'P')
   DROP PROCEDURE P_infoMZGH_ETL
GO

Create PROCEDURE P_infoMZGH_ETL
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
  Declare @SQLText varchar(8000)
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)
  
  Select * into #infoMZGH From infoMZGH Where 1=2

  Set @SQLText=
  'INSERT INTO #infoMZGH
           ([GID],[BRID],[mzh]
           ,[IsJZ],[IsFZ]
           ,[IsYY],[ghlb]
           ,[hzxm],[hzxb]
           ,[csrq],[Hznl]
           ,[Nldw],[ghksdm]
           ,[ghksmc],[ghsj]
           ,[ghysdm],[ghysxm]
           ,[tel],[lxr_xm]
           ,[lxr_tel], [ybh],[tz],[sfzhm],[mzzd_ICD],[mzzd_mc],[zxzt],[jzsj],[jzr],[jzks]
           ,mzfyno,jlxz,mz,hyzk,hjdz,zy,lxdz,islgls,lgstarttime,lgendtime)
  Select * From OpenQuery(dqhis, ''
    Select A.EMR_REGID GID, a.CLINIC_CODE BRID, a.CLINIC_CODE mzh, (Case When a.IS_EMERGENCY=''''1'''' Then 1 Else 0 End) IsJZ,
           (Case When a.YNFR=''''0'''' Then 1 Else 0 End) IsFZ,
           (Case When a.YNBOOK=''''1'''' Then 1 Else 0 End) IsYY,a.REGLEVL_NAME ghlb,substr(a.name,1,10) hzxm, case when a.SEX_CODE=''''M'''' then 1 
                                                                                                       when a.SEX_CODE=''''F'''' then 2 else null end hzxb,
          trunc(a.BIRTHDAY+0) csrq, null hznl, Null nldw,
          a.dept_code ghksdm,a.dept_name ghksmc, a.REG_DATE  ghsj, a.SEE_DOCD ghysdm, b.EMPL_NAME  ghysxm, a.RELA_PHONE tel, null lxr_xm, 
         null lxr_tel, null ybh, Null tz,substr(a.IDENNO,1,18) sfzhm,null mzzd_ICD,null mzzd_mc ,null zxzt,a.SEE_DATE jzsj,a.SEE_DOCD jzr,a.SEE_DPCD jzks,
         null mzfyno,null jlxz,null mz,null hyzk,null hjdz,null zy,null lxdz,case when a.IN_STATE<>''''N'''' then 1 else  0 end islgls,
         a.in_date lgstarttime,case when to_char(a.OUT_DATE,''''yyyy-mm-dd'''')=''''0001-01-01'''' then null else a.OUT_DATE end lgendtime
    From  dqhis.fin_opr_register a left join dqhis.com_employee  b on a.SEE_DOCD=b.EMPL_CODE
    Where A.TRANS_TYPE = ''''1'''' AND A.VALID_FLAG = ''''1'''' and 
          A.REG_DATE+0>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.REG_DATE+0<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''') '')'
   exec(@SQLText)  
  

  
    -- 计算年龄
  Update #infoMZGH
    Set hznl=nl, nldw=Anldw From (
  Select GID AGID, (Case When DateDiff(dd, csrq, ghsj)<=30 Then (Case When DateDiff(dd, csrq, ghsj)=0 Then 1 Else DateDiff(dd, csrq, ghsj) End)
            Else (Case When DateDiff(mm, csrq, ghsj)<=11 Then (Case When DateDiff(mm, csrq, ghsj)=0 Then 1 Else DateDiff(mm, csrq, ghsj) End)
              Else (Case When DateDiff(yy, csrq, ghsj)=0 Then 1 Else DateDiff(yy, csrq, ghsj) End) End) End) nl,
         (Case When DateDiff(dd, csrq, ghsj)<=30 Then '天'
            Else (Case When DateDiff(mm, csrq, ghsj)<=11 Then '月' Else '岁' End) End) Anldw
    From infoMZGH ) T
    Where GID=AGID

    
    --SELECT gid,ROW_NUMBER() OVER(PARTITION BY gid ORDER BY diag_name),icd_code,diag_name FROM aa  
    --WHERE diag_date=(SELECT MAX(diag_date) FROM aa a WHERE a.gid=aa.gid AND inpatient_no IS NOT NULL AND diag_kind IN (1,10) )  AND gid=1029033
 
   --取诊断select gid ,count(*) from aa where inpatient_no IS NOT NULL group by gid  having count(*)>1
   select a.gid, b.* into #zd 
   from #infoMZGH a left join (select * from openquery(dqhis,'select inpatient_no ,diag_kind,icd_code,diag_name,diag_date,diag_flag,main_flag  from  dqhis.met_com_diagnose')) b ON a.BRID=b.inpatient_no AND b.diag_flag=1 AND b.main_flag=1            
  
   --清洗2种情况的数据：1.不同时间的2次诊断，取最后一次诊断；2.同一时间的多次诊断，取其中一个
   SELECT ROW_NUMBER() OVER(PARTITION BY gid ORDER BY diag_name) xh,gid,icd_code mzzdicd ,diag_name mzzd INTO #zd2 FROM #zd  
   WHERE diag_date=(SELECT MAX(diag_date) FROM #zd  a WHERE a.gid=#zd.gid AND a.inpatient_no IS NOT NULL AND a.diag_kind IN (1,10) ) 
   
   --DROP TABLE aa

   update #infoMZGH
   set mzzd_ICD=#zd2.mzzdicd,mzzd_mc=#zd2.mzzd
   from #zd2 
   where #infoMZGH.gid=#zd2.gid AND xh=1
    
  Delete infoMZGH
  Where CONVERT(VARCHAR(10),ghsj,120)>=@StartDate and CONVERT(VARCHAR(10),ghsj,120)<@EndDate
  
--  print (@SQLText)
  INSERT INTO infoMZGH
  select * from #infoMZGH 
 
   --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoMZGH', 'ghsj', 'ghysdm', 'ghysxm'

End

/*
Exec P_infoMZGH_ETL '2016-05-01', '2016-05-31'
Select  top 1000 * From infoMZGH where BRTYPE IS NULL
drop table aa 

select top 1000 * from  infoMZGH order by ghsj desc
*/

