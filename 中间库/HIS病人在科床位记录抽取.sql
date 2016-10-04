��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������/*
 ���� ��ȡHIS�����ڿƼ�¼ 
 ���� ZMJ
 ���� 2013-11-01
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
  -- ���ǵ���Ҫ�Ӵ˱�����ת�����ݣ�ÿ�ζ��һ��
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
								  Select A.ID, To_Char(A.����ID)||''''_''''||To_Char(A.��ҳID) BRID, A.����ID bah, A.��ҳID zycs, D.סԺ�� zyh,A.��ʼʱ�� zkrq ,A.����ID ksdm, E.���� ksmc, A.���� cw,
									   (Case When A.����ҽʦ is Null or A.����ҽʦ=''''����Ա'''' Then F.��Ϣֵ Else A.����ҽʦ End) zgys
								  From ���˱䶯��¼ A
									Left Join ������ҳ D on A.����ID=D.����ID and A.��ҳID=D.��ҳID
									Left Join ���ű� E on A.����ID=E.ID
									Left Join ������ҳ�ӱ� F on A.����ID=F.����ID and A.��ҳID=F.��ҳID and F.��Ϣ��=''''����ҽʦ''''
								  Where A.��ʼʱ��>To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and    A.��ʼʱ��<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD'''') and A.��ʼԭ��=2 and
										not Exists(Select 1 From ���˱䶯��¼ B Where ��ֹʱ��<To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and ��ֹԭ��=1 and A.����ID=B.����ID and A.��ҳID=B.��ҳID) and
										not Exists(Select 1 From ���˱䶯��¼ C Where  ��ʼʱ��>To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and ��ʼʱ��<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD'''') and ��ʼԭ��=3 and A.����ID=C.����ID and A.��ҳID=C.��ҳID)
 Union
								Select A.ID, To_Char(A.����ID)||''''_''''||To_Char(A.��ҳID) BRID, A.����ID bah, A.��ҳID zycs, D.סԺ�� zyh,A.��ʼʱ�� zkrq, A.����ID ksdm, E.���� ksmc, A.���� cw,
									   (Case When A.����ҽʦ is Null or A.����ҽʦ=''''����Ա'''' Then F.��Ϣֵ Else A.����ҽʦ End) zgys
								  From ���˱䶯��¼ A
									Left Join ������ҳ D on A.����ID=D.����ID and A.��ҳID=D.��ҳID
									Left Join ���ű� E on A.����ID=E.ID
									Left Join ������ҳ�ӱ� F on A.����ID=F.����ID and A.��ҳID=F.��ҳID and F.��Ϣ��=''''����ҽʦ''''
								  Where A.��ʼʱ��>To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and A.��ʼʱ��<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD'''') and A.��ʼԭ�� in (4,5,6,7,8,11,12,13,15) and A.��ʼʱ��=
										(Select Max(��ʼʱ��) From ���˱䶯��¼ C Where ��ʼʱ��>To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and ��ʼʱ��<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD'''') and ��ʼԭ�� in (4,5,6,7,8,11,12,13,15) and A.����ID=C.����ID and A.��ҳID=C.��ҳID and c.���� is not null) and
										not Exists(Select 1 From ���˱䶯��¼ B Where ��ֹʱ��<To_Date('''''+@PDate+''''', ''''YYYY-MM-DD'''') and ��ֹԭ��=1 and A.����ID=B.����ID and A.��ҳID=B.��ҳID)  '')'
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

