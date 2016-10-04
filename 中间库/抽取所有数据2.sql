IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_AllData_ETL2' AND type = 'P')
   DROP PROCEDURE P_AllData_ETL2
GO

Create PROCEDURE P_AllData_ETL2
   @StartDate varchar(10), @EndDate varchar(10)

As
Begin
  Declare @S datetime, @E datetime, @BigStartDate varchar(10)
  Set @BigStartDate=Convert(varchar(10), DateAdd(dd, -31, Convert(DateTime, @StartDate)), 120)

-- 字典表  
Select @S=GetDate()

begin try      
  Exec P_Dictionary_ETL          
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'字典表(P_Dictionary_ETL)',ERROR_MESSAGE())               
end Catch  
  
Select @E=GetDate()
Exec P_GetDateTime_Interval '字典表', @S, @E  

-- HIS入院登记表  
Select @S=GetDate() 

begin try      
  Exec P_infoRYDJB_ETL @BigStartDate, @EndDate        
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS入院登记表(P_infoRYDJB_ETL)',ERROR_MESSAGE())               
end Catch
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS入院登记表',@S, @E

-- HIS病人转科记录
Select @S=GetDate()  

begin try      
  Exec P_infoBrZhuankJL_ETL @StartDate, @EndDate        
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS病人转科记录(P_infoBrZhuankJL_ETL)',ERROR_MESSAGE())               
end Catch
    
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS病人转科记录',@S, @E 
  
-- HIS病人护理三测单   
Select @S=GetDate()  

begin try      
  Exec P_infoBrscd_ETL @StartDate, @EndDate      
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS病人护理三测单(P_infoBrscd_ETL)',ERROR_MESSAGE())               
end Catch
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS病人护理三测单',@S, @E

-- LIS检验基本信息
Select @S=GetDate() 

begin try      
  Exec P_infoJyjbxx_ETL @StartDate, @EndDate    
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'LIS检验基本信息(P_infoJyjbxx_ETL)',ERROR_MESSAGE())               
end Catch 
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'LIS检验基本信息',@S, @E

-- LIS检验结果
Select @S=GetDate() 
 
begin try      
  Exec P_infoJyjg_ETL @StartDate, @EndDate   
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'LIS检验结果(P_infoJyjg_ETL)',ERROR_MESSAGE())               
end Catch 
   
Select @E=GetDate()
Exec P_GetDateTime_Interval 'LIS检验结果',@S, @E

-- LIS药敏结果
Select @S=GetDate()

begin try      
  Exec P_infoYmjg_ETL @StartDate, @EndDate -- LIS药敏结果 
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'LIS药敏结果(P_infoYmjg_ETL)',ERROR_MESSAGE())               
end Catch   

Select @E=GetDate()
Exec P_GetDateTime_Interval 'LIS药敏结果',@S, @E

-- 病人在科床位信息
Select @S=GetDate() 
  
begin try      
  Exec P_infoBrzkcwjl_ETL @StartDate, @EndDate -- 病人在科床位信息 
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'病人在科床位信息(P_infoBrzkcwjl_ETL)',ERROR_MESSAGE())               
end Catch 
    
Select @E=GetDate()
Exec P_GetDateTime_Interval '病人在科床位信息',@S, @E

--病人手术麻醉记录add by Waj 2015-04-23    
Select @S=GetDate() 

begin try      
  Exec P_infoBRSMJL_ETL   @StartDate, @EndDate    
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'病人手术麻醉记录(P_infoBRSMJL_ETL)',ERROR_MESSAGE())               
end Catch   
 
Select @E=GetDate()   
Exec P_GetDateTime_Interval '病人手术麻醉记录',@S, @E     

---- RIS结果表 add by Waj 2015-05-15   

Select @S=GetDate()  

begin try      
  Exec P_infoRisJG_ETL   @StartDate, @EndDate    
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'RIS结果表(P_infoRisJG_ETL)',ERROR_MESSAGE())               
end Catch
 
Select @E=GetDate()   
Exec P_GetDateTime_Interval ' RIS结果表',@S, @E  

--HIS病人信息add by Waj 2015-05-16   

