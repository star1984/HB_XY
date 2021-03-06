USE [HBIDATA]
GO
/****** Object:  StoredProcedure [dbo].[P_WB_ZDXX]    Script Date: 09/02/2016 15:29:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_WB_ZDXX]
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
   declare @SQLText Varchar(8000) 
   --Select * Into #ZDXX from WB_ZDXX where 1=2 
   --alter table WB_ZDXX alter column id varchar(30) not null
   --SELECT * FROM jhdzbl.[JHEMR].[dbo].[V_DLBA_DIAGNOSIS]
   --select top 1000 * from hbidata..infoRYDJB
  

  
  CREATE TABLE #aa(
	[ID] [varchar](30) ,
	[BRID] [varchar](50) NULL,
	[visit_id] INT,
	[ZDLX] [varchar](30) NULL,
	[ZDICD] [varchar](50) NULL,
	[ZDMC] [varchar](200) NULL
	)
  
   
   Set @SQLText='  insert into #aa(id,brid,visit_id,zdlx,zdicd,zdmc)
                   SELECT patient_id+''_''+ltrim(visit_id)+''_''+ltrim(diagnosis_no)+''_''+ltrim(diagnosis_sub_no) id,
                          patient_id brid ,visit_id ,diagnosis_type_name ZDLX,diagnosis_code zdicd,diagnosis_desc zdmc   
                     
                  FROM jhdzbl.[JHEMR].[dbo].[V_DLBA_DIAGNOSIS]   inner join hbidata..infoRYDJB b on patient_id=b.bah and visit_id=b.zycs 
                   where (convert(varchar(10),b.rysj,120) between '''+ @StartDate+''' and '''+ @EndDate+ ''') or (b.cysj between '''+ @StartDate + ''' and '''+@EndDate+''' or b.cysj is null )'
  EXEC  (@SQLText) 
  
  DELETE FROM #aa WHERE id IS NULL 
  
  UPDATE #aa 
  SET brid=b.zyh
  FROM HBIDATA..infoRYDJB b 
  WHERE #aa.BRID=b.bah
  
 
  
  delete WB_ZDXX where EXISTS (Select 1 From #aa WHERE WB_ZDXX.id=#aa.id AND WB_ZDXX.ZDLX=#aa.ZDLX )
  
  Insert Into WB_ZDXX(id,brid,zdlx,zdicd,zdmc)
  Select id,brid+'_'+LTRIM(visit_id) ,zdlx,zdicd,zdmc from #aa

END

--exec P_WB_ZDXX '2016-05-01','2016-09-04'   
--select id,count(*) from aa group by id having count(*)>1
--select * from WB_ZDXX where id='0000765121_1_1_2'
--select * from jhdzbl.[JHEMR].[dbo].[V_DLBA_DIAGNOSIS]  where patient_id='0000765121'