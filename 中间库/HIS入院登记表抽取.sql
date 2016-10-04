USE [hbidata]
GO
/****** Object:  StoredProcedure [dbo].[P_infoRYDJB_ETL]    Script Date: 04/26/2016 16:05:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_infoRYDJB_ETL]
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
  Declare @SQLText varchar(8000)
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)

  Select * into #RYDJ From infoRYDJB Where 1=2
  --PATIENT_NO为B开头的是新生儿，算入院人数、出院人数时根据统计需要进行考虑
  --Select * From OpenQuery(dqhis,'select * from dqhis.fin_ipr_inmaininfo ') 
  Set @SQLText=
  'INSERT INTO #RYDJ([GID], [bah],[zyh], [zycs],[hzxm], [hzxb],[csrq], [Hznl],[Nldw],[zjhm], [ryksdm],[ryksmc], [cyksdm],[cyksmc], [Rysj] 
           ,[cysj], [jssj],[rycwdm], [rycwmc],[cycwdm], [cycwmc],[zgysdm], [zgysxm],[MZZDICD], [mzzd],[RYZDICD], [ryzd],[CYZDICD], [cyzd],[cyzd2]
           ,[zssICCM], [zssmc]
           ,[cyzg], [lyfs]
           ,[tel], [lxr_xm],[lxr_tel] 
           ,[lxr_dz], [tz], [ybh]
           ,[BRXZ],[IsLCLJ], [xzz],[ryzgysdm],[ryzgysxm]
           )
  Select * From OpenQuery(dqhis, ''
  Select cast(A.INPATIENT_NO  as varchar(20))||''''_''''||cast(1 as varchar(10)) GID, a.PATIENT_NO bah,
         a.INPATIENT_NO  zyh, 1 zycs, a.NAME hzxm, case when a.SEX_CODE=''''M'''' then 1 
                                                        when a.SEX_CODE=''''F'''' then 2 else null end hzxb,
         trunc(a.BIRTHDAY) csrq, Null Hznl, Null Nldw, a.IDENNO zjhm, null ryksdm,null  ryksmc,
         case when to_char(a.OUT_DATE,''''yyyy-mm-dd'''')<>''''0001-01-01'''' and to_char(a.OUT_DATE,''''yyyy-mm-dd'''')<>''''0002-01-01'''' and a.OUT_DATE is not null then  A.DEPT_CODE end cyksdm,
         case when to_char(a.OUT_DATE,''''yyyy-mm-dd'''')<>''''0001-01-01'''' and to_char(a.OUT_DATE,''''yyyy-mm-dd'''')<>''''0002-01-01'''' and a.OUT_DATE is not null then  A.DEPT_name end cyksmc,
         a.IN_DATE rysj,CASE WHEN to_char(a.OUT_DATE,''''yyyy-mm-dd'''') NOT IN (''''0001-01-01'''',''''0002-01-01'''') THEN a.OUT_DATE ELSE null end cysj,null jssj, Null rycwdm, null rycwmc, Null cycwdm, null cycwmc,
         case when to_char(a.OUT_DATE,''''yyyy-mm-dd'''')<>''''0001-01-01'''' and to_char(a.OUT_DATE,''''yyyy-mm-dd'''')<>''''0002-01-01'''' and a.OUT_DATE is not null then A.CHARGE_DOC_CODE end zgysdm, 
         case when to_char(a.OUT_DATE,''''yyyy-mm-dd'''')<>''''0001-01-01'''' and to_char(a.OUT_DATE,''''yyyy-mm-dd'''')<>''''0002-01-01'''' and a.OUT_DATE is not null then a.CHARGE_DOC_NAME end zgysxm, 
         null MZZDICD,null mzzd, null RYZDICD, null  ryzd, null CYZDICD,
         null cyzd,null cyzd2,
         null zssICCM, null zssmc, 
         null cyzg,      
         null lyfs,
         A.HOME_TEL tel, null lxr_xm, null lxr_tel, A.HOME lxr_dz,null tz, null ybh, null brxz,
         null IsLCLJ, A.HOME xzz,null ryzgysdm,null ryzgysxm
    From dqhis.fin_ipr_inmaininfo a 
    Where ((A.IN_DATE>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.IN_DATE<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD''''))
          or 
           (CASE WHEN to_char(a.OUT_DATE,''''yyyy-mm-dd'''') NOT IN (''''0001-01-01'''',''''0002-01-01'''') THEN a.OUT_DATE ELSE null end  >=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and CASE WHEN to_char(a.OUT_DATE,''''yyyy-mm-dd'''') NOT IN (''''0001-01-01'''',''''0002-01-01'''') THEN a.OUT_DATE ELSE null end<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''') or (to_char(a.OUT_DATE,''''yyyy-mm-dd'''')=''''0001-01-01'''' AND to_char(a.OUT_DATE,''''yyyy-mm-dd'''')=''''0002-01-01'''' AND  A.OUT_DATE is null) ) 
          )  '')'

   EXEC (@SQLText)
      


--由于东软出入院表没有患者入院科室信息，患者科室变动记录存在数据不准确的情况，因此根据住院医嘱表取患者最早医嘱的开单科室为入院科室select top 100 *  from hbidata..infobryz 
select  * into #yzxx from hbidata..infobryz a
where exists (select 1 from #RYDJ b where a.BRID=b.GID)  

select a.BRID,a.kyzksdm,a.kyzksmc,kyzysdm,kyzysxm into #ryks from #yzxx a,(select brid,min(yzcjsj) yzcjsj from #yzxx group by brid) b
where a.BRID=b.BRID and a.yzcjsj=b.yzcjsj 

update #RYDJ 
set ryksdm=#ryks.kyzksdm ,ryksmc=#ryks.kyzksmc ,ryzgysdm=#ryks.kyzysdm,ryzgysxm=#ryks.kyzysxm
from #ryks 
where #RYDJ.gid=#ryks.brid  

--根据患者变动记录更新入院科室为null的情况

if exists(select 1 from sysobjects where type='U' and name='aa5') 
   BEGIN
   DROP TABLE aa5 
   end
   
   
  Set @SQLText='
                  Select * into aa5 From OpenQuery(DQHIS, ''select A.CLINIC_NO||''''_''''||cast(a.HAPPEN_NO as varchar(12)) gid,
                                                           a.NEW_DATA_CODE ryksdm,a.NEW_DATA_NAME ryksmc,a.oper_date ryrq,
                                                           cast(b.INPATIENT_NO  as varchar(20))||''''_''''||cast(1 as varchar(10)) bah, b.PATIENT_NO brid,
                                                           b.INPATIENT_NO zyh, 1 zycs 
                                                           from dqhis.com_shiftdata a  left join  dqhis.fin_ipr_inmaininfo b on  a.CLINIC_NO=b.inpatient_no                           
                                                           where a.SHIFT_TYPE=''''B''''  
                                                                 
  
                                                          '') '
                                                          
   exec(@SQLText)  
   
   --排除重复数据select * from aa where bah='ZY01B100778121_1'
   DELETE a 
   FROM aa5 a,(SELECT  bah ,MIN(ryrq) ryrq FROM aa5 GROUP BY bah) b 
   WHERE a.bah=b.bah AND a.ryrq>b.ryrq 
   
   UPDATE a 
   SET ryksdm=b.ryksdm,ryksmc=b.ryksmc
   FROM #RYDJ a,aa5 b 
   WHERE a.gid=b.bah AND a.ryksdm is null 
   
 
--更新诊断信息！！！！！！！！！！！！！！！！！！！！！！！！！
      

-- 计算年龄
  Update #RYDJ
    Set hznl=nl, nldw=Anldw From (
  Select GID AGID, (Case When DateDiff(dd, csrq, rysj)<=30 Then (Case When DateDiff(dd, csrq, rysj)=0 Then 1 Else DateDiff(dd, csrq, rysj) End)
            Else (Case When DateDiff(mm, csrq, rysj)<=11 Then (Case When DateDiff(mm, csrq, rysj)=0 Then 1 Else DateDiff(mm, csrq, rysj) End)
              Else (Case When DateDiff(yy, csrq, rysj)=0 Then 1 Else DateDiff(yy, csrq, rysj) End) End) End) nl,
         (Case When DateDiff(dd, csrq, rysj)<=30 Then '天'
            Else (Case When DateDiff(mm, csrq, rysj)<=11 Then '月' Else '岁' End) End) Anldw
    From #RYDJ ) T
    Where GID=AGID
   

 
  Delete infoRYDJB
    Where Exists(Select 1 From #RYDJ Where infoRYDJB.GID=#RYDJ.GID)

  Insert infoRYDJB([GID], [bah],[zyh], [zycs],[hzxm], [hzxb],[csrq], [Hznl],[Nldw],[zjhm], [ryksdm],[ryksmc], [cyksdm],[cyksmc], [Rysj] 
           ,[cysj], [jssj],[rycwdm], [rycwmc],[cycwdm], [cycwmc],[zgysdm], [zgysxm],[MZZDICD], [mzzd],[RYZDICD], [ryzd],[CYZDICD], [cyzd]
           ,[zssICCM], [zssmc]
           ,[cyzg], [lyfs]
           ,[tel], [lxr_xm],[lxr_tel] 
           ,[lxr_dz], [tz], [ybh]
           ,[BRXZ],[IsLCLJ], [xzz],[ryzgysdm],[ryzgysxm]
           )
    Select gid,bah,zyh,zycs,hzxm,hzxb,csrq,hznl,nldw,zjhm,ryksdm,ryksmc,cyksdm,cyksmc,Rysj
            ,cysj,jssj,rycwdm,rycwmc,cycwdm,cycwmc,zgysdm,zgysxm,MZZDICD,mzzd,RYZDICD,ryzd,CYZDICD,cyzd
            ,[zssICCM], [zssmc]
            ,[cyzg], [lyfs]
            ,[tel], [lxr_xm],[lxr_tel] 
            ,[lxr_dz], [tz], [ybh]
            ,[BRXZ],[IsLCLJ], [xzz],[ryzgysdm],[ryzgysxm]
             From #RYDJ  
             
   --异常数据特例处理
   UPDATE hbidata..infoRYDJB 
   SET ryksdm=1019,ryksmc='产科A区' 
   where gid in ('ZY11B100778121_1','ZY11B200778121_1','ZY11B300778121_1','ZY11B400778121_1',
                 'ZY11B500778121_1','ZY11B600778121_1','ZY11B700778121_1','ZY11B800778121_1','ZY11B900778121_1')
         
            
    drop table aa5         
  -- --根据病案数据，更新出院但出院时间和出院科室都为null的患者数据 select DATEPART(dd,GETDATE())%3
  --if DATEPART(dd,GETDATE())%5=0 
  --begin
  --update a 
  --set a.cysj=b.CH0A27,cyksdm=D.DeptID,cyksmc=D.DeptName
  --from infoRYDJB a,VsCH0A b,(select * from jcba..MHIS.T_ITF_OFFI) c,WB_Dept d
  --where a.zyh=b.CH0A00 and a.zycs=b.zycs and  b.cyks=c.FOFFIB AND C.FOFFIA=D.DeptName   and  (a.Cysj is Null or a.Cyksdm is Null) 
  --end

  --Update infoRYDJB
  --  Set zgysdm=(Select top 1 UserID From WB_Doctor A Where A.TName=infoRYDJB.zgysxm)
  --  Where infoRYDJB.Cysj Is Null
    

    
   
   
  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoRYDJB', 'Cysj', 'zgysdm', 'zgysxm'
  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoRYDJB', 'Rysj', 'zgysdm', 'zgysxm'

End

/*

truncate table infoRYDJB
select top 1000 * from  infoRYDJB where cysj is null
Exec P_infoRYDJB_ETL '2016-08-01','2016-09-04'
select * from infoRYDJB where ryksdm is null and bah not like '%B%' order by rysj desc

drop table aa
以下是中联增加HQMS汇总数据上报时增加的字段
if col_length('infoRYDJB', 'IsHQMSV01') is Null begin
alter table infoRYDJB Add IsHQMSV01 int -- 接受冠状动脉旁路移植术
alter table infoRYDJB Add IsHQMSV02 int -- 接受经皮冠状动脉介入治疗
alter table infoRYDJB Add IsHQMSV03 int -- 接受脑血肿清除术
alter table infoRYDJB Add IsHQMSV04 int -- 接受髋关节置换术
alter table infoRYDJB Add IsHQMSV05 int -- 接受心脏瓣膜置换术
alter table infoRYDJB Add IsHQMSV06 int -- 接受子宫切除术
alter table infoRYDJB Add IsHQMSV07 int -- 发生重返手术室再次手术
alter table infoRYDJB Add IsHQMSV08 int -- 输血
alter table infoRYDJB Add IsHQMSV09 int -- 输血反应
alter table infoRYDJB Add IsHQMSV10 int -- 输液
alter table infoRYDJB Add IsHQMSV11 int -- 输液反应
alter table infoRYDJB Add IsHQMSV12 int -- 患者放弃治疗自动出院

alter table infoRYDJB Add IsBFZ_his int -- 手术患者并发症发生例数  发生并发症
alter table infoRYDJB Add IsFXS_his int -- 手术患者术后肺栓塞发生例数  择期手术后并发症：肺栓塞  有,无
alter table infoRYDJB Add IsSJMXX_his int -- 手术患者手术后深静脉血栓发生例数 择期手术后并发症：深静脉血栓 有,无
alter table infoRYDJB Add IsBXZ_his int -- 手术患者手术后败血症发生例数  择期手术后并发症：败血症 有,无
alter table infoRYDJB Add IsCxOrLz_his int -- 手术患者手术后出血或血肿发生例数 择期手术后并发症：出血或血肿 有,无
alter table infoRYDJB Add IsSklk_his int -- 手术患者手术伤口裂开发生例数  择期手术后并发症：伤口裂开 有,无
alter table infoRYDJB Add IsCs_his int -- 手术患者手术后猝死发生例数  择期手术后并发症：猝死 有,无
alter table infoRYDJB Add IsHxsj_his int -- 手术患者手术后呼吸衰竭发生例数  择期手术后并发症：呼吸衰竭  有,无
alter table infoRYDJB Add IsSlDxsl_his int -- 手术患者手术后生理/代谢紊乱发生例数  择期手术后并发症：骨折/代谢紊乱 有,无
alter table infoRYDJB Add IsMz_his int -- 手术患者麻醉并发症发生例数  手术及麻醉并发症 有,无
end
*/
