/*
 ���� ��ȡHIS�����ڿƼ�¼ 
 ���� ZMJ
 ���� 2013-11-01
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_infoBrzkjl_ETL' AND type = 'P')
   DROP PROCEDURE P_infoBrzkjl_ETL
GO

Create PROCEDURE P_infoBrzkjl_ETL
   @StartDate varchar(10), @EndDate varchar(10)
With 
   ENCRYPTION 
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
  Select Convert(varchar(30), ID)+''_''+replace('''+@PDate+''', ''-'',''''), BRID, bah, zyh, zycs, '''+@PDate+''', cw, cw, Null, zgys, ksdm, ksmc From OpenQuery(ZLEMR, ''
    Select A.ID, To_Char(A.����ID)||''''_''''||To_Char(A.��ҳID) BRID, A.����ID bah, A.��ҳID zycs, D.סԺ�� zyh, A.����ID ksdm, E.���� ksmc, 
           (Case When Exists(Select 1 From ���˱䶯��¼ G Where A.����ID=G.����ID and A.��ҳID=G.��ҳID and G.��ʼԭ��=4 and G.��ʼʱ��>A.��ʼʱ�� and G.��ʼʱ��<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD''''))
               Then (Select max(����) From ���˱䶯��¼ G Where A.����ID=G.����ID and A.��ҳID=G.��ҳID and G.��ʼԭ��=4 and
                       G.��ʼʱ��=(Select Max(��ʼʱ��) From ���˱䶯��¼ H Where G.����ID=H.����ID and G.��ҳID=H.��ҳID and H.��ʼԭ��=4 and H.��ʼʱ��<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD''''))
                  ) Else  A.���� End) cw,
           (Case When B.����ҽʦ is Null or B.����ҽʦ=''''����Ա'''' Then F.��Ϣֵ Else B.����ҽʦ End) zgys
      From ���˱䶯��¼ A
        Left Join ������ҳ D on A.����ID=D.����ID and A.��ҳID=D.��ҳID
        Left Join ���ű� E on A.����ID=E.ID
        Left Join (Select C.ID, (Case When Exists(Select 1 From ���˱䶯��¼ G Where C.����ID=G.����ID and C.��ҳID=G.��ҳID and G.��ʼԭ��=11 and G.��ʼʱ��>C.��ʼʱ�� and G.��ʼʱ��<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD''''))
          Then (Select max(����ҽʦ) From ���˱䶯��¼ G Where C.����ID=G.����ID and C.��ҳID=G.��ҳID and G.��ʼԭ��=11 and
                       G.��ʼʱ��=(Select Max(��ʼʱ��) From ���˱䶯��¼ H Where G.����ID=H.����ID and G.��ҳID=H.��ҳID and H.��ʼԭ��=11 and H.��ʼʱ��<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD''''))
                  ) Else  C.����ҽʦ End) ����ҽʦ From ���˱䶯��¼ C) B on A.ID=B.ID
        Left Join ������ҳ�ӱ� F on A.����ID=F.����ID and A.��ҳID=F.��ҳID and F.��Ϣ��=''''����ҽʦ''''
      Where A.��ʼԭ�� in (2,3) and A.��ʼʱ��<To_Date('''''+@P1Date+''''', ''''YYYY-MM-DD'''') and
            not Exists(Select 1 From ���˱䶯��¼ B
              Where B.��ֹʱ��>A.��ʼʱ�� and ��ֹԭ�� in (1, 3) and A.����ID=B.����ID and A.��ҳID=B.��ҳID and ��ֹʱ��<To_Date('''''+@PDate+''''', ''''YYYY-MM-DD''''))'')'
-- ��ʼԭ�� 2 ��� 3 ת��  ��ֹԭ�� 1 ��Ժ 3 ת��  
-- ����ʼԭ��Ϊ 9(����תסԺ)ʱ֮ǰ������ƶ��� ���Բ��ÿ���
---- ����ֹԭ��Ϊ 10(Ԥ��Ժ)ʱ �Բ��˲�����ʵ��Ӱ�����Ҳ���ÿ���
  Delete infoBrzkjl
    Where convert(varchar(10),zkrq,120)>=@StartDate and convert(varchar(10),zkrq,120)<@EndDate
  Set @Date=@StartDate
  while Convert(Datetime, @Date)<Convert(DateTime, @EndDate) begin
    Set @NDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @Date)), 120)
    Set @SQLText1=replace(replace(@SQLText, @PDate, @Date), @P1Date, @NDate)
    Exec (@SQLText1)
    --print (@SQLText1)
    Set @Date=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @Date)), 120)
  End
  Exec P_UpdateYSDM @StartDate, @EndDate, 'infoBrzkjl', 'zkrq', 'zgysdm', 'zgysxm'
End

/*
Exec P_infoBrzkjl_ETL '2015-01-01', '2015-01-01'
*/

