USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[P_00_GetDataAll]    Script Date: 07/07/2016 14:29:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_00_GetDataAll]   
   
AS  
BEGIN  

 DECLARE @StartDate VARCHAR(10), @EndDate VARCHAR(10)
 
 SET @EndDate=CONVERT(VARCHAR(10),GETDATE(),120) 
 
 SET @StartDate=CONVERT(VARCHAR(10),DATEADD(dd,-60,@EndDate),120) 
 
--抽取手填的资源配置(员工基建数据)
begin try      
  exec  P_Hresource @StartDate, @EndDate         
end Try              
begin catch              
 insert into error_Log(error_Date,error_step,error_text)               
 values(getdate(),'抽取资源配置(人力基建数据)(P_Hresource)',ERROR_MESSAGE())               
end Catch 




 /* 
 --处理维表数据  
 EXEC p_etl_GetLjJbbm--更新路径对应诊断码信息  
   

----病案--------------------------------------------------------------------
 EXEC P_09_Etl_GetZDSS @StartDate,@EndDate-- 统计18种重点手术信息  
 EXEC P_10_Etl_GetZDJB @StartDate,@EndDate-- 统计18种重点疾病信息  
  
 EXEC P_11_Sjps_ba @StartDate,@EndDate-- 提取病案首页患者基本信息事实表数据  
 EXEC P_12_BA_GetVsch0E @StartDate,@EndDate-- 病案首页手术E表抽取脚本  
  
 EXEC P_13_Etl_VsMzLog  @StartDate,@EndDate--门诊工作日志统计  
  
  ----HIS-------------------------------------------------------------- 
 EXEC P_14_bigDatainfo04  @StartDate,@EndDate--门诊病人挂号及用药信息  
 EXEC P_15_bigDatainfo05  @StartDate,@EndDate--门诊、住院医疗收入信息  
 exec p_16_Etl_mzpage @StartDate,@EndDate--抽取门诊首页mzpage数据      
    
 exec P_17_Etl_GetYC @StartDate,@EndDate--压疮数据      
 EXEC P_18_GetFyJL_YP @StartDate,@EndDate-- 获取门诊住院用药/发药记录   
         
 Exec P_20_VsTjZy_ETL  @StartDate,@EndDate --住院日志统计  
 EXEC P_21_Info_nclj02 @StartDate,@EndDate--临床路径  
 
 ----院感------------------------------------------------------------------
 EXEC P_19_ETL_GetSSGR_2 @StartDate,@EndDate --感染信息
 EXEC P_19_ETL_GetSSGR_3 @StartDate,@EndDate



/*
----单病种、不良事件--------------------------------------------------
	EXEC P_01_ETL_AMI_ 	@StartDate,@EndDate
	EXEC P_02_ETL_CABG_ 	@StartDate,@EndDate
	EXEC P_03_ETL_CAP_	@StartDate,@EndDate
	EXEC P_03_ETL_CAP2_	@StartDate,@EndDate
	EXEC P_03_ETL_COPD_	@StartDate,@EndDate
	EXEC P_03_ETL_DVT_	@StartDate,@EndDate
	EXEC P_04_ETL_HF_	@StartDate,@EndDate
	EXEC P_05_ETL_HIP_	@StartDate,@EndDate
	EXEC P_05_ETL_KNEE_	@StartDate,@EndDate
	EXEC P_05_ETL_PIP_	@StartDate,@EndDate
	EXEC P_06_ETL_STK_	@StartDate,@EndDate
	
	EXEC P_07_ETL_DDZC3	@StartDate,@EndDate
	EXEC P_07_ETL_DDZC4	@StartDate,@EndDate 
*/
END  