Select @S=GetDate() 

begin try      
  Exec P_infoRyxxb_ETL   @StartDate, @EndDate      
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS病人信息(P_infoRyxxb_ETL)',ERROR_MESSAGE())               
end Catch

Select @E=GetDate()   
Exec P_GetDateTime_Interval ' HIS病人信息 ',@S, @E  


--手术清点单add by hzf 2015-06-09  
Select @S=GetDate() 

begin try      
  Exec P_infoBRSSQDD_ETL   @StartDate, @EndDate      
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'手术清点单(P_infoBRSSQDD_ETL)',ERROR_MESSAGE())               
end Catch   
 
Select @E=GetDate()   
Exec P_GetDateTime_Interval ' 手术清点单 ',@S, @E  


   
----临床用血质控系统 add by fy 2015-05-11，整理：WAJ 2015-05-28
--医疗机构用血情况分析
Select @S=GetDate() 

begin try      
  Exec P_InfoYljgyxqkfx_ETL   @StartDate, @EndDate     
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'医疗机构用血情况分析(P_InfoYljgyxqkfx_ETL)',ERROR_MESSAGE())               
end Catch   

Select @E=GetDate() 
Exec P_GetDateTime_Interval '医疗机构用血情况分析',@S, @E  

--血液收费情况
Select @S=GetDate() 
begin try      
  exec P_InfoXYSFQK_ETL @StartDate, @EndDate      
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'血液收费情况(P_InfoXYSFQK_ETL)',ERROR_MESSAGE())               
end Catch  

Select @E=GetDate() 
Exec P_GetDateTime_Interval '血液收费情况',@S, @E  


--输血科血库库存情况
Select @S=GetDate() 

begin try      
  exec P_Info_SXKXKKC_ETL @StartDate, @EndDate     
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'输血科血库库存情况(P_Info_SXKXKKC_ETL)',ERROR_MESSAGE())               
end Catch  

Select @E=GetDate()  
Exec P_GetDateTime_Interval '输血科血库库存情况',@S, @E  

--血液收益情况
Select @S=GetDate() 

begin try      
  exec P_infoXYSY_ETL @StartDate, @EndDate  
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'血液收益情况(P_infoXYSY_ETL)',ERROR_MESSAGE())               
end Catch  

Select @E=GetDate()  
Exec P_GetDateTime_Interval '血液收益情况',@S, @E  

--血液检验报告
Select @S=GetDate() 

begin try      
  exec P_infoXXJYBG_ETL @StartDate, @EndDate 
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'血液检验报告(P_infoXXJYBG_ETL)',ERROR_MESSAGE())               
end Catch 

Select @E=GetDate()  
Exec P_GetDateTime_Interval '血液检验报告',@S, @E  

--病人医嘱附件
Select @S=GetDate()
 
begin try      
  exec P_infoBRYZFJ_ETL  @StartDate, @EndDate 
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'病人医嘱附件(P_infoBRYZFJ_ETL)',ERROR_MESSAGE())               
end Catch

Select @E=GetDate()  
Exec P_GetDateTime_Interval '病人医嘱附件',@S, @E  


----手麻安全与质量监测系统 add by fy 2015-05-11，整理：WAJ 2015-05-28

Select @S=GetDate()

begin try      
  exec P_infoSMSJ_ETL @StartDate, @EndDate
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'手麻安全与质量监测数据提取(P_infoSMSJ_ETL)',ERROR_MESSAGE())               
end Catch

Select @E=GetDate() 
Exec P_GetDateTime_Interval '手麻安全与质量监测数据提取',@S, @E  



--清理日志    
ALTER DATABASE HBIData SET RECOVERY SIMPLE WITH NO_WAIT     
ALTER DATABASE HBIData SET RECOVERY SIMPLE      
  DBCC SHRINKFILE (N'HBIData_log' , 11, TRUNCATEONLY)--先收缩日志文件     
ALTER DATABASE HBIData SET RECOVERY FULL WITH NO_WAIT    
ALTER DATABASE HBIData SET RECOVERY FULL WITH NO_WAIT      
      
  
  
  
end