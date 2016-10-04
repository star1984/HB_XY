/*
 功能 读取HIS门诊处方
 作者 ZMJ
 日期 2013-10-31
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_infoMZCF_ETL' AND type = 'P')
   DROP PROCEDURE P_infoMZCF_ETL
GO

CREATE PROCEDURE [dbo].[P_infoMZCF_ETL]  
   @StartDate varchar(10), @EndDate varchar(10)  
  
As  
begin  
  Declare @SQLText varchar(8000)  
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)  
    
  if(exists(select 1 from tempdb..sysobjects where id=object_id('tempdb..#xx_temp_infoMZCF')))  
    Begin  
      drop table #xx_temp_infoMZCF  
    End  
  CREATE TABLE #xx_temp_infoMZCF(  
 [CFID] [varchar](50) NOT NULL,  
 [cfzid] [varchar](50) NULL,  
 [cfdjh] [varchar](50) NULL,  
 [MZID] [varchar](50) NULL,  
 [mzh] [varchar](50) NULL,  
 [mzcs] [int] NULL,  
 [cflxdm] [varchar](20) NULL,  
 [cflxmc] [varchar](30) NULL,  
 [kcfysdm] [varchar](30) NULL,  
 [kcfysxm] [varchar](30) NULL,  
 [zlxmdm] [varchar](50) NULL,  
 [zlxmmc] [varchar](100) NULL,  
 [kcfksdm] [varchar](30) NULL,  
 [kcfksmc] [varchar](50) NULL,  
 [cfcjsj] [datetime] NULL,  
 [zxplcs] [int] NULL,  
 [zxpljg] [int] NULL,  
 [zxpljgdw] [varchar](20) NULL,  
 [gyfsdm] [varchar](50) NULL,  
 [gyfsmc] [varchar](100) NULL,  
 [yplbdm] [varchar](50) NULL,  
 [yplbmc] [varchar](50) NULL,  
 [cfyl] [varchar](50) NULL,  
 [cfnr] [varchar](800) NULL,  
 [yymd] [varchar](20) NULL,  
 [yyyy] [varchar](50) NULL,  
 [Issqsykss] [int] NULL,  
 [sykssmd] [int] NULL,  
 [brID] varchar(50) NULL,  
 [cfztdm] [int] NULL,  
 [cfztmc] [nvarchar](50) NULL,
 [yongliang] [varchar](50) NULL,
 [zxpc]  [varchar](50) NULL
 )  
    
    
  Set @SQLText=  
  ' INSERT INTO #xx_temp_infoMZCF  
           ([CFID],[cfzid],[cfdjh],[MZID],[mzh]  
           ,[mzcs],[cflxdm],[cflxmc]  
           ,[kcfysdm],[kcfysxm],[zlxmdm]  
           ,[zlxmmc],[kcfksdm],[kcfksmc]  
           ,[cfcjsj],[zxplcs],[zxpljg]  
           ,[zxpljgdw],[gyfsdm],[gyfsmc]  
           ,[yplbdm],[yplbmc],[cfyl]  
           ,[cfnr],[yymd],[yyyy]  
           ,[Issqsykss],[sykssmd]  
           ,[brID],[cfztdm],[cfztmc],[yongliang],[zxpc])  
  Select *   From OpenQuery(DQHIS,''  
  Select a.SEQUENCE_NO cfid, Null cfzid, a.RECIPE_NO cfdjh,b.EMR_REGID mzid,a.CLINIC_CODE mzh, 
         1 mzcs, a.CLASS_CODE cflxdm, c.name cflxmc,
         a.DOCT_CODE kyzysdm, a.DOCT_NAME kyzysxm,    
         a.ITEM_CODE zlxmdm, a.ITEM_name zlxmmc, a.EXEC_DPCD kyzksdm, a.EXEC_DPNM kyzksmc, 
         a.oper_date cfcjsj, 
         null zxplcs, null zxpljg, null zxpljgdw,  
         a.USAGE_CODE gyfsdm, a.USAGE_name gyfsmc, null yplbdm,   
         null yplbmc, a.qty cfyl, a.ITEM_NAME cfnr, null yymd, null yyyy,  
         Null Issqsykss, Null sykssmd,a.CLINIC_CODE brid,a.STATUS cfztdm, null  cfztmc,
         null yongliang, a.FREQUENCY_name zxpc   
    From  dqhis.met_ord_recipedetail a left join dqhis.fin_opr_register b on  a.clinic_code=b.clinic_code and b.TRANS_TYPE = ''''1'''' AND b.VALID_FLAG = ''''1''''
                                       left join dqhis.com_dictionary c   on  a.CLASS_CODE=c.code and  c.type=''''MZEXECBILL''''
    Where A.oper_date>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.oper_date<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''') '')'  
  --print (@SQLText)  
   Exec (@SQLText)  
  
   UPDATE  #xx_temp_infoMZCF 
   SET cfztmc=case when cfztdm='0' then '开立'
                   when cfztdm='1' then '收费' 
                   when cfztdm='2' then '确认' 
                   when cfztdm='3' then '作废' else null end 
 

  Delete infoMZCF  
    Where exists (select 1 from #xx_temp_infoMZCF a where infoMZCF.cfid=a.cfid)  
      
   INSERT INTO [infoMZCF]  
           ([CFID],[cfzid],[cfdjh],[MZID],[mzh]  
           ,[mzcs],[cflxdm],[cflxmc]  
           ,[kcfysdm],[kcfysxm],[zlxmdm]  
           ,[zlxmmc],[kcfksdm],[kcfksmc]  
           ,[cfcjsj],[zxplcs],[zxpljg]  
           ,[zxpljgdw],[gyfsdm],[gyfsmc]  
           ,[yplbdm],[yplbmc],[cfyl]  
           ,[cfnr],[yymd],[yyyy]  
           ,[Issqsykss],[sykssmd],[brID]  
           ,[cfztdm],[cfztmc],[yongliang],[zxpc])  
   select * from #xx_temp_infoMZCF  

  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoMZCF', 'cfcjsj', 'kcfysdm', 'kcfysxm'  

End  
  
/*  
Exec P_infoMZCF_ETL '2016-05-01', '2016-06-30' 

truncate table infoMZCF
select * from  dhc_workload 
where WorkLoad_OEORI_DR='1982498||9'
'1982498||9'
select cfyl,brid,cfnr,* from infoMZCF where cfid='1982498||5' order by cfcjsj
cfid='1987342||52'
*/  
  

