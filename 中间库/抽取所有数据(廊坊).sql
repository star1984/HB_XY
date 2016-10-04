USE [hbidata]
GO
/****** Object:  StoredProcedure [dbo].[P_AllData_ETL]    Script Date: 03/15/2016 17:08:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_AllData_ETL]
   @StartDate varchar(10), @EndDate varchar(10)

As
Begin
DECLARE @S DATETIME,@E DATETIME


Select @S=GetDate()
  Exec P_Dictionary_ETL   -- 字典表
Select @E=GetDate()
Exec P_GetDateTime_Interval '字典表', @S, @E 
 
---- HIS病人在科记录 (后面的会用到此表，所以要放到前面抽取)
--Select @S=GetDate()  -- 从在科记录计算转科记录并不准确，所以转科记录改为直接抽取

--begin try      
--  exec  P_infoBrzkjl_ETL @StartDate, @EndDate         
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'HIS病人在科记录(P_infoBrzkjl_ETL)',ERROR_MESSAGE())               
--end Catch   
 
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS病人在科记录', @S, @E


-- HIS病人医嘱信息
Select @S=GetDate() 

begin try      
   Exec P_infoBryz_ETL @StartDate, @EndDate   
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS病人医嘱信息(P_infoBryz_ETL)',ERROR_MESSAGE())               
end Catch 

Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS病人医嘱信息',@S, @E

-- HIS住院收费
Select @S=GetDate()  

begin try      
  Exec P_infoZYSF_ETL @StartDate, @EndDate    
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS住院收费表(P_infoZYSF_ETL)',ERROR_MESSAGE())               
end Catch  
  
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS住院收费',@S, @E

-- HIS入院登记表  
Select @S=GetDate() 

begin try      
  Exec P_infoRYDJB_ETL @StartDate, @EndDate        
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS入院登记表(P_infoRYDJB_ETL)',ERROR_MESSAGE())               
end Catch
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS入院登记表',@S, @E


-- 嘉禾电子病历患者诊断信息
Select @S=GetDate() 

begin try      
  Exec P_WB_ZDXX @StartDate, @EndDate        
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'嘉禾电子病历患者诊断信息(P_WB_ZDXX)',ERROR_MESSAGE())               
end Catch
  
Select @E=GetDate()
Exec P_GetDateTime_Interval '嘉禾电子病历患者诊断信息',@S, @E

 --HIS病人转科记录
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

--HIS病人在科记录计算
Select @S=GetDate()  

begin try      
  Exec P_infoBrzkjl_js        
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS病人在科记录计算(P_infoBrzkjl_js)',ERROR_MESSAGE())               
end Catch
    
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS病人在科记录计算',@S, @E 




-- HIS门诊挂号表
Select @S=GetDate() 

begin try      
  exec   P_infoMZGH_ETL @StartDate, @EndDate       
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS门诊挂号表(P_infoMZGH_ETL)',ERROR_MESSAGE())               
end Catch    
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS门诊挂号表',@S, @E

-- HIS门诊病人收费表
Select @S=GetDate() 
 
begin try      
  Exec P_infoMZSF_ETL @StartDate, @EndDate       
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS门诊病人收费表(P_infoMZSF_ETL)',ERROR_MESSAGE())               
end Catch  
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS门诊病人收费表',@S, @E





/* 已转入P_AllData_ETL2，备注：2015-05-25*/
--Select @S=GetDate()  
--  Exec P_infoBrZhuankJL_ETL @StartDate, @EndDate-- HIS病人转科记录
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS病人转科记录',@S, @E

-- HIS手术申请单
Select @S=GetDate()
 
begin try      
  Exec P_infoBrsssqd_ETL @StartDate, @EndDate   
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS手术申请单(P_infoBrsssqd_ETL)',ERROR_MESSAGE())               
end Catch  
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS手术申请单',@S, @E

---- HIS手麻记录
--Select @S=GetDate() 

--begin try      
--  Exec P_infoBRSMJL_ETL @StartDate, @EndDate  
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'HIS手麻记录(P_infoBRSMJL_ETL)',ERROR_MESSAGE())               
--end Catch 
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS手麻记录',@S, @E

---- HIS首页手术记录
--Select @S=GetDate()  

--begin try      
--  Exec P_infoBRSYSSJL_ETL @StartDate, @EndDate    
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'HIS首页手术记录(P_infoBRSYSSJL_ETL)',ERROR_MESSAGE())               
--end Catch 

  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS首页手术记录',@S, @E

----Select @S=GetDate()  
----  Exec P_infoSSYYJL_ETL @StartDate, @EndDate -- 手麻用药信息
----Select @E=GetDate()
----Exec P_GetDateTime_Interval '手麻用药信息',@S, @E
----Select @S=GetDate()  
----  Exec P_infoBrscd_ETL @StartDate, @EndDate -- HIS病人护理三测单
----Select @E=GetDate()
----Exec P_GetDateTime_Interval 'HIS病人护理三测单',@S, @E

-- HIS门诊处方
Select @S=GetDate() 

begin try      
  Exec P_infoMZCF_ETL @StartDate, @EndDate  
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS门诊处方(P_infoMZCF_ETL)',ERROR_MESSAGE())               
end Catch 
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS门诊处方',@S, @E

