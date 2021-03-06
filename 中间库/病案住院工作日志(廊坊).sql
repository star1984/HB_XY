USE [hbidata]
GO
/****** Object:  StoredProcedure [dbo].[P_VsTjZy_ETL]    Script Date: 10/13/2015 10:04:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_VsTjZy_ETL]
   @StartDate varchar(10), @EndDate varchar(10)
As
begin
  Declare @SQLText varchar(8000)
  Select * into #Zy From zyworkdiary Where 1=2
  Set @SQLText= 
  'INSERT INTO #Zy 
           (RQ,KSDM,KSMC,ZKRS,XJRS,ZRRS,ZCRS,KFCWS)
  Select * From OpenQuery(JCBA, '' 
    SELECT A.FDATE,A.FOFFI,B.FDESC,a.FXYRS,a.FRYRS,a.FZRRS,a.FZCRS,a.FKFCS
  FROM TIPSI A INNER JOIN TOFFIM B  ON A.FOFFI=B.FOFFN 
    Where (to_char(fdate,''''yyyy-mm-dd'''')>='''''+@StartDate+''''' and to_char(fdate,''''yyyy-mm-dd'''')<='''''+@EndDate+''''') '')' 
--  print (@SQLText)   
  Exec (@SQLText)



  Delete zyworkdiary
    Where Exists(Select 1 From #Zy Where zyworkdiary.RQ=#Zy.RQ and zyworkdiary.KSDM=#Zy.KSDM)

  Insert Into zyworkdiary (RQ,KSDM,KSMC,ZKRS,XJRS,ZRRS,ZCRS,KFCWS)
    Select RQ,KSDM,KSMC,ZKRS,XJRS,ZRRS,ZCRS,KFCWS From #Zy

End

/*
Exec P_VsTjZy_ETL '2015-10-12', '2015-10-12'
*/

