USE [hbidata]
GO
/****** Object:  StoredProcedure [dbo].[P_infoBrZhuankJL_ETL]    Script Date: 03/14/2016 11:05:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_infoBrZhuankJL_ETL]
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
  Declare @SQLText varchar(8000)
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)


	
   SELECT * INTO #ZK FROM infoBrZhuankJL WHERE 1=2
   

   
   --转科日志 
  Set @SQLText=' INSERT INTO #ZK(
                                  [gid],[zcksdm],[zcksmc],[zrksdm],[zrksmc],[zkrq],[bah],[BRID]
								  ,[zyh],[zycs],valid
	                            ) 
                  Select *  From OpenQuery(DQHIS, ''select A.CLINIC_NO||''''_''''||cast(a.HAPPEN_NO as varchar(12)) gid,a.OLD_DATA_CODE zcksdm,a.OLD_DATA_NAME zcksmc,
                                                           a.NEW_DATA_CODE zrksdm,a.NEW_DATA_NAME zrksmc,a.oper_date zkrq,
                                                           cast(b.INPATIENT_NO  as varchar(20))||''''_''''||cast(1 as varchar(10)) bah, b.PATIENT_NO brid,
                                                           b.INPATIENT_NO zyh, 1 zycs ,1 valid
                                                           from dqhis.com_shiftdata a  left join  dqhis.fin_ipr_inmaininfo b on  a.CLINIC_NO=b.inpatient_no
                                                           where a.SHIFT_TYPE=''''RO''''  
                                                                 and A.oper_date>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.oper_date<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''')
  
                                                          '') '
                                                          
   exec(@SQLText)  
    
   --生成排序序号                                                      
   SELECT ROW_NUMBER() OVER(PARTITION BY zyh,zycs ORDER BY zkrq )  xh,gid,zyh,zycs,zkrq,zcksdm,zrksdm,valid INTO #ZK_NOVALID  FROM  #ZK 
   
   if exists(select 1 from sysobjects where type='U' and name='BBB2') 
   DROP TABLE BBB2
   
   --获取转科有效性标志记录   stat_type 4 转出 5 转入
   Set @SQLText='
                  Select * into BBB2 From OpenQuery(DQHIS, ''select distinct  A.seq_no gid,a.FROM_DEPT_CODE zcksdm,
                                                           a.TO_DEPT_CODE zrksdm,a.TRANSFER_DATE zkrq,
                                                           a.INPATIENT_NO zyh, 1 zycs ,a.stat_type zklx,a.IS_VALID valid
                                                           from  dqhis.met_mrs_inhosdayreport_detail a inner join  dqhis.com_shiftdata b on  a.inpatient_no=b.CLINIC_NO
                                                           where (a.stat_type=4 or a.stat_type=5) 
                                                                 and b.oper_date>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and b.oper_date<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''')
  
                                                          '') '
                                                          
   exec(@SQLText)  
   
   --生成排序序号
   SELECT ROW_NUMBER() OVER(PARTITION BY zyh,zycs,zklx ORDER BY gid )  xh,gid,zyh,zycs,zcksdm,zrksdm,zkrq,zklx,valid INTO #ZK_YESVALID FROM BBB2

  
       
       
     
--更新转科有效性标志  1 有效  0 无效
     --按转出科室更新有效性标志
     UPDATE a 
     SET valid=CASE WHEN b.valid=0 THEN 0 ELSE a.valid END 
     FROM #ZK_NOVALID a,#ZK_YESVALID b 
     WHERE a.zyh=b.zyh AND a.zycs=b.zycs AND  a.xh=b.xh  AND a.zcksdm=b.zcksdm AND b.zcksdm IS NOT NULL 
     
     --按转入科室更新有效性标志
     UPDATE a 
     SET valid=CASE WHEN b.valid=0 THEN 0 ELSE a.valid END 
     FROM #ZK_NOVALID a,#ZK_YESVALID b 
     WHERE a.zyh=b.zyh AND a.zycs=b.zycs AND a.xh=b.xh AND a.zrksdm=b.zrksdm AND b.zrksdm IS NOT null 
     
     --更新#ZK
     UPDATE A
     SET valid=b.valid
     FROM #ZK a,#ZK_NOVALID b
     WHERE a.gid=b.gid
  
  /*
    CREATE TABLE #ZK(
	[gid] [varchar](50) NULL,
	[BRID] [varchar](50) NULL,
	[bah] [varchar](50) NULL,
	[zyh] [varchar](50) NULL,
	[zycs] [int] NULL,
	[zkrq] [datetime] NULL,
	[zcksdm] [varchar](30) NULL,
	[zcksmc] [varchar](50) NULL,
	[zrksdm] [varchar](30) NULL,
	[zrksmc] [varchar](50) NULL,
	[zccwmc] [varchar](30) NULL,
	[zrcwmc] [varchar](30) NULL,
	[zczgysdm] [varchar](30) NULL,
	[zrzgysdm] [varchar](30) NULL) 

  insert into #ZK(gid,BRID,bah,zyh,zycs,zkrq,zcksdm,zrksdm,zczgysdm,zrzgysdm)
  */
 

  Delete infoBrZhuankJL 
  Where Exists(Select 1 From #ZK Where #ZK.GID=infoBrZhuankJL.GID)

  Insert INTO infoBrZhuankJL
           ([gid],[BRID],[bah]
           ,[zyh],[zycs]
           ,[zkrq],[zcksdm]
           ,[zcksmc],[zrksdm]
           ,[zrksmc],[zccwmc]
           ,[zrcwmc],[zczgysdm]
           ,[zrzgysdm],valid)
  Select    [gid],[BRID],[bah]
                 ,[zyh],[zycs]
                 ,[zkrq],[zcksdm]
                 ,[zcksmc],[zrksdm]
                 ,[zrksmc],[zccwmc]
                 ,[zrcwmc],[zczgysdm]
                 ,[zrzgysdm],valid From #ZK 
           
    DROP TABLE BBB2 
 

  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoBrZhuankJL', 'zkrq', 'zczgysdm', 'zczgysxm'
  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoBrZhuankJL', 'zkrq', 'zrzgysdm', 'zrzgysxm'
End

/*
SELECT * FROM BBB2 ORDER BY TRANS_PARREF

truncate table  infoBrZhuankJL
Exec P_infoBrZhuankJL_ETL '2016-05-01', '2016-05-31' 

 SELECT TOP 1000 * FROM infoBrZhuankJL WHERE zyh='ZY010000776288' ORDER BY zkrq
   
     SELECT TOP 1000 * FROM infoBrZhuankJL WHERE zyh='ZY010000777300' ORDER BY zkrq
       
       SELECT TOP 1000 * FROM infoRYDJB  WHERE zyh='ZY010000777300'
       
     SELECT * FROM bbb2 WHERE zyh='ZY010000777300' ORDER BY gid 
    
     SELECT * INTO aa FROM #ZK_NOVALID 
     
      SELECT * INTO bb FROM #ZK_YESVALID 
     
     SELECT TOP 1000 * FROM AA WHERE zyh='ZY010000777300' ORDER BY XH
     
     SELECT TOP 1000 * FROM BB WHERE zyh='ZY010000777300' ORDER BY XH

*/