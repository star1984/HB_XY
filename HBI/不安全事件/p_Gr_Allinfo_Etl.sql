USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[p_Gr_Allinfo_Etl]    Script Date: 10/20/2016 20:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER ProceDure [dbo].[p_Gr_Allinfo_Etl] 
As
Begin
Declare @Startdate varchar(10),@Enddate varchar(10)
Set @Startdate=CONVERT(varchar(10),dateAdd(MM,-2,getdate()),120) 
Set @Enddate=CONVERT(varchar(10),getdate(),120) 


/*********************************            
0、住院患者明细表
**********************************/         
begin try  
  Exec P_zyhzmxb @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'住院患者明细表P_zyhzmxb',ERROR_MESSAGE())           
end Catch  

/*
 
/*********************************            
2、给药差错
**********************************/         
begin try  
  Exec p_blsj_Gycc_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'给药差错p_blsj_Gycc_Etl',ERROR_MESSAGE())           
end Catch
/*********************************            
3、输血反应
**********************************/         
begin try  
  Exec p_blsj_Sxfy_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'输血反应p_blsj_Sxfy_Etl',ERROR_MESSAGE())           
end Catch  
/*********************************            
4、投诉纠纷
**********************************/         
begin try  
  Exec p_blsj_Tsjf_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'投诉纠纷p_blsj_Tsjf_Etl',ERROR_MESSAGE())           
end Catch  
/*********************************            
5、饮食差错
**********************************/         
begin try  
  Exec p_blsj_Yscc_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'饮食差错p_blsj_Yscc_Etl',ERROR_MESSAGE())           
end Catch
/*********************************            
6、意外不良
**********************************/         
begin try  
  Exec p_blsj_Ywbl_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'意外不良p_blsj_Ywbl_Etl',ERROR_MESSAGE())           
end Catch
/*********************************            
7、用血错误
**********************************/         
begin try  
  Exec p_blsj_Yxcw_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'用血错误p_blsj_Yxcw_Etl',ERROR_MESSAGE())           
end Catch


*/

/*********************************            
1、管路滑脱上报
**********************************/         
begin try  
  Exec p_blsj_Glht_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'管路滑脱上报p_blsj_Glht_Etl',ERROR_MESSAGE())           
end Catch  

/*********************************            
2、杏林感染上报数据
**********************************/         
begin try  
  Exec p_gr_grinfo_Etl2
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'杏林感染上报数据p_gr_grinfo_Etl2',ERROR_MESSAGE())           
end Catch  

/*********************************            
3、职业暴露
**********************************/         
begin try  
  Exec p_blsj_zybl_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'职业暴露p_blsj_zybl_Etl',ERROR_MESSAGE())           
end Catch

/*********************************            
9、压疮上报
**********************************/         
begin try  
  Exec P_GetYC @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'压疮上报P_GetYC',ERROR_MESSAGE())           
end Catch  

/*********************************            
10、跌倒上报
**********************************/         
begin try  
  Exec P_GetDiedao @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'跌倒上报P_GetDiedao',ERROR_MESSAGE())           
end Catch  

/*********************************            
11、质控办不良事件综合上报
**********************************/         
begin try  
  Exec p_TSf_blsj_XY @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'质控办不良事件综合上报p_TSf_blsj_XY',ERROR_MESSAGE())           
end Catch 

/*********************************            
12、投诉纠纷不良事件综合上报
**********************************/         
begin try  
  Exec p_TSf_tsjf_XY @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'投诉纠纷不良事件综合上报p_TSf_tsjf_XY',ERROR_MESSAGE())           
end Catch 


/*********************************            
13、院外医疗纠纷上报
**********************************/         
begin try  
  Exec p_Ywyljfsb_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'院外医疗纠纷上报p_Ywyljfsb_Etl',ERROR_MESSAGE())           
end Catch   

/*********************************            
14、特殊患者登记上报
**********************************/         
begin try  
  Exec p_Tshzdj_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'特殊患者登记上报p_Tshzdj_Etl',ERROR_MESSAGE())           
end Catch   

/*********************************            
15、管道风险评估
**********************************/         
begin try  
  Exec p_gdpg_XY @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'管道风险评估p_gdpg_XY',ERROR_MESSAGE())           
end Catch  

/*********************************            
16、自杀风险评估
**********************************/         
begin try  
  Exec p_Hzzsfxpg_XY @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'自杀风险评估p_Hzzsfxpg_XY',ERROR_MESSAGE())           
end Catch  

/*********************************            
17、走失风险评估
**********************************/         
begin try  
  Exec p_Hzzsfxpgb_XY @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'走失风险评估p_Hzzsfxpgb_XY',ERROR_MESSAGE())           
end Catch  

/*********************************            
18、可疑器械不良事件上报
**********************************/         
begin try  
  Exec p_Kyylqxblsjbg_Etl @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'可疑器械不良事件上报p_Kyylqxblsjbg_Etl',ERROR_MESSAGE())           
end Catch  

/*********************************            
19、护理部不良事件综合事实表
**********************************/         
begin try  
  Exec p_blsjtj_hlb @Startdate,@Enddate
end Try          
begin catch      
 insert into error_Log(Error_date,error_step,error_text)           
 values(getdate(),'护理部不良事件综合事实表p_blsjtj_hlb',ERROR_MESSAGE())           
end Catch  



--------------------------------------感染分析的需要编写

End 
/*
	select * from error_Log
truncate table error_Log
exec p_Gr_Allinfo_Etl 

select * from BRXXB
select * from mpehr_hl..thzxxb order by rydate desc
*/
