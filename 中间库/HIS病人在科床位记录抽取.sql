······································································································································································································································································································································································/*
 功能 读取HIS病人在科记录 
 作者 ZMJ
 日期 2013-11-01
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_infoBrzkjl_ETL' AND type = 'P')
   DROP PROCEDURE P_infoBrzkjl_ETL
GO

Create PROCEDURE P_infoBrzkjl_ETL
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
  Declare @SQLText varchar(8000), @SQLText1 varchar(8000), @Date varchar(10), @NDate varchar(10),
          @PDate varchar(10), @P1Date varchar(10)
  Set @PDate='8888888888'
  Set @P1Date='9999999999'
  -- 考虑到需要从此表生成转科数据，每次多读一天
  Set @StartDate=Convert(varchar(10), Dateadd(dd, -1, Convert(DateTime, @StartDate)), 120)
  if Convert(DateTime, @EndDate)>=GetDate()
    Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, GetDate()), 120)
  Else
    Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)
  Set @SQLText=
  'INSERT INTO [infoBrzkjl]
           ([gid],[BRID],[bah]
           ,[zyh],[zycs]
           ,[zkrq],[cwdm]
           ,[cwmc],[zgysdm]
           ,[zgysxm],[ksdm]
           ,[ksmc])
  Select Convert(varchar(30), ID)+''_''+replace('''+@PDate+''', ''-'',''''), BRID, bah, zyh, zycs, zkrq, cw, cw, Null, zgys, ksdm, ksmc 
         From OpenQuery(ZLEMR, ''
								  Select A.ID, To_Char(A.病人ID)||''''_''''||To_Char(A.主页ID) BRID, A.病人ID bah, A.主页ID zycs, D.住院号 zyh,A.开始时间 zkrq ,A.科室ID ksdm, E.名称 ksmc, A.床号 cw,
									   (Case When A.主治医师 is Null or A.主治医师=''''管理员'''' Then F.信息值 Else A.主治医师 End) zgys
								  From 病人变动记录 A
									Left Join 病案主页 D on A.病人ID=D.病人ID and A.主页ID=D.主页ID
									Left Join 部门表 E on A.科室ID=E.ID
									Left Join 病案主页从表 F on A.病人ID=F.病人ID and A.主页ID=F.主页ID and F.信息名=''''主治医师''''
								  Where A.开始时间>To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and    A.开始时间<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD'''') and A.开始原因=2 and
										not Exists(Select 1 From 病人变动记录 B Where 终止时间<To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and 终止原因=1 and A.病人ID=B.病人ID and A.主页ID=B.主页ID) and
										not Exists(Select 1 From 病人变动记录 C Where  开始时间>To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and 开始时间<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD'''') and 开始原因=3 and A.病人ID=C.病人ID and A.主页ID=C.主页ID)
 Union
								Select A.ID, To_Char(A.病人ID)||''''_''''||To_Char(A.主页ID) BRID, A.病人ID bah, A.主页ID zycs, D.住院号 zyh,A.开始时间 zkrq, A.科室ID ksdm, E.名称 ksmc, A.床号 cw,
									   (Case When A.主治医师 is Null or A.主治医师=''''管理员'''' Then F.信息值 Else A.主治医师 End) zgys
								  From 病人变动记录 A
									Left Join 病案主页 D on A.病人ID=D.病人ID and A.主页ID=D.主页ID
									Left Join 部门表 E on A.科室ID=E.ID
									Left Join 病案主页从表 F on A.病人ID=F.病人ID and A.主页ID=F.主页ID and F.信息名=''''主治医师''''
								  Where A.开始时间>To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and A.开始时间<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD'''') and A.开始原因 in (4,5,6,7,8,11,12,13,15) and A.开始时间=
										(Select Max(开始时间) From 病人变动记录 C Where 开始时间>To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and 开始时间<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD'''') and 开始原因 in (4,5,6,7,8,11,12,13,15) and A.病人ID=C.病人ID and A.主页ID=C.主页ID and c.床号 is not null) and
										not Exists(Select 1 From 病人变动记录 B Where 终止时间<To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and 终止原因=1 and A.病人ID=B.病人ID and A.主页ID=B.主页ID)  '')'
  Delete infoBrzkjl
    Where convert(varchar(10),zkrq,120)>=@StartDate and convert(varchar(10),zkrq,120)<@EndDate
  Set @Date=@StartDate
  while Convert(Datetime, @Date)<Convert(DateTime, @EndDate) begin
    Set @NDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @Date)), 120)
    Set @SQLText1=replace(replace(@SQLText, @PDate, @Date), @P1Date, @NDate)
    Exec (@SQLText1)
    Set @Date=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @Date)), 120)
  End
  Exec P_UpdateYSDM @StartDate, @EndDate, 'infoBrzkjl', 'zkrq', 'zgysdm', 'zgysxm'
--  print (@SQLText)
End

/*
Exec P_infoBrzkjl_ETL '2015-01-01', '2015-03-10'
*/

