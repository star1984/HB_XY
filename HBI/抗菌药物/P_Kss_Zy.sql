USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[P_Kss_Zy]    Script Date: 05/21/2015 11:36:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER ProceDure [dbo].[P_Kss_Zy]     
as    
Begin    
Declare @Startdate varchar(10),@Enddate varchar(10)    
Set @Startdate=convert(varchar(10),dateAdd(day,-60,getdate()),120)    
Set @Enddate=convert(varchar(10),getdate() ,120)  
--set   @Startdate='2015-04-01'
--set   @enddate='2015-07-19'
    
   /*********************************     
    1、提取门急诊病人处方信息   exec  P_Kss_Zy
   **********************************/     
  begin try        
    Exec K_ETL_Cf @Startdate,@Enddate      
  end Try                
  begin catch            
   insert into error_Log(Error_date,error_step,error_text)                 
   values(getdate(),'提取门急诊病人处方信息K_ETL_Cf',ERROR_MESSAGE())                 
  end Catch      
  --/*********************************                  
  --  2、提取门急诊住院病人基本信息    
  -- **********************************/               
  --begin try        
  --  Exec K_ETL_brjbxx @Startdate,@Enddate      
  --end Try                
  --begin catch            
  -- insert into error_Log(Error_date,error_step,error_text)                 
  -- values(getdate(),'提取门急诊病人基本信息K_ETL_brjbxx',ERROR_MESSAGE())                 
  --end Catch       
  /*********************************      
    3、计算各药房处方张数、处方金额    
   **********************************/      
  begin try        
    Exec K_ETL_yfcf @Startdate,@Enddate      
  end Try                
  begin catch            
   insert into error_Log(Error_date,error_step,error_text)                 
   values(getdate(),'计算各药房处方张数、处方金额K_ETL_yfcf',ERROR_MESSAGE())                 
  end Catch    
  -- /*********************************      
  --  4、计算科室医生药品类别相关数据(原科室医生基础上按药品及药品类别统计)    
  -- **********************************/     
  --begin try        
  --  Exec Js_K_ks_ys_yplb @Startdate,@Enddate      
  --end Try                
  --begin catch            
  -- insert into error_Log(Error_date,error_step,error_text)                 
  -- values(getdate(),'计算科室医生药品类别Js_K_ks_ys_yplb',ERROR_MESSAGE())                 
  --end Catch    
   /*********************************                  
    5、计算科室医生药品相关数据    
   **********************************/               
  begin try        
    Exec Js_K_ks_ys_yp @Startdate,@Enddate      
  end Try                
  begin catch            
   insert into error_Log(Error_date,error_step,error_text)                 
   values(getdate(),'计算科室医生药品相关数据Js_K_ks_ys_yp',ERROR_MESSAGE())                 
  end Catch      
  -- /*********************************     
  --  6、提取患者用药明细    
  -- **********************************/     
  --begin try        
  --  Exec K_ETL_YyMX @Startdate,@Enddate      
  --end Try                
  --begin catch            
  -- insert into error_Log(Error_date,error_step,error_text)                 
  -- values(getdate(),'提取患者用药明细K_ETL_YyMX',ERROR_MESSAGE())                 
  --end Catch      
  -- /*********************************     
  --  6、提取医疗总费用数据    
  -- **********************************/     
  --begin try        
  --  Exec K_ETL_hzfyhzb @Startdate,@Enddate      
  --end Try                
  --begin catch            
  -- insert into error_Log(Error_date,error_step,error_text)                 
  -- values(getdate(),'提取医疗总费用数据K_ETL_hzfyhzb',ERROR_MESSAGE())                 
  --end Catch  

  -- /*********************************     
  --  7、提取患者手术信息 
  -- **********************************/     
  --begin try        
  --  Exec K_ETL_Brss @Startdate,@Enddate      
  --end Try                
  --begin catch            
  -- insert into error_Log(Error_date,error_step,error_text)                 
  -- values(getdate(),'提取患者手术信息K_ETL_Brss',ERROR_MESSAGE())                 
  --end Catch      
   /*********************************     
    8、提取维表数据    
   **********************************/     
  begin try        
    Exec K_ETL_Wb     
  end Try                
  begin catch            
   insert into error_Log(Error_date,error_step,error_text)     
   values(getdate(),'提取维表数据K_ETL_Wb',ERROR_MESSAGE())     
  end Catch  
  --/*********************************     
  --9、提取住院患者用药明细
  -- **********************************/     
  --begin try        
  --  EXEC [K_HzyyMx] @Startdate,@Enddate 
  --end Try                
  --begin catch            
  -- insert into error_Log(Error_date,error_step,error_text)     
  -- values(getdate(),'提取住院患者用药明细[K_HzyyMx]',ERROR_MESSAGE())     
  --end Catch    
  --  /*********************************     
  --10、提取手术关联医嘱抗生素明细信息
  -- **********************************/     
  --begin try        
  --  EXEC [ETL_k_ssyz]  @Startdate,@Enddate 
  --end Try                
  --begin catch            
  -- insert into error_Log(Error_date,error_step,error_text)     
  -- values(getdate(),'提取手术关联医嘱抗生素明细信息[ETL_k_ssyz]',ERROR_MESSAGE())     
  --end Catch    

  --  /*********************************     
  --11、提取LIS药敏结果信息
  -- **********************************/     
  --begin try        
  --  EXEC K_ETL_Nyjg  @Startdate,@Enddate 
  --end Try                
  --begin catch            
  -- insert into error_Log(Error_date,error_step,error_text)     
  -- values(getdate(),'提取LIS药敏结果信息[K_ETL_Nyjg]',ERROR_MESSAGE())     
  --end Catch   
  --   /*********************************      
  --12、计算科室医生相关数据(原科室医生表)    
  -- **********************************/     
  --begin try        
  --  Exec [Js_K_ks_ys] @Startdate,@Enddate      
  --end Try                
  --begin catch            
  -- insert into error_Log(Error_date,error_step,error_text)                 
  -- values(getdate(),'计算科室医生Js_K_ks_ys',ERROR_MESSAGE())                 
  --end Catch    
       
End    


