/*
 功能 读取HIS门诊药房发药记录
 作者 ZMJ
 日期 2013-10-31
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_infoMZYFFYJL_ETL' AND type = 'P')
   DROP PROCEDURE P_infoMZYFFYJL_ETL
GO

Create PROCEDURE P_infoMZYFFYJL_ETL
   @StartDate varchar(10), @EndDate varchar(10)
With 
   ENCRYPTION 
As
begin
  Declare @SQLText varchar(8000)
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)
  Create Table #FY(
	[gid] [varchar](50) NULL,
	[yfdm] [varchar](50) NULL,
	[yfmc] [varchar](50) NULL,
	[YPID] [varchar](50) NULL,
	[lybmdm] [varchar](50) NULL,
	[lybmmc] [varchar](50) NULL,
	[fyrdm] [varchar](50) NULL,
	[fyrxm] [varchar](50) NULL,
	[fysj] [datetime] NULL,
	[fysl] [numeric](18, 4) NULL,
	[ypdj] [numeric](18, 4) NULL,
	[ypje] [numeric](18, 4) NULL,
	[SFJLID] [varchar](50) NULL,
	[YZID] [varchar](50) NULL,
	[YZZXID] [varchar](50) NULL,
	[BRID] [varchar](50) NULL,
	[MZID] [varchar](50) NULL,
	[cfdjh] [varchar](50) NULL)
  Set @SQLText=
  'INSERT INTO #FY
           ([gid],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[fyrdm],[fyrxm],[fysj]
           ,[fysl],[ypdj],[ypje]
           ,[SFJLID],[YZID],[YZZXID]
           ,[MZID],[cfdjh])
Select * From OpenQuery(ZLEMR, ''
  Select A.ID gid, A.库房ID yfdm, B.名称 yfmc, D.病人ID BRID, A.药品ID YPID, A.对方部门ID lybmdm, C.名称 lybmmc, Null fyrdm, 
         A.审核人 fyrxm, A.审核日期 fysj, A.实际数量 fysl, A.零售价 ypdj, A.零售金额 ypje, A.费用ID SFJLID, D.医嘱序号 YZID, 
         (Case When E.医嘱ID is null Then Null Else To_Char(E.医嘱ID)||''''_''''||To_Char(E.发送号) End) YZZXID,
         G.ID MZID, D.NO cfdjh
    From 药品收发记录 A
      Inner Join 部门表 B on A.库房ID=B.ID
      Inner Join 部门表 C on A.对方部门ID=C.ID
      Left Join 门诊费用记录 D on A.费用ID=D.ID
      Left Join 病人医嘱发送 E on D.医嘱序号=E.医嘱ID and D.No=E.No
      Left Join 病人医嘱记录 F on D.医嘱序号=F.ID
      Left Join 病人挂号记录 G on F.病人ID=G.病人ID and F.挂号单=G.NO and G.记录状态<>2
    Where A.单据=8 and 入出系数=-1 and 
          A.审核日期>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.审核日期<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''')'')'
  Exec (@SQLText)
--  print (@SQLText)
  Delete infoMZYFFYJL
    Where Exists(Select 1 From #FY Where #FY.GID=infoMZYFFYJL.GID)

  INSERT INTO [infoMZYFFYJL]
           ([gid],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[fyrdm],[fyrxm],[fysj]
           ,[fysl],[ypdj],[ypje]
           ,[SFJLID],[YZID],[YZZXID]
           ,[MZID],[cfdjh])
    Select [gid],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[fyrdm],[fyrxm],[fysj]
           ,[fysl],[ypdj],[ypje]
           ,[SFJLID],[YZID],[YZZXID]
           ,[MZID],[cfdjh] From #FY
  Exec P_UpdateYSDM @StartDate, @EndDate, 'infoMZYFFYJL', 'fysj', 'fyrdm', 'fyrxm'
End

/*
Exec P_infoMZYFFYJL_ETL '2013-11-01', '2013-11-01'
*/
