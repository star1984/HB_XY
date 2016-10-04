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
  Exec P_Dictionary_ETL   -- �ֵ��
Select @E=GetDate()
Exec P_GetDateTime_Interval '�ֵ��', @S, @E 
 
---- HIS�����ڿƼ�¼ (����Ļ��õ��˱�����Ҫ�ŵ�ǰ���ȡ)
--Select @S=GetDate()  -- ���ڿƼ�¼����ת�Ƽ�¼����׼ȷ������ת�Ƽ�¼��Ϊֱ�ӳ�ȡ

--begin try      
--  exec  P_infoBrzkjl_ETL @StartDate, @EndDate         
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'HIS�����ڿƼ�¼(P_infoBrzkjl_ETL)',ERROR_MESSAGE())               
--end Catch   
 
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS�����ڿƼ�¼', @S, @E


-- HIS����ҽ����Ϣ
Select @S=GetDate() 

begin try      
   Exec P_infoBryz_ETL @StartDate, @EndDate   
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS����ҽ����Ϣ(P_infoBryz_ETL)',ERROR_MESSAGE())               
end Catch 

Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS����ҽ����Ϣ',@S, @E

-- HISסԺ�շ�
Select @S=GetDate()  

begin try      
  Exec P_infoZYSF_ETL @StartDate, @EndDate    
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HISסԺ�շѱ�(P_infoZYSF_ETL)',ERROR_MESSAGE())               
end Catch  
  
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HISסԺ�շ�',@S, @E

-- HIS��Ժ�ǼǱ�  
Select @S=GetDate() 

begin try      
  Exec P_infoRYDJB_ETL @StartDate, @EndDate        
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS��Ժ�ǼǱ�(P_infoRYDJB_ETL)',ERROR_MESSAGE())               
end Catch
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS��Ժ�ǼǱ�',@S, @E


-- �κ̵��Ӳ������������Ϣ
Select @S=GetDate() 

begin try      
  Exec P_WB_ZDXX @StartDate, @EndDate        
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'�κ̵��Ӳ������������Ϣ(P_WB_ZDXX)',ERROR_MESSAGE())               
end Catch
  
Select @E=GetDate()
Exec P_GetDateTime_Interval '�κ̵��Ӳ������������Ϣ',@S, @E

 --HIS����ת�Ƽ�¼
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

--HIS�����ڿƼ�¼����
Select @S=GetDate()  

begin try      
  Exec P_infoBrzkjl_js        
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS�����ڿƼ�¼����(P_infoBrzkjl_js)',ERROR_MESSAGE())               
end Catch
    
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS�����ڿƼ�¼����',@S, @E 




-- HIS����Һű�
Select @S=GetDate() 

begin try      
  exec   P_infoMZGH_ETL @StartDate, @EndDate       
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS����Һű�(P_infoMZGH_ETL)',ERROR_MESSAGE())               
end Catch    
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS����Һű�',@S, @E

-- HIS���ﲡ���շѱ�
Select @S=GetDate() 
 
begin try      
  Exec P_infoMZSF_ETL @StartDate, @EndDate       
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS���ﲡ���շѱ�(P_infoMZSF_ETL)',ERROR_MESSAGE())               
end Catch  
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS���ﲡ���շѱ�',@S, @E





/* ��ת��P_AllData_ETL2����ע��2015-05-25*/
--Select @S=GetDate()  
--  Exec P_infoBrZhuankJL_ETL @StartDate, @EndDate-- HIS����ת�Ƽ�¼
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS����ת�Ƽ�¼',@S, @E

-- HIS�������뵥
Select @S=GetDate()
 
begin try      
  Exec P_infoBrsssqd_ETL @StartDate, @EndDate   
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS�������뵥(P_infoBrsssqd_ETL)',ERROR_MESSAGE())               
end Catch  
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS�������뵥',@S, @E

---- HIS�����¼
--Select @S=GetDate() 

--begin try      
--  Exec P_infoBRSMJL_ETL @StartDate, @EndDate  
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'HIS�����¼(P_infoBRSMJL_ETL)',ERROR_MESSAGE())               
--end Catch 
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS�����¼',@S, @E

---- HIS��ҳ������¼
--Select @S=GetDate()  

--begin try      
--  Exec P_infoBRSYSSJL_ETL @StartDate, @EndDate    
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'HIS��ҳ������¼(P_infoBRSYSSJL_ETL)',ERROR_MESSAGE())               
--end Catch 

  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS��ҳ������¼',@S, @E

----Select @S=GetDate()  
----  Exec P_infoSSYYJL_ETL @StartDate, @EndDate -- ������ҩ��Ϣ
----Select @E=GetDate()
----Exec P_GetDateTime_Interval '������ҩ��Ϣ',@S, @E
----Select @S=GetDate()  
----  Exec P_infoBrscd_ETL @StartDate, @EndDate -- HIS���˻������ⵥ
----Select @E=GetDate()
----Exec P_GetDateTime_Interval 'HIS���˻������ⵥ',@S, @E

-- HIS���ﴦ��
Select @S=GetDate() 

begin try      
  Exec P_infoMZCF_ETL @StartDate, @EndDate  
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HIS���ﴦ��(P_infoMZCF_ETL)',ERROR_MESSAGE())               
end Catch 
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HIS���ﴦ��',@S, @E

-- HISҩ����ҩ��¼
Select @S=GetDate()

begin try      
  Exec P_infoYFSFJL_ETL @StartDate, @EndDate  
end Try              
begin catch              
 insert into error_Log(ZxDate,error_step,error_text)               
 values(getdate(),'HISҩ����ҩ��¼(P_infoYFSFJL_ETL)',ERROR_MESSAGE())               
