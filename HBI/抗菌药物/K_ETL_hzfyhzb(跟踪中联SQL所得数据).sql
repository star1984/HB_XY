/**********************************
--作者：邓俊
--日期：2013-12-26 
--抽取患者处方数据   

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
      Select a.日期,
             C.编码 AS 部门编码,
             C.名称 AS 部门名称,
             a.来源途径,
             A.结帐金额,
             B.编码 AS 收入编码,
             B.名称 AS 收入项目
        From 病人费用汇总 a,
            (SELECT ID,
                    上级ID,
                    编码,
                    LPAD('''' '''', (LEVEL - 1) * 3, '''' '''') || 名称 AS 名称 
               FROM 收入项目
              WHERE LEVEL <= ''''1''''
              START WITH 上级ID IS NULL
             CONNECT BY PRIOR ID = 上级ID) B, 
             部门表 C
       Where C.ID = A.开单部门ID AND 
             B.ID IN (SELECT ID FROM ZLHIS.收入项目
                       START WITH ID = A.收入项目ID
                     CONNECT BY PRIOR 上级ID = ID) And
             A.日期>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and 
             A.日期<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''')'')'
             
 
 Exec (@SQLText)
   
  insert into T_hzfyhzb
  Select DATEPART(yy,bidate) biyear,DATEPART(qq,bidate) biquarter,DATEPART(mm,bidate) bimonth,DATEPART(qq,bidate) biweek,*
    from #T_hzfyhzb 
 
End
go
--Exec K_ETL_hzfyhzb '2014-01-01','2014-03-28'  
  
  
  --Select Sum(jzje) from T_hzfyhzb Where bidate between '2014-02-01' And '2014-02-28' And fyxmlb='01' And fylb=2
  --Select * from T_hzfyhzb
 --SELECT a.日期,
 --      C.编码 AS 部门编码,
 --      C.名称 AS 部门名称,
 --      a.来源途径,
 --      A.结帐金额,
 --      B.编码 AS 收入编码,
 --      B.名称 AS 收入项目, 
 -- FROM 病人费用汇总 A,
 --      (SELECT ID,
 --              上级ID,
 --              编码,
 --              LPAD(' ', (LEVEL - 1) * 3, ' ') || 名称 AS 名称,
 --              LEVEL AS 级数
 --         FROM ZLHIS.收入项目
 --        WHERE LEVEL <= '1'
 --        START WITH 上级ID IS NULL
 --       CONNECT BY PRIOR ID = 上级ID) B, ZLHIS.部门表 C
 --WHERE C.ID = A.开单部门ID 
 --  AND B.ID IN (SELECT ID
 --                 FROM ZLHIS.收入项目
 --                START WITH ID = A.收入项目ID
 --               CONNECT BY PRIOR 上级ID = ID)
 --     And a.日期>=to_date('2014-01-01', 'YYYY-MM-DD') and 
 --         a.日期<to_date('2014-03-28', 'YYYY-MM-DD') 
 