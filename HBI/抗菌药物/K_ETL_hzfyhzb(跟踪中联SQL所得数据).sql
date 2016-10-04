/**********************************
--���ߣ��˿�
--���ڣ�2013-12-26 
--��ȡ���ߴ�������   

**********************************/  
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE NAME='K_ETL_hzfyhzb' AND TYPE='P' )
    DROP PROCEDURE K_ETL_hzfyhzb
Go    
CREATE ProceDure K_ETL_hzfyhzb 
 @StartDate varchar(10),
 @EndDate Varchar(10)
as
Begin
  delete T_hzfyhzb Where bidate between @StartDate And @EndDate
 Declare @SQLText varchar(8000)
 --,@StartDate varchar(10),@EndDate varchar(10)
 --Set @StartDate='2014-02-01'
 --Set @EndDate='2014-02-28'

CREATE TABLE #T_hzfyhzb( 
	[bidate] [datetime] NULL,
	[kscode] [nvarchar](20) NULL,
	[ksname] [nvarchar](40) NULL,
	[fylb] [nvarchar](200) NULL,
	[jzje] [numeric](20, 4) NULL,
	[fyxmlb] [nvarchar](50) NULL,
	[fyxmlbmc] [nvarchar](50) NULL
)
  Set @SQLText=
  'INSERT INTO #T_hzfyhzb
      ([bidate]
      ,[kscode]
      ,[ksname]
      ,[fylb]
      ,[jzje]
      ,[fyxmlb]
      ,[fyxmlbmc])
  Select * From OpenQuery(ZLEMR, ''
      Select a.����,
             C.���� AS ���ű���,
             C.���� AS ��������,
             a.��Դ;��,
             A.���ʽ��,
             B.���� AS �������,
             B.���� AS ������Ŀ
        From ���˷��û��� a,
            (SELECT ID,
                    �ϼ�ID,
                    ����,
                    LPAD('''' '''', (LEVEL - 1) * 3, '''' '''') || ���� AS ���� 
               FROM ������Ŀ
              WHERE LEVEL <= ''''1''''
              START WITH �ϼ�ID IS NULL
             CONNECT BY PRIOR ID = �ϼ�ID) B, 
             ���ű� C
       Where C.ID = A.��������ID AND 
             B.ID IN (SELECT ID FROM ZLHIS.������Ŀ
                       START WITH ID = A.������ĿID
                     CONNECT BY PRIOR �ϼ�ID = ID) And
             A.����>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and 
             A.����<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''')'')'
             
 
 Exec (@SQLText)
   
  insert into T_hzfyhzb
  Select DATEPART(yy,bidate) biyear,DATEPART(qq,bidate) biquarter,DATEPART(mm,bidate) bimonth,DATEPART(qq,bidate) biweek,*
    from #T_hzfyhzb 
 
End
go
--Exec K_ETL_hzfyhzb '2014-01-01','2014-03-28'  
  
  
  --Select Sum(jzje) from T_hzfyhzb Where bidate between '2014-02-01' And '2014-02-28' And fyxmlb='01' And fylb=2
  --Select * from T_hzfyhzb
 --SELECT a.����,
 --      C.���� AS ���ű���,
 --      C.���� AS ��������,
 --      a.��Դ;��,
 --      A.���ʽ��,
 --      B.���� AS �������,
 --      B.���� AS ������Ŀ, 
 -- FROM ���˷��û��� A,
 --      (SELECT ID,
 --              �ϼ�ID,
 --              ����,
 --              LPAD(' ', (LEVEL - 1) * 3, ' ') || ���� AS ����,
 --              LEVEL AS ����
 --         FROM ZLHIS.������Ŀ
 --        WHERE LEVEL <= '1'
 --        START WITH �ϼ�ID IS NULL
 --       CONNECT BY PRIOR ID = �ϼ�ID) B, ZLHIS.���ű� C
 --WHERE C.ID = A.��������ID 
 --  AND B.ID IN (SELECT ID
 --                 FROM ZLHIS.������Ŀ
 --                START WITH ID = A.������ĿID
 --               CONNECT BY PRIOR �ϼ�ID = ID)
 --     And a.����>=to_date('2014-01-01', 'YYYY-MM-DD') and 
 --         a.����<to_date('2014-03-28', 'YYYY-MM-DD') 
 