end Catch   
  
Select @E=GetDate()
Exec P_GetDateTime_Interval 'HISҩ����ҩ��¼',@S, @E




---- HISҽ��ִ����Ϣ
--Select @S=GetDate()  

--begin try      
--   Exec P_infoYZZX_ETL @StartDate, @EndDate   
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'HISҽ��ִ����Ϣ(P_infoYZZX_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HISҽ��ִ����Ϣ',@S, @E

--Select @S=GetDate()  
--  Exec P_infoMZYFFYJL_ETL @StartDate, @EndDate -- HIS����ҩ����ҩ��¼ (�Ѹ�Ϊ������HISҩ����ҩ��¼�г�ȡ��
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HIS����ҩ����ҩ��¼',@S, @E
--Select @S=GetDate()  
--  Exec P_infoZYYFFYJL_ETL @StartDate, @EndDate -- HISסԺҩ����ҩ��¼ (�Ѹ�Ϊ������HISҩ����ҩ��¼�г�ȡ��
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'HISסԺҩ����ҩ��¼',@S, @E

---- ��ȡEMR�ٴ�·����ȡ
--Select @S=GetDate()  

--begin try      
--  Exec P_infoLCLJ_ETL @StartDate, @EndDate   
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'��ȡEMR�ٴ�·����ȡ(P_infoLCLJ_ETL)',ERROR_MESSAGE())               
--end Catch

--Select @E=GetDate()
--Exec P_GetDateTime_Interval '��ȡEMR�ٴ�·����ȡ',@S, @E

--Select @S=GetDate()  
--  Exec P_infoJyjbxx_ETL @StartDate, @EndDate -- LIS���������Ϣ
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'LIS���������Ϣ',@S, @E
--Select @S=GetDate()  
--  Exec P_infoJyjg_ETL @StartDate, @EndDate -- LIS������
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'LIS������',@S, @E
--Select @S=GetDate()  
--  Exec P_infoYmjg_ETL @StartDate, @EndDate -- LISҩ�����
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'LISҩ�����',@S, @E

---- ������Ϣ��ȡ

--Select @S=GetDate()  

--begin try      
--  Exec P_VsCH0A_ETL @StartDate, @EndDate -- ����������ϢA��
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'����������ϢA��(P_VsCH0A_ETL)',ERROR_MESSAGE())               
--end Catch  
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '����������ϢA��',@S, @E

---- ����������ϢB��
--Select @S=GetDate()  

--begin try      
--  Exec P_VsCH0B_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'����������ϢB��(P_VsCH0B_ETL)',ERROR_MESSAGE())               
--end Catch 
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '����������ϢB��',@S, @E

---- �����������ϢC��
--Select @S=GetDate() 

--begin try      
--  Exec P_VsCH0C_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'�����������ϢC��(P_VsCH0C_ETL)',ERROR_MESSAGE())               
--end Catch 
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '�����������ϢC��',@S, @E

---- ����������ϢE��
--Select @S=GetDate()  

--begin try      
--  Exec P_VsCH0E_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'����������ϢE��(P_VsCH0E_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '����������ϢE��',@S, @E

---- ���߰�ȫ��ϢP��
--Select @S=GetDate()  

--begin try      
--  Exec P_VsCH0P_ETL @StartDate, @EndDate  
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'���߰�ȫ��ϢP��(P_VsCH0P_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '���߰�ȫ��ϢP��',@S, @E

---- סԺ������־��Ϣ
--Select @S=GetDate()  

--begin try      
--  Exec P_VsTjZy_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'סԺ������־��Ϣ(P_VsTjZy_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'סԺ������־��Ϣ',@S, @E


---- ���﹤����־��Ϣ
--Select @S=GetDate()  

--begin try      
--  Exec P_VsTjmz_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'���﹤����־��Ϣ(P_VsTjmz_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '���﹤����־��Ϣ',@S, @E  

--------------------------------------------------����------------------------
---- ѹ������
--Select @S=GetDate()  

--begin try      
--  Exec P_ycpf_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'ѹ������(P_ycpf_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval 'ѹ������',@S, @E  


---- ��������
--Select @S=GetDate()  

--begin try      
--  Exec P_diedaopf_ETL @StartDate, @EndDate 
--end Try              
--begin catch              
-- insert into error_Log(ZxDate,error_step,error_text)               
-- values(getdate(),'��������(P_diedaopf_ETL)',ERROR_MESSAGE())               
--end Catch
  
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '��������',@S, @E  

--Select @S=GetDate()  
--  Exec P_infobrEmrML_ETL @StartDate, @EndDate -- ���Ӳ���Ŀ¼
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '���Ӳ���Ŀ¼', @S, @E

--Select @S=GetDate()  
--  Exec P_infobrEmrText_ETL @StartDate, @EndDate -- ���Ӳ����ı�����
--Select @E=GetDate()
--Exec P_GetDateTime_Interval '���Ӳ����ı�����',@S, @E 

--������־    
ALTER DATABASE HBIData SET RECOVERY SIMPLE WITH NO_WAIT     
ALTER DATABASE HBIData SET RECOVERY SIMPLE      
  DBCC SHRINKFILE (N'HBIData_log' , 11, TRUNCATEONLY)--��������־�ļ�     
ALTER DATABASE HBIData SET RECOVERY FULL WITH NO_WAIT    
ALTER DATABASE HBIData SET RECOVERY FULL WITH NO_WAIT   

End
/*
Exec P_AllData_ETL '2014-12-01', '2014-12-10'
*/