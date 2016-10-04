IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_AllData_ETL2' AND type = 'P')
   DROP PROCEDURE P_AllData_ETL2
GO

Create PROCEDURE P_AllData_ETL2
   @StartDate varchar(10), @EndDate varchar(10)

As
Begin
  Declare @S datetime, @E datetime, @BigStartDate varchar(10)
  Set @BigStartDate=Convert(varchar(10), DateAdd(dd, -31, Convert(DateTime, @StartDate)), 120)

-- �ֵ��  
Select @S=GetDate()

begin try      
  Exec P_Dictionary_ETL          
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'�ֵ��(P_Dictionary_ETL)',ERROR_MESSAGE())               
end Catch  
  
Select @E=GetDate()
Exec P_GetDateTime_Interval '�ֵ��', @S, @E  

-- HIS��Ժ�ǼǱ�  
Select @S=GetDate() 

begin try      
  Exec P_infoRYDJB_ETL @BigStartDate, @EndDate        
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS��Ժ�ǼǱ�(P_infoRYDJB_ETL)',ERROR_MESSAGE())               
end Catch
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS��Ժ�ǼǱ�',@S, @E

-- HIS����ת�Ƽ�¼
Select @S=GetDate()  

begin try      
  Exec P_infoBrZhuankJL_ETL @StartDate, @EndDate        
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS����ת�Ƽ�¼(P_infoBrZhuankJL_ETL)',ERROR_MESSAGE())               
end Catch
    
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS����ת�Ƽ�¼',@S, @E 
  
-- HIS���˻������ⵥ   
Select @S=GetDate()  

begin try      
  Exec P_infoBrscd_ETL @StartDate, @EndDate      
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS���˻������ⵥ(P_infoBrscd_ETL)',ERROR_MESSAGE())               
end Catch
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS���˻������ⵥ',@S, @E

-- LIS���������Ϣ
Select @S=GetDate() 

begin try      
  Exec P_infoJyjbxx_ETL @StartDate, @EndDate    
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'LIS���������Ϣ(P_infoJyjbxx_ETL)',ERROR_MESSAGE())               
end Catch 
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'LIS���������Ϣ',@S, @E

-- LIS������
Select @S=GetDate() 
 
begin try      
  Exec P_infoJyjg_ETL @StartDate, @EndDate   
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'LIS������(P_infoJyjg_ETL)',ERROR_MESSAGE())               
end Catch 
   
Select @E=GetDate()
Exec P_GetDateTime_Interval 'LIS������',@S, @E

-- LISҩ�����
Select @S=GetDate()

begin try      
  Exec P_infoYmjg_ETL @StartDate, @EndDate -- LISҩ����� 
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'LISҩ�����(P_infoYmjg_ETL)',ERROR_MESSAGE())               
end Catch   

Select @E=GetDate()
Exec P_GetDateTime_Interval 'LISҩ�����',@S, @E

-- �����ڿƴ�λ��Ϣ
Select @S=GetDate() 
  
begin try      
  Exec P_infoBrzkcwjl_ETL @StartDate, @EndDate -- �����ڿƴ�λ��Ϣ 
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'�����ڿƴ�λ��Ϣ(P_infoBrzkcwjl_ETL)',ERROR_MESSAGE())               
end Catch 
    
Select @E=GetDate()
Exec P_GetDateTime_Interval '�����ڿƴ�λ��Ϣ',@S, @E

--�������������¼add by Waj 2015-04-23    
Select @S=GetDate() 

begin try      
  Exec P_infoBRSMJL_ETL   @StartDate, @EndDate    
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'�������������¼(P_infoBRSMJL_ETL)',ERROR_MESSAGE())               
end Catch   
 
Select @E=GetDate()   
Exec P_GetDateTime_Interval '�������������¼',@S, @E     

---- RIS����� add by Waj 2015-05-15   

Select @S=GetDate()  

begin try      
  Exec P_infoRisJG_ETL   @StartDate, @EndDate    
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'RIS�����(P_infoRisJG_ETL)',ERROR_MESSAGE())               
end Catch
 
Select @E=GetDate()   
Exec P_GetDateTime_Interval ' RIS�����',@S, @E  

--HIS������Ϣadd by Waj 2015-05-16   

Select @S=GetDate() 

