IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_AutoGetAllData2' AND type = 'P')
   DROP PROCEDURE P_AutoGetAllData2
GO

Create PROCEDURE P_AutoGetAllData2

As
begin
  Declare @StartDate varchar(10), @EndDate varchar(10)
  Select @EndDate=Convert(varchar(10), GetDate(), 120)
  Set @StartDate=Convert(varchar(10), DateAdd(dd, -45, @EndDate), 120)

  Exec P_AllData_ETL2 @StartDate, @EndDate
End

/*
Exec P_AutoGetAllData
*/