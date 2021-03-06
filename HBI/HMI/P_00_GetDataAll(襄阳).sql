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
 
----抽取手填的资源配置(员工基建数据)
--begin try      
--  exec  P_Hresource @StartDate, @EndDate         
--end Try              
--begin catch              
-- insert into error_Log(error_Date,error_step,error_text)               
-- values(getdate(),'抽取资源配置(人力基建数据)(P_Hresource)',ERROR_MESSAGE())               
--end Catch 

--抗菌药物系统数据抽取，用于合理用药
begin try      
  exec  P_Kss_Zy      
end Try              
begin catch              
 insert into error_Log(error_Date,error_step,error_text)               
 values(getdate(),'抗菌药物系统数据抽取(P_Kss_Zy)',ERROR_MESSAGE())               
end Catch 


--单病种数据抽取存储过程 
  --单病种3存储过程
  begin try      
  exec  P_InsDBZ3Data      
  end Try              
  begin catch              
   insert into error_Log(error_Date,error_step,error_text)               
   values(getdate(),'单病种3存储过程(P_InsDBZ3Data)',ERROR_MESSAGE())               
  end Catch 
  
  ----单病种已上报未上报查询
  --begin try      
  -- exec  P_DBZWSBYLB  @StartDate, @EndDate   
  --end Try              
  --begin catch              
  -- insert into error_Log(error_Date,error_step,error_text)               
  -- values(getdate(),'单病种已上报未上报查询(P_DBZWSBYLB)',ERROR_MESSAGE())               
  --end Catch 
  
  --字典表
  begin try      
   exec  ProcTM_GetWB      
  end Try              
  begin catch              
   insert into error_Log(error_Date,error_step,error_text)               
   values(getdate(),'单病种3字典表存储过程(ProcTM_GetWB)',ERROR_MESSAGE())               
  end Catch 
  

--门急诊挂号人次及费用计算
 begin try      
   exec  P_bigDatainfo04   @StartDate, @EndDate   
  end Try              
  begin catch              
   insert into error_Log(error_Date,error_step,error_text)               
   values(getdate(),'门急诊挂号人次及费用计算(P_bigDatainfo04)',ERROR_MESSAGE())               
  end Catch 
  
  
--麦迪斯顿三甲评审麻醉指标抽取（默认取本月及上月的整月数据）
 begin try      
   exec  P_HMIdocare_ETL   
  end Try              
  begin catch              
   insert into error_Log(error_Date,error_step,error_text)               
   values(getdate(),'麦迪斯顿三甲评审麻醉指标抽取(P_HMIdocare_ETL)',ERROR_MESSAGE())               
  end Catch 
  
  
  


END  