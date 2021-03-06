USE [MPEHR]
GO
/****** Object:  StoredProcedure [dbo].[p_RunZy]    Script Date: 07/01/2016 11:58:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter ProceDure [dbo].[p_RunZy] 
As
Begin

Declare @Startdate varchar(10),@Enddate varchar(10)
Set @Startdate=CONVERT(varchar(10),dateAdd(dd,-30,getdate()),120)
Set @Enddate=CONVERT(varchar(10),getdate(),120) 

/*********************************            
1、提取用户基本信息
**********************************/         
begin try  
  Exec p_ysks_Etl
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'提取用户基本信息p_ysks_Etl',ERROR_MESSAGE())           
end Catch   
/*********************************            
2、提取患者基本信息
**********************************/         
begin try  
  Exec ProcTM_HL_Hzxxb_zy @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'提取患者基本信息ProcTM_HL_Hzxxb',ERROR_MESSAGE())           
end Catch   


--/*********************************            
--3、提取患者诊断基本信息
--**********************************/         
--begin try  
--  Exec ETL_ZDXX @Startdate,@Enddate
--end Try          
--begin catch      
-- insert into error_Log(Error_date,error_step,error_text)           
-- values(getdate(),'提取患者诊断信息ETL_ZDXX',ERROR_MESSAGE())           
--end Catch
End 
/*
exec ETL_ZDXX '2015-03-01','2015-03-31'
select * from error_Log
truncate table error_Log
select * from THzxxb order by ryDate desc
*/


