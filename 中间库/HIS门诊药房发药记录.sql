/*
 ���� ��ȡHIS����ҩ����ҩ��¼
 ���� ZMJ
 ���� 2013-10-31
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
  Select A.ID gid, A.�ⷿID yfdm, B.���� yfmc, D.����ID BRID, A.ҩƷID YPID, A.�Է�����ID lybmdm, C.���� lybmmc, Null fyrdm, 
         A.����� fyrxm, A.������� fysj, A.ʵ������ fysl, A.���ۼ� ypdj, A.���۽�� ypje, A.����ID SFJLID, D.ҽ����� YZID, 
         (Case When E.ҽ��ID is null Then Null Else To_Char(E.ҽ��ID)||''''_''''||To_Char(E.���ͺ�) End) YZZXID,
         G.ID MZID, D.NO cfdjh
    From ҩƷ�շ���¼ A
      Inner Join ���ű� B on A.�ⷿID=B.ID
      Inner Join ���ű� C on A.�Է�����ID=C.ID
      Left Join ������ü�¼ D on A.����ID=D.ID
      Left Join ����ҽ������ E on D.ҽ�����=E.ҽ��ID and D.No=E.No
      Left Join ����ҽ����¼ F on D.ҽ�����=F.ID
      Left Join ���˹Һż�¼ G on F.����ID=G.����ID and F.�Һŵ�=G.NO and G.��¼״̬<>2
    Where A.����=8 and ���ϵ��=-1 and 
          A.�������>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.�������<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''')'')'
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
