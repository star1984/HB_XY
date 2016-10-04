USE [hbidata]
GO
/****** Object:  StoredProcedure [dbo].[P_VsTjZy_ETL]    Script Date: 10/13/2015 10:04:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[P_VsTjmz_ETL]
   @StartDate varchar(10), @EndDate varchar(10)
As
begin
  Declare @SQLText varchar(8000)
  Select * into #mz From mzworkdiary Where 1=2
  Set @SQLText= 
  'INSERT INTO #mz
           (RQ,KSDM,KSMC,PTHRS,JZHRS)
  Select * From OpenQuery(JCBA, '' 
    SELECT A.FDATE,A.FOFFI,B.FDESC,A.FCZRS,A.FJZRS
  FROM TOPSI A INNER JOIN TOFFIM B  ON A.FOFFI=B.FOFFN 
    Where (to_char(fdate,''''yyyy-mm-dd'''')>='''''+@StartDate+''''' and to_char(fdate,''''yyyy-mm-dd'''')<='''''+@EndDate+''''') '')' 
--  print (@SQLText)   
  Exec (@SQLText)



  Delete mzworkdiary
    Where Exists(Select 1 From #mz Where mzworkdiary.RQ=#mz.RQ and mzworkdiary.KSDM=#mz.KSDM)

  Insert Into mzworkdiary (RQ,KSDM,KSMC,PTHRS,JZHRS)
    Select RQ,KSDM,KSMC,PTHRS,JZHRS From #mz

End

/*
Exec P_VsTjmz_ETL '2015-10-11', '2015-10-11'
select * from mzworkdiary where ksdm=101
*/

