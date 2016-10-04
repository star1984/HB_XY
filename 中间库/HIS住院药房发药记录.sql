/*
 ���� ��ȡHISסԺҩ����ҩ��¼
 ���� ZMJ
 ���� 2013-10-31
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_infoZYYFFYJL_ETL' AND type = 'P')
   DROP PROCEDURE P_infoZYYFFYJL_ETL
GO

Create PROCEDURE P_infoZYYFFYJL_ETL
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
	[ypjj] [numeric](18, 4) NULL,
	[ypcb] [numeric](18, 4) NULL,
	[SFJLID] [varchar](50) NULL,
	[YZID] [varchar](50) NULL,
	[YZZXID] [varchar](50) NULL,
	[BRID] [varchar](50) NULL,
	[yzdjh] [varchar](50) NULL)
  Set @SQLText=
  'INSERT INTO #FY
           ([gid],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[fyrdm],[fyrxm],[fysj]
           ,[fysl],[ypdj],[ypje],[ypjj],[ypcb]
           ,[SFJLID],[YZID],[YZZXID]
           ,[yzdjh])
Select * From OpenQuery(ZLEMR, ''
  Select A.ID gid, A.�ⷿID yfdm, B.���� yfmc, To_Char(D.����ID)||''''_''''||To_Char(D.��ҳID) BRID, A.ҩƷID YPID, A.�Է�����ID lybmdm, 
         C.���� lybmmc, Null fyrdm, A.����� fyrxm,A.������� fysj, A.ʵ������ fysl, A.���ۼ� ypdj, A.���۽�� ypje, A.�ɱ��� ypjj, A.�ɱ���� ypcb, A.����ID SFJLID,  
         D.ҽ����� YZID,(Case When E.ҽ��ID is null Then Null Else To_Char(E.ҽ��ID)||''''_''''||To_Char(E.���ͺ�) End) YZZXID, D.NO yzdjh
    From ҩƷ�շ���¼ A
      Inner Join ���ű� B on A.�ⷿID=B.ID
      Inner Join ���ű� C on A.�Է�����ID=C.ID
      Left Join סԺ���ü�¼ D on A.����ID=D.ID
      Left Join ����ҽ������ E on D.ҽ�����=E.ҽ��ID and D.No=E.No
    Where A.����=9 and ���ϵ��=-1 and
          A.�������>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.�������<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''')'')'
  Exec (@SQLText)
  Delete infoZYYFFYJL
    Where Exists(Select 1 From #FY Where #FY.GID=infoZYYFFYJL.GID)
--  print (@SQLText)
  INSERT INTO infoZYYFFYJL
           ([gid],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[fyrdm],[fyrxm],[fysj]
           ,[fysl],[ypdj],[ypje],[ypjj],[ypcb]
           ,[SFJLID],[YZID],[YZZXID]
           ,[yzdjh])
    Select [gid],[yfdm],[yfmc],[BRID]
           ,[YPID],[lybmdm],[lybmmc]
           ,[fyrdm],[fyrxm],[fysj]
           ,[fysl],[ypdj],[ypje],[ypjj],[ypcb]
           ,[SFJLID],[YZID],[YZZXID]
           ,[yzdjh] From #FY
  Exec P_UpdateYSDM @StartDate, @EndDate, 'infoZYYFFYJL', 'fysj', 'fyrdm', 'fyrxm'
End

/*
Exec P_infoZYYFFYJL_ETL '2013-11-01', '2013-11-01'
*/

