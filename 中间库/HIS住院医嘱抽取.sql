USE [hbidata]
GO
/****** Object:  StoredProcedure [dbo].[P_infoBryz_ETL]    Script Date: 10/19/2015 14:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_infoBryz_ETL]
   @StartDate varchar(10), @EndDate varchar(10)
   
As
begin
  Declare @SQLText varchar(8000)
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)
  select * into #infoBryz from infoBryz where 1=2  
  
  --因东软医嘱状态里没有“停止”，长期医嘱结束后状态就成为了“作废”，因此HIS后来通过医嘱主表DC_CODE<>'3',来区分作废还是正常停止医嘱
  ALTER  TABLE #infoBryz ADD dc_code VARCHAR(10)
  
  Set @SQLText=
  'INSERT INTO [#infoBryz]
           ([YZID],[YZZID],[yzdjh],[BRID],[bah]
           ,[zyh],[zycs],[yzztdm]
           ,[yzztmc],[yzlbdm],[yzlbmc]
           ,[yzlx],[kyzysdm],[kyzysxm]
           ,[zlxmdm],[zlxmmc],[kyzksdm]
           ,[kyzksmc],[zxyzksdm]
           ,[zxyzksmc],[yzcjsj],[yzjssj]
           ,[zxpc]
           ,[zxplcs],[zxpljg],[zxpljgdw]
           ,[gyfsdm],[gyfsmc],[ypcode],[yplbdm]
           ,[yplbmc],[yzyl],[yznr]
           ,[yymd],[yyyy],[Issqsykss]
           ,[sqkssmd], [yszt], [IsJJ],dc_code)
Select * From OpenQuery(dqhis, ''
  Select a.MO_ORDER YZID, Null YZZID, null yzdjh,cast(b.INPATIENT_NO as varchar(20))||''''_''''||cast(1 as varchar(10)) BRID, b.PATIENT_NO bah, a.INPATIENT_NO zyh, 1 zycs,
         a.MO_STAT yzztdm, case when a.MO_STAT=''''0'''' then ''''开立''''
                                when a.MO_STAT=''''1'''' then ''''审核'''' 
                                when a.MO_STAT=''''2'''' then ''''执行'''' 
                                when a.MO_STAT=''''3'''' then ''''作废''''
                                when a.MO_STAT=''''4'''' then ''''重整''''
                                when a.MO_STAT=''''5'''' then ''''需要上级医生审核''''
                                when a.MO_STAT=''''6'''' then ''''暂存'''' 
                                when a.MO_STAT=''''7'''' then ''''预停止'''' else null end  yzztmc,
         a.class_code yzlbdm, a.class_name yzlbmc,case when a.TYPE_CODE=''''CZ'''' OR a.TYPE_CODE=''''ZC''''  then 1 
                                                       when a.TYPE_CODE=''''ZL'''' OR a.TYPE_CODE=''''LZ''''  then 2 else null end yzlx, a.DOC_CODE  kyzysdm, a.DOC_name kyzysxm,a.item_code zlxmdm,a.item_name zlxmmc, a.LIST_DPCD kyzksdm, c.dept_name kyzksmc,
         case when a.PHARMACY_CODE is not null then a.PHARMACY_CODE  else a.EXEC_DPCD end  zxyzksdm, null zxyzksmc, a.DATE_BGN yzcjsj,CASE WHEN to_char(a.DATE_END,''''yyyy-mm-dd'''')=''''0001-01-01'''' then null else a.DATE_END end  yzjssj,a.FREQUENCY_NAME zxpc, null zxplcs, null zxpljg, null zxpljgdw,a.USAGE_CODE gyfsdm, a.USE_name gyfsmc,null ypcode, null yplbdm, 
         null yplbmc,a.QTY_TOT  yzyl, 
         a.item_name yznr, case when a.mark5=1 then 2 
                                when a.mark5=2 then 1 else 2 end  yymd, null yyyy, Null Issqsykss, 
         null sqkssmd, null yszt, null IsJJ,a.dc_code
    From dqhis.met_ipm_order a left join dqhis.fin_ipr_inmaininfo b on a.INPATIENT_NO=b.INPATIENT_NO 
                         left join dqhis.com_department c on a.LIST_DPCD=c.dept_code
    
    Where a.DATE_BGN>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and a.DATE_BGN<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''') '')'
  exec (@SQLText) 

--更新执行科室名称select * from WB_Dept
UPDATE  A
SET zxyzksmc=b.DeptName
FROM #infoBryz a,dbo.WB_Dept b
WHERE a.zxyzksdm=b.DeptID

--更新医嘱“作废”还是“正常停止”状态
UPDATE #infoBryz 
SET yzztmc='正常停止' 
WHERE yzztdm='3' AND  dc_code<>'3'

ALTER TABLE #infoBryz DROP COLUMN  dc_code

  Delete infoBryz
    Where exists (select 1 from #infoBryz where infoBryz.YZID=#infoBryz.yzid) 
    
  insert into infoBryz
  select * from #infoBryz
  
  --drop table WorkLoad2
 
  
  

  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoBryz', 'yzcjsj', 'kyzysdm', 'kyzysxm'


End

/*
select yzyl,yznr,yzcjsj b,* from infoBryz where bah='0000603341' and convert(varchar(10),yzcjsj,120) between '2015-10-15' and '2015-10-16' order by yzcjsj
Exec P_infoBryz_ETL '2016-06-01', '2016-07-31' 
select * from WorkLoad2 
truncate table infoBryz
*/

