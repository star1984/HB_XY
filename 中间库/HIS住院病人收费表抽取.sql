/*
 功能 读取HIS住院病人收费表 按收费时间范围读取
 作者 ZMJ
 日期 2013-10-31
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_infoZYSF_ETL' AND type = 'P')
   DROP PROCEDURE P_infoZYSF_ETL
GO

Create PROCEDURE P_infoZYSF_ETL
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
  Declare @SQLText varchar(8000)
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)
create table #ZYSF (
   gid                  varchar(50)          null,
   BRID                 varchar(50)          null,
   bah                  varchar(50)          null,
   zyh                  varchar(50)          null,
   zycs                 int                  null,
   sflbdm               varchar(20)          null,
   sflbmc               varchar(100)         null,
   sfxmdm               varchar(30)          null,
   sfxmmc               varchar(100)         null,
   sjfmdm               varchar(30)          null,
   sjfmmc               varchar(100)         null,
   kdysdm               varchar(20)          null,
   kdysxm               varchar(50)          null,
   kdksdm               varchar(20)          null,
   kdksmc               varchar(50)          null,
   brksdm               varchar(20)          null,
   brksmc               varchar(50)          null,
   zxksdm               varchar(20)          null,
   zxksmc               varchar(50)          null,
   jfsj                 datetime             null,
   kfsj                 datetime             null,
   gg                   varchar(50)          null,
   je                   decimal(20,2)        null,
   sl                   decimal(20,2)        null,
   dj                   decimal(20,2)        null,
   dw                   varchar(50)          null,
   cfdjh                varchar(50)          null,
   yzid                 varchar(100)         null,
   yzzxid               varchar(100)         null,
   SRXMID               varchar(50)          null,
   IsJZ                 int                  null,
   JLZT                 int                  null,
   JLXZ                 int                  null,
   JLBZ                 int                  null,
   hzxm                 varchar(100)          null
)


    
  --药品收费明细 
  Set @SQLText=
  'insert into #ZYSF(gid, BRID,bah ,zyh ,zycs,sflbdm ,sflbmc ,sfxmdm ,sfxmmc ,sjfmdm ,sjfmmc ,kdysdm ,kdysxm ,kdksdm ,
                     kdksmc , brksdm ,brksmc ,zxksdm ,zxksmc ,jfsj,kfsj,gg,je,sl,dj,dw,cfdjh,yzid,
                     yzzxid ,SRXMID ,IsJZ,JLZT,JLXZ,JLBZ,hzxm )
  Select *  From OpenQuery(dqhis, ''
    Select cast(a.RECIPE_NO as varchar(20))||''''_''''||cast(a.SEQUENCE_NO as varchar(20))||''''_''''||cast(a.TRANS_TYPE as varchar(20))||''''_''''||substr(replace(to_char(A.fee_date,''''yyyy-mm-dd hh24:mi:ss''''),'''':'''',''''''''),12) gid, cast(c.inPATIENT_NO as varchar(20))||''''_''''||cast(1 as varchar(10)) BRID, c.PATIENT_NO  bah, 
           a.INPATIENT_NO zyh, 1 zycs, a.fee_code sflbdm, d.fee_stat_name sflbmc, 
           a.drug_code sfxmdm, a.drug_name sfxmmc, a.fee_code sjfmdm, e.name sjfmmc, a.RECIPE_DOCCODE kdysdm, f.empl_name kdysxm,
           a.RECIPE_DEPTCODE kdksdm,g.dept_name kdksmc, a.INHOS_DEPTCODE brksdm, h.dept_name brksmc,
           a.EXECUTE_DEPTCODE zxksdm,i.dept_name zxksmc,
           A.fee_date jfsj, null kfsj, 
           a.pack_qty gg, a.TOT_COST je,A.qty sl,cast(a.TOT_COST*1.0/A.qty as decimal(18,2))  dj, a.CURRENT_UNIT dw,
           a.RECIPE_NO cfdjh, a.MO_ORDER YZID,
           null YZZXID, null SRXMID,
           null IsJZ, null JLZT, null JLXZ, null JLBZ,a.name hzxm
    From  dqhis.fin_ipb_medicinelist a left join dqhis.fin_ipr_inmaininfo c on a.inpatient_no=c.inpatient_no  
                                       left join dqhis.fin_com_feecodestat d on  a.fee_code=d.fee_code and d.report_code = ''''TJ04''''   
                                       left join dqhis.com_dictionary e on e.type =''''MINFEE'''' and a.fee_code=e.code    
                                       left join dqhis.com_employee f on  a.RECIPE_DOCCODE=f.empl_code 
                                       left join dqhis.com_department g on a.RECIPE_DEPTCODE=g.dept_code  
                                       left join dqhis.com_department h on a.INHOS_DEPTCODE=h.dept_code 
                                       left join dqhis.com_department i on a.EXECUTE_DEPTCODE=i.dept_code
    Where A.fee_date>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.fee_date<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''') '')'
 
  exec (@SQLText) 
  
  --非药品收费明细 
  Set @SQLText=
  'insert into #ZYSF(gid, BRID,bah ,zyh ,zycs,sflbdm ,sflbmc ,sfxmdm ,sfxmmc ,sjfmdm ,sjfmmc ,kdysdm ,kdysxm ,kdksdm ,
                     kdksmc , brksdm ,brksmc ,zxksdm ,zxksmc ,jfsj,kfsj,gg,je,sl,dj,dw,cfdjh,yzid,
                     yzzxid ,SRXMID ,IsJZ,JLZT,JLXZ,JLBZ,hzxm )
  Select *  From OpenQuery(dqhis, ''
    Select cast(a.RECIPE_NO as varchar(20))||''''_''''||cast(a.SEQUENCE_NO as varchar(20))||''''_''''||cast(a.TRANS_TYPE as varchar(20))||''''_''''||substr(replace(to_char(A.fee_date,''''yyyy-mm-dd hh24:mi:ss''''),'''':'''',''''''''),12) gid, cast(c.inPATIENT_NO as varchar(20))||''''_''''||cast(1 as varchar(10)) BRID, c.PATIENT_NO  bah, 
           a.INPATIENT_NO zyh, 1 zycs, a.fee_code sflbdm, d.fee_stat_name sflbmc, 
           a.item_code sfxmdm, a.item_name sfxmmc, a.fee_code sjfmdm, e.name sjfmmc, a.RECIPE_DOCCODE kdysdm, f.empl_name kdysxm,
           a.RECIPE_DEPTCODE kdksdm,g.dept_name kdksmc, a.INHOS_DEPTCODE brksdm, h.dept_name brksmc,
           a.EXECUTE_DEPTCODE zxksdm,i.dept_name zxksmc,
           A.fee_date jfsj, null kfsj, 
           null gg, a.TOT_COST je,A.qty sl,a.UNIT_PRICE  dj, a.CURRENT_UNIT dw,
           a.RECIPE_NO cfdjh, a.MO_ORDER YZID,
           null YZZXID, null SRXMID,
           null IsJZ, null JLZT, null JLXZ, null JLBZ,a.name hzxm
    From  dqhis.fin_ipb_itemlist a  left join dqhis.fin_ipr_inmaininfo c on a.inpatient_no=c.inpatient_no  
                                    left join dqhis.fin_com_feecodestat d on  a.fee_code=d.fee_code and d.report_code = ''''TJ04''''   
                                    left join dqhis.com_dictionary e on e.type =''''MINFEE'''' and a.fee_code=e.code    
                                    left join dqhis.com_employee f on  a.RECIPE_DOCCODE=f.empl_code 
                                    left join dqhis.com_department g on a.RECIPE_DEPTCODE=g.dept_code  
                                    left join dqhis.com_department h on a.INHOS_DEPTCODE=h.dept_code 
                                    left join dqhis.com_department i on a.EXECUTE_DEPTCODE=i.dept_code
    Where A.fee_date>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.fee_date<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''')  '')'
 
  exec (@SQLText) 
  

  
  
  ----由于收费视图存在个别大金额错误数据明细，隔天又会退费，因此采用临时表aa，用于数据筛选用
  --delete #ZYSF 
  --where cast(je as decimal(18,2))>10000000  or ABS(sl)>10000000
 


  Delete infoZYSF
    Where Exists(Select 1 From #ZYSF Where #ZYSF.GID=infoZYSF.GID)

  INSERT INTO infoZYSF
           ([gid],[BRID],[bah]
      ,[zyh],[zycs]
      ,[sflbdm],[sflbmc]
      ,[sfxmdm],[sfxmmc]
      ,[sjfmdm],[sjfmmc]
      ,[kdysdm],[kdysxm]
      ,[kdksdm],[kdksmc]
      ,[brksdm],[brksmc]
      ,[zxksdm],[zxksmc]
      ,[jfsj],[kfsj]
      ,[gg],[je]
      ,[sl],[dj],[dw]
      ,[cfdjh],[yzid],[yzzxid]
      ,[SRXMID],[IsJZ]
      ,[JLZT],[JLXZ],[JLBZ],[hzxm])
  Select [gid],[BRID],[bah]
      ,[zyh],[zycs]
      ,[sflbdm],[sflbmc]
      ,[sfxmdm],[sfxmmc]
      ,[sjfmdm],[sjfmmc]
      ,[kdysdm],[kdysxm]
      ,[kdksdm],[kdksmc]
      ,[brksdm],[brksmc]
      ,[zxksdm],[zxksmc]
      ,[jfsj],[kfsj]
      ,[gg],[je]
      ,[sl],[dj],[dw]
      ,[cfdjh],[yzid],[yzzxid]
      ,[SRXMID],[IsJZ]
      ,[JLZT],[JLXZ],[JLBZ],[hzxm]
    From #ZYSF
    
 
  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoZYSF', 'jfsj', 'kdysdm', 'kdysxm'


End

/*
Exec P_infoZYSF_ETL '2016-05-01', '2016-06-30' 

select count(*) from infoZYSF where bah='0000603341'  and yzid='1949334||354'
alter table infozysf alter column je decimal(20,2)
select top 1000  * from infoBryz  where bah='0000603341' and yznr like '%肠内营养%'
 1949334||347  1949334||441
*/

