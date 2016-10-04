IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_AutoGetAllData' AND type = 'P')
   DROP PROCEDURE P_AutoGetAllData
GO

Create PROCEDURE P_AutoGetAllData

As
begin
  Declare @StartDate varchar(10), @EndDate varchar(10)
  Select @EndDate=Convert(varchar(10), GetDate(), 120)
  Set @StartDate=Convert(varchar(10), DateAdd(dd, -31, @EndDate), 120)

  Exec P_AllData_ETL @StartDate, @EndDate
End

/*
Exec P_AutoGetAllData
*/