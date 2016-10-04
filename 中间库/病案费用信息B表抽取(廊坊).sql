/*
 功能 读取入院登记表 按入院时间范围读取
 作者 ZMJ
 日期 2013-10-31
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_VsCH0B_ETL' AND type = 'P')
   DROP PROCEDURE P_VsCH0B_ETL
GO

Create PROCEDURE P_VsCH0B_ETL
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
  Declare @SQLText varchar(8000)
  CREATE TABLE #CH0B(
   CHYear               varchar(4)           not null,
   CH0B01               varchar(50)          not null,
   CH0B83               numeric(18,2)        null,
   CH0BP1               numeric(18,2)        null,
   CH0BP2               numeric(18,2)        null,
   CH0BP3               numeric(18,2)        null,
   CH0BP4               numeric(18,2)        null,
   CH0BP5               numeric(18,2)        null,
   CH0BP6               numeric(18,2)        null,
   CH0BP7               numeric(18,2)        null,
   CH0BP8               numeric(18,2)        null,
   CH0BP9               numeric(18,2)        null,
   CH0BPA               numeric(18,2)        null,
   CH0BPB               numeric(18,2)        null,
   CH0BPC               numeric(18,2)        null,
   CH0BPD               numeric(18,2)        null,
   CH0BPE               numeric(18,2)        null,
   CH0BPF               numeric(18,2)        null,
   CH0BPG               numeric(18,2)        null,
   CH0BPH               numeric(18,2)        null,
   CH0BPI               numeric(18,2)        null,
   CH0BPJ               numeric(18,2)        null,
   CH0BPK               numeric(18,2)        null,
   CH0BPL               numeric(18,2)        null,
   CH0BPM               numeric(18,2)        null,
   CH0BPN               numeric(18,2)        null,
   CH0BPO               numeric(18,2)        null,
   CH0BPP               numeric(18,2)        null,
   CH0BPQ               numeric(18,2)        null,
   CH0BPR               numeric(18,2)        null,
   CH0BPS               numeric(18,2)        null,
   CH0BPT               numeric(18,2)        null)
  Set @SQLText= 
  'INSERT INTO #CH0B 
           (CHYear
      ,CH0B01
      ,CH0B83
      ,CH0BP1
      ,CH0BP2
      ,CH0BP3
      ,CH0BP4
      ,CH0BP5
      ,CH0BP6
      ,CH0BP7
      ,CH0BP8
      ,CH0BP9
      ,CH0BPA
      ,CH0BPB
      ,CH0BPC
      ,CH0BPD
      ,CH0BPE
      ,CH0BPF
      ,CH0BPG
      ,CH0BPH
      ,CH0BPI
      ,CH0BPJ
      ,CH0BPK
      ,CH0BPL
      ,CH0BPM
      ,CH0BPN
      ,CH0BPO
      ,CH0BPP
      ,CH0BPQ
      ,CH0BPR
      ,CH0BPS
      ,CH0BPT)
  Select * From OpenQuery(JCBA, '' 
    SELECT substr(to_char(a.fodate,''''yyyy-mm-dd''''),1,4) chyear,B.FMRDID CH0B01,
          B.FFSUM CH0B83,
		  B.FFSEL CH0BP1,B.F0101 CH0BP2,B.F0102 CH0BP3,F0103 CH0BP4,F0104 CH0BP5,F0205 CH0BP6,F0206 CH0BP7,F0207 CH0BP8,F0208 CH0BP9,
		  F0309 CH0BPA,F030901 CH0BPB,F0310 CH0BPC,F031001 CH0BPD,F031002 CH0BPE,
		  F0411 CH0BPF,F0512 CH0BPG,F0613 CH0BPH,F061301 CH0BPI,F0714 CH0BPJ,F0715 CH0BPK,
		  F0816 CH0BPL,F0817 CH0BPM,F0818 CH0BPN,F0819 CH0BPO,F0820 CH0BPP,
		  F0921 CH0BPQ,F0922 CH0BPR,F0923 CH0BPS,F1024 CH0BPT
  FROM TMRDDE_CHARGE B Inner Join TMRDDE A on  a.FMRDID=b.FMRDID
    Where (to_char(a.fudate,''''yyyy-mm-dd'''')>='''''+@StartDate+''''' and to_char(a.fudate,''''yyyy-mm-dd'''')<='''''+@EndDate+''''')or
          (to_char(a.fodate,''''yyyy-mm-dd'''')>='''''+@StartDate+''''' and to_char(a.fodate,''''yyyy-mm-dd'''')<='''''+@EndDate+''''') '')'
--  print (@SQLText)   
  exec (@SQLText)

  Delete VsCH0B
    Where Exists(Select 1 From #CH0B Where VsCH0B.CHYear=#CH0B.CHYear and VsCH0B.CH0B01=#CH0B.CH0B01)
  

  
  Delete VsCH0B
    Where not Exists(Select 1 From VsCH0A A Where VsCH0B.CHYear=A.CHYear and a.CH0A01=VsCH0B.CH0B01)

  Insert Into VsCH0B (CHYear
      ,CH0B01
      ,CH0B83
      ,CH0BP1
      ,CH0BP2
      ,CH0BP3
      ,CH0BP4
      ,CH0BP5
      ,CH0BP6
      ,CH0BP7
      ,CH0BP8
      ,CH0BP9
      ,CH0BPA
      ,CH0BPB
      ,CH0BPC
      ,CH0BPD
      ,CH0BPE
      ,CH0BPF
      ,CH0BPG
      ,CH0BPH
      ,CH0BPI
      ,CH0BPJ
      ,CH0BPK
      ,CH0BPL
      ,CH0BPM
      ,CH0BPN
      ,CH0BPO
      ,CH0BPP
      ,CH0BPQ
      ,CH0BPR
      ,CH0BPS
      ,CH0BPT)
    Select CHYear
      ,CH0B01
      ,CH0B83
      ,CH0BP1
      ,CH0BP2
      ,CH0BP3
      ,CH0BP4
      ,CH0BP5
      ,CH0BP6
      ,CH0BP7
      ,CH0BP8
      ,CH0BP9
      ,CH0BPA
      ,CH0BPB
      ,CH0BPC
      ,CH0BPD
      ,CH0BPE
      ,CH0BPF
      ,CH0BPG
      ,CH0BPH
      ,CH0BPI
      ,CH0BPJ
      ,CH0BPK
      ,CH0BPL
      ,CH0BPM
      ,CH0BPN
      ,CH0BPO
      ,CH0BPP
      ,CH0BPQ
      ,CH0BPR
      ,CH0BPS
      ,CH0BPT
      From #CH0B
    
End

/*
Exec P_VsCH0B_ETL '2015-01-01', '2015-01-02'
*/

