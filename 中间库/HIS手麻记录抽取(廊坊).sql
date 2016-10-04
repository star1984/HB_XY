  
Alter PROCEDURE P_infoBRSMJL_ETL  
   @StartDate varchar(10), @EndDate varchar(10)  
As  
begin  
/*  

  
[调用示例]:  
 Exec P_infoBRSMJL_ETL '2015-04-01', '2015-04-29'  
  
 select * from  ss_mazui..MEDSURGERY.MED_OPERATION_MASTER order by start_date_time  --where patient_id='5566' order by start_date_time  --手术主表  
 select * from  ss_mazui..MEDSURGERY.MED_CUSTOM_DATA where item_name='手术风险评估单.B1' and item_value='1'--手术记录明细表  
 select * from  ss_mazui..MEDCOMM.MED_PAT_MASTER_INDEX  where patient_id='5566' --病人基本信息表  
 select * from  SS_MAZUI..MEDCOMM.MED_DEPT_DICT--部门对应表  
 select * from  ss_mazui..MEDCOMM.MED_HIS_USERS--医生护士   
 select * from  SS_MAZUI..MEDSURGERY.MED_ANESTHESIA_PLAN--手术麻醉记录单  
*/  
--declare @StartDate varchar(10)='2015-04-01', @EndDate varchar(10)='2015-04-29'  
--truncate table infoBRSMJL  
Declare @SQLText varchar(8000)  
 
select  * into #infoBRSMJL from infoBRSMJL where 1=2 

set @SQLText=
     'INSERT INTO #infoBRSMJL
           ([SSID]
           ,[SQID]
           ,[BRID]
           ,[bah]
           ,[zyh]
           ,[zycs]
           ,[ssrq]
           ,[kssj]
           ,[jssj]
           ,[jxsj]
           ,[ssmc]
           ,[ssysxm]
           ,[mzysdm]
           ,[mzysxm]
           ,[mzfsdm]
           ,[mzfsmc]
           ,[ASAFJ]
           ,[NNISFJ]
           ,[isjz]
           ,[KSDM]
           ,[KSMC]
           ,[sslb]
           ,[qkdj])
    Select * From OpenQuery(DHHIS, ''
      Select a.opa_rowid,null sqid,e.PAPMI_no brid,cast(e.PAPMI_no as varchar(12))||''''_''''||cast(d.PAADM_InPatNo as varchar(10)) bah,
             e.PAPMI_Medicare zyh, d.PAADM_InPatNo zycs,convert(varchar(10),A.opa_startdate,120) ssrq,
             cast(convert(varchar(10),A.opa_startdate,120)||'''' ''''||convert(varchar(20),A.opa_starttime,108) as datetime) kssj,
             cast(convert(varchar(10),A.opa_enddate,120)||'''' ''''||convert(varchar(20),A.opa_endtime,108) as datetime) jssj,
             null jxsj,I.oper_DESC ssmc,null ssysxm,null mzysdm,null mzysxm,null mzfsdm,null mzfsmc,c.ORASA_DESC ASAFJ,NULL NNISFJ,
             NULL ISJZ,a.opa_Patdept_dr KSDM,cast(F.CTLOC_code as varchar) KSMC,NULL SSLB,h.BLDTP_desc QKDJ
                                           from  dhc_AN_OPARRANGE  a inner join (select ANA_PAADM_PARREF,ana_rowid,ana_date,ana_notes,ANA_TheatreInDate,ANA_ASA_DR from  OR_Anaesthesia ) b on a.OPA_Anaest_Dr=b.ANA_ROWID 
                                                 inner join ORC_ASA_ClassPhActiv c on b.ANA_ASA_DR=c.ORASA_rowid 
                                                 inner join PA_Adm d on a.OPA_Adm_dr=d.PAADM_rowid 
                                                 inner join PA_PATMAS e on d.PAADM_Papmi_dr=e.papmi_rowid1 
                                                 inner join CT_Loc f on  a.opa_Patdept_dr=f.CTLOC_rowid  
                                                 inner JOIN OR_Anaest_Operation G ON   b.ana_rowid=g.anaop_par_ref  
                                                 left join ORC_BladeType h on g.anaop_blade_dr=h.BLDTP_ROWID 
                                                 left join  ORC_Operation I on G.anaop_type_dr=I.oper_rowid 
      Where a.opa_status=''''F'''' and  convert(varchar(10),a.opa_StartDate,120)>='''''+@StartDate+''''' and convert(varchar(10),a.opa_StartDate,120)<'''''+@EndDate+''''' '')'
 

exec(@SQLText)  



--去除重复数据。由于和手术申请单关联，一台手麻手术有可能会对应多条手术申请单信息 
select row_number() over(partition by ssid order by ssrq,qkdj desc) xh,* into #aaaaa  from #infoBRSMJL 

delete from #aaaaa 
where xh>1 

--更新手术风险等级
UPDATE #aaaaa 
SET jxsj=datediff(mi,kssj,jssj), NNISFJ=CASE WHEN qkdj='III类' OR qkdj='IV类' THEN 1 ELSE 0 END 
        +CASE WHEN ASAFJ='Ⅲ' OR ASAFJ='Ⅳ' OR ASAFJ='Ⅴ' OR ASAFJ='Ⅵ' THEN 1 ELSE 0 END 
        +CASE WHEN datediff(mi,kssj,jssj)>180 THEN 1 ELSE 0 end 


Delete infoBRSMJL   Where CONVERT(VARCHAR(10),ssrq,120)  between  @StartDate and @EndDate  
  
  
--drop table aaaaa

    
   
--更新手术麻醉信息结束  
  
  Insert infoBRSMJL   
           ([SSID],[BRID],[bah],[zyh],[zycs],[ssrq],[kssj]  
           ,[jssj],[jxsj],[ssmc],[ssysxm],[mzysdm],[mzysxm],[mzfsmc],ksdm,[KSMC],[qkdj],[ASAFJ],[NNISFJ],[isjz],[sslb])  
    Select ssID,brid,bah,zyh,zycs,ssrq,kssj,  
           jssj,jxsj,ssmc,ssysxm,mzysdm,[mzysxm],mzfsmc,ksdm,ksmc,qkdj,ASAFJ,NNISFJ,isjz,sslb      
      From #aaaaa 



   
End  
  
/*  
Exec P_infoBRSMJL_ETL '2015-01-01', '2015-11-30'  
Select * From infoBRSMJL  Where ssrq between '2014-01-03' and '2014-01-04' order by zyh ZYH='191211'  
select * from infoBRSMJL  
DELETE from infoBRSMJL 
*/  
  