-- HIS药房发药记录
Select @S=GetDate()

begin try      
  Exec P_infoYFSFJL_ETL @StartDate, @EndDate  
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS药房发药记录(P_infoYFSFJL_ETL)',ERROR_MESSAGE())               
end Catch   
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS药房发药记录',@S, @E




---- HIS医嘱执行信息
--Select @S=GetDate()  

--begin try      
--   Exec P_infoYZZX_ETL @StartDate, @EndDate   
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'HIS医嘱执行信息(P_infoYZZX_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS医嘱执行信息',@S, @E

--Select @S=GetDate()  
--  Exec P_infoMZYFFYJL_ETL @StartDate, @EndDate -- HIS门诊药房发药记录 (已改为包含在HIS药房发药记录中抽取）
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS门诊药房发药记录',@S, @E
--Select @S=GetDate()  
--  Exec P_infoZYYFFYJL_ETL @StartDate, @EndDate -- HIS住院药房发药记录 (已改为包含在HIS药房发药记录中抽取）
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS住院药房发药记录',@S, @E

---- 读取EMR临床路径抽取
--Select @S=GetDate()  

--begin try      
--  Exec P_infoLCLJ_ETL @StartDate, @EndDate   
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'读取EMR临床路径抽取(P_infoLCLJ_ETL)',ERROR_MESSAGE())               
--end Catch

--Select @E=GetDate()
--Exec P_GetDateTime_Interval '读取EMR临床路径抽取',@S, @E

--Select @S=GetDate()  
--  Exec P_infoJyjbxx_ETL @StartDate, @EndDate -- LIS检验基本信息
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'LIS检验基本信息',@S, @E
--Select @S=GetDate()  
--  Exec P_infoJyjg_ETL @StartDate, @EndDate -- LIS检验结果
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'LIS检验结果',@S, @E
--Select @S=GetDate()  
--  Exec P_infoYmjg_ETL @StartDate, @EndDate -- LIS药敏结果
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'LIS药敏结果',@S, @E

---- 病案信息抽取

--Select @S=GetDate()  

--begin try      
--  Exec P_VsCH0A_ETL @StartDate, @EndDate -- 病案基本信息A表
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'病案基本信息A表(P_VsCH0A_ETL)',ERROR_MESSAGE())               
--end Catch  
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '病案基本信息A表',@S, @E

---- 病案费用信息B表
--Select @S=GetDate()  

--begin try      
--  Exec P_VsCH0B_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'病案费用信息B表(P_VsCH0B_ETL)',ERROR_MESSAGE())               
--end Catch 
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '病案费用信息B表',@S, @E

---- 病案次诊断信息C表
--Select @S=GetDate() 

--begin try      
--  Exec P_VsCH0C_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'病案次诊断信息C表(P_VsCH0C_ETL)',ERROR_MESSAGE())               
--end Catch 
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '病案次诊断信息C表',@S, @E

---- 病案手术信息E表
--Select @S=GetDate()  

--begin try      
--  Exec P_VsCH0E_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'病案手术信息E表(P_VsCH0E_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '病案手术信息E表',@S, @E

---- 患者安全信息P表
--Select @S=GetDate()  

--begin try      
--  Exec P_VsCH0P_ETL @StartDate, @EndDate  
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'患者安全信息P表(P_VsCH0P_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '患者安全信息P表',@S, @E

---- 住院工作日志信息
--Select @S=GetDate()  

--begin try      
--  Exec P_VsTjZy_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'住院工作日志信息(P_VsTjZy_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '住院工作日志信息',@S, @E


---- 门诊工作日志信息
--Select @S=GetDate()  

--begin try      
--  Exec P_VsTjmz_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'门诊工作日志信息(P_VsTjmz_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '门诊工作日志信息',@S, @E  

--------------------------------------------------护理------------------------
---- 压疮评分
--Select @S=GetDate()  

--begin try      
--  Exec P_ycpf_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'压疮评分(P_ycpf_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '压疮评分',@S, @E  


---- 跌倒评分
--Select @S=GetDate()  

--begin try      
--  Exec P_diedaopf_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'跌倒评分(P_diedaopf_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '跌倒评分',@S, @E  

--Select @S=GetDate()  
--  Exec P_infobrEmrML_ETL @StartDate, @EndDate -- 电子病历目录
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '电子病历目录', @S, @E

--Select @S=GetDate()  
--  Exec P_infobrEmrText_ETL @StartDate, @EndDate -- 电子病历文本数据
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '电子病历文本数据',@S, @E 

--清理日志    
ALTER DATABASE HBIData SET RECOVERY SIMPLE WITH NO_WAIT     
ALTER DATABASE HBIData SET RECOVERY SIMPLE      
  DBCC SHRINKFILE (N'HBIData_log' , 11, TRUNCATEONLY)--先收缩日志文件     
ALTER DATABASE HBIData SET RECOVERY FULL WITH NO_WAIT    
ALTER DATABASE HBIData SET RECOVERY FULL WITH NO_WAIT   

End
/*
Exec P_AllData_ETL '2014-12-01', '2014-12-10'
*/