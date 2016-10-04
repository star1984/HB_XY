/*
 功能 读取次诊断 按出院时间范围读取
 作者 ZMJ
 日期 2013-10-31
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_VsCH0C_ETL' AND type = 'P')
   DROP PROCEDURE P_VsCH0C_ETL
GO

Create PROCEDURE P_VsCH0C_ETL
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
  Declare @SQLText varchar(8000)
  CREATE TABLE #CH0C(
   CHYear               varchar(4)           not null,
   CH0C01               varchar(50)          not null,
   CH0C02               int                  not null,
   CH0C03               varchar(20)          null,
   CH0C03_MC            varchar(200)         null,
   CH0C05               varchar(1)           null,
   CH0C05_MC            varchar(4)           null,
   CH0C06               varchar(1)           null,
   CH0C06_MC            varchar(20)          null,
   CH0C07               varchar(1)           null,
   CH0C07_MC            varchar(10)          null,
   Ch0CN1               varchar(1)           null,
   Ch0CN1_MC            varchar(20)          null)
  Set @SQLText= 
  'INSERT INTO #CH0C 
           ([CHYear]
      ,[CH0C01]
      ,[CH0C02]
      ,[CH0C03]
      ,[CH0C03_MC]
      ,[CH0C05]
      ,[CH0C05_MC]
      ,[CH0C06]
      ,[CH0C06_MC]
      ,[CH0C07]
      ,[CH0C07_MC]
      ,[Ch0CN1]
      ,[Ch0CN1_MC])
  Select * From OpenQuery(jcba, '' 
   SELECT substr(to_char(a.fodate,''''yyyy-mm-dd''''),1,4) chyear
      ,a.FMRDID CH0C01
      ,C.FSEQ CH0C02
      ,C.FICD  CH0C03
      ,B.FDESC CH0C03_MC
      ,C.FOTHST CH0C05
      ,D.FDESC CH0C05_MC
      ,CAST(NULL AS VARCHAR(100)) CH0C06
      ,CAST(NULL AS VARCHAR(100)) CH0C06_MC
      ,CAST(NULL AS VARCHAR(100)) CH0C07
      ,CAST(NULL AS VARCHAR(100)) CH0C07_MC
      ,C.FIHSTA2 Ch0CN1
      ,E.FDESC Ch0CN1_MC
    FROM TMRDZD C
      Inner Join TMRDDE A on  a.FMRDID=c.FMRDID
      LEFT JOIN  tICD10 B ON  C.FICD=B.fICD10 
      LEFT JOIN  TOUSTA D ON  C.FOTHST=D.FID 
      LEFT JOIN  (SELECT DISTINCT FID,FQUN,FDESC FROM TSTAND_LIST WHERE FTYPE=''''入院病情'''' )  E ON e.FID=C.FIHSTA2
    Where C.FZDTYP<>''''1'''' and (to_char(a.fudate,''''yyyy-mm-dd'''')>='''''+@StartDate+''''' and to_char(a.fudate,''''yyyy-mm-dd'''')<='''''+@EndDate+''''')or
          (to_char(a.fodate,''''yyyy-mm-dd'''')>='''''+@StartDate+''''' and to_char(a.fodate,''''yyyy-mm-dd'''')<='''''+@EndDate+''''') '')' 
--  print (@SQLText)   
  Exec (@SQLText)

  Delete VsCH0C
    Where Exists(Select 1 From #CH0C Where  VsCH0C.CH0C01=#CH0C.CH0C01)

  Delete VsCH0C
    Where not Exists(Select 1 From VsCH0A A Where CH0A01=CH0C01)

  Insert Into VsCH0C ([CHYear]
      ,[CH0C01]
      ,[CH0C02]
      ,[CH0C03]
      ,[CH0C03_MC]
      ,[CH0C05]
      ,[CH0C05_MC]
      ,[CH0C06]
      ,[CH0C06_MC]
      ,[CH0C07]
      ,[CH0C07_MC]
      ,[Ch0CN1]
      ,[Ch0CN1_MC])
    Select [CHYear]
      ,[CH0C01]
      ,[CH0C02]
      ,[CH0C03]
      ,[CH0C03_MC]
      ,[CH0C05]
      ,[CH0C05_MC]
      ,[CH0C06]
      ,[CH0C06_MC]
      ,[CH0C07]
      ,[CH0C07_MC]
      ,[Ch0CN1]
      ,[Ch0CN1_MC] From #CH0C
End

/*
Exec P_VsCH0C_ETL '2015-01-01', '2015-10-25' 
select  * from VsCH0C where CH0C01=52297501
*/