begin try      
  Exec P_infoRyxxb_ETL   @StartDate, @EndDate      
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS������Ϣ(P_infoRyxxb_ETL)',ERROR_MESSAGE())               
end Catch

Select @E=GetDate()   
Exec P_GetDateTime_Interval ' HIS������Ϣ ',@S, @E  


--������㵥add by hzf 2015-06-09  
Select @S=GetDate() 

begin try      
  Exec P_infoBRSSQDD_ETL   @StartDate, @EndDate      
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'������㵥(P_infoBRSSQDD_ETL)',ERROR_MESSAGE())               
end Catch   
 
Select @E=GetDate()   
Exec P_GetDateTime_Interval ' ������㵥 ',@S, @E  


   
----�ٴ���Ѫ�ʿ�ϵͳ add by fy 2015-05-11������WAJ 2015-05-28
--ҽ�ƻ�����Ѫ�������
Select @S=GetDate() 

begin try      
  Exec P_InfoYljgyxqkfx_ETL   @StartDate, @EndDate     
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'ҽ�ƻ�����Ѫ�������(P_InfoYljgyxqkfx_ETL)',ERROR_MESSAGE())               
end Catch   

Select @E=GetDate() 
Exec P_GetDateTime_Interval 'ҽ�ƻ�����Ѫ�������',@S, @E  

--ѪҺ�շ����
Select @S=GetDate() 
begin try      
  exec P_InfoXYSFQK_ETL @StartDate, @EndDate      
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'ѪҺ�շ����(P_InfoXYSFQK_ETL)',ERROR_MESSAGE())               
end Catch  

Select @E=GetDate() 
Exec P_GetDateTime_Interval 'ѪҺ�շ����',@S, @E  


--��Ѫ��Ѫ�������
Select @S=GetDate() 

begin try      
  exec P_Info_SXKXKKC_ETL @StartDate, @EndDate     
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'��Ѫ��Ѫ�������(P_Info_SXKXKKC_ETL)',ERROR_MESSAGE())               
end Catch  

Select @E=GetDate()  
Exec P_GetDateTime_Interval '��Ѫ��Ѫ�������',@S, @E  

--ѪҺ�������
Select @S=GetDate() 

begin try      
  exec P_infoXYSY_ETL @StartDate, @EndDate  
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'ѪҺ�������(P_infoXYSY_ETL)',ERROR_MESSAGE())               
end Catch  

Select @E=GetDate()  
Exec P_GetDateTime_Interval 'ѪҺ�������',@S, @E  

--ѪҺ���鱨��
Select @S=GetDate() 

begin try      
  exec P_infoXXJYBG_ETL @StartDate, @EndDate 
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'ѪҺ���鱨��(P_infoXXJYBG_ETL)',ERROR_MESSAGE())               
end Catch 

Select @E=GetDate()  
Exec P_GetDateTime_Interval 'ѪҺ���鱨��',@S, @E  

--����ҽ������
Select @S=GetDate()
 
begin try      
  exec P_infoBRYZFJ_ETL  @StartDate, @EndDate 
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'����ҽ������(P_infoBRYZFJ_ETL)',ERROR_MESSAGE())               
end Catch

Select @E=GetDate()  
Exec P_GetDateTime_Interval '����ҽ������',@S, @E  


----���鰲ȫ���������ϵͳ add by fy 2015-05-11������WAJ 2015-05-28

Select @S=GetDate()

begin try      
  exec P_infoSMSJ_ETL @StartDate, @EndDate
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'���鰲ȫ���������������ȡ(P_infoSMSJ_ETL)',ERROR_MESSAGE())               
end Catch

Select @E=GetDate() 
Exec P_GetDateTime_Interval '���鰲ȫ���������������ȡ',@S, @E  



--������־    
ALTER DATABASE HBIData SET RECOVERY SIMPLE WITH NO_WAIT     
ALTER DATABASE HBIData SET RECOVERY SIMPLE      
  DBCC SHRINKFILE (N'HBIData_log' , 11, TRUNCATEONLY)--��������־�ļ�     
ALTER DATABASE HBIData SET RECOVERY FULL WITH NO_WAIT    
ALTER DATABASE HBIData SET RECOVERY FULL WITH NO_WAIT      
      
  
  
  
end