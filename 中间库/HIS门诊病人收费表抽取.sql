/*
 功能 读取HIS门诊病人收费表 按收费时间范围读取
 作者 ZMJ
 日期 2013-10-31
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_infoMZSF_ETL' AND type = 'P')
   DROP PROCEDURE P_infoMZSF_ETL
GO

Create PROCEDURE P_infoMZSF_ETL
   @StartDate varchar(10), @EndDate varchar(10)

As
begin
  Declare @SQLText varchar(8000)
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)
  
create table #MZSF (
   gid                  varchar(50)          null,
   BRID                 varchar(50)          null,
   mzid                 varchar(50)          null,
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
   gg                   int          null,
   je                   decimal(18,4)        null,
   sl                   decimal(18,4)        null,
   dj                   decimal(18,4)        null,
   dw                   varchar(50)          null,
   cfdjh                varchar(50)          null,
   YZID                 varchar(100)         null,
   YZZXID               varchar(100)         null,
   SRXMID               varchar(50)          null,
   IsJZ                 varchar(10)                  null,
   IsTJ                 varchar(10)                  null,
   JLZT                 varchar(10)                  null,
   JLXZ                 varchar(10)                  null,
   JLBZ                 varchar(10)                  null,
   hzxm                 varchar(100)          null
)

/*
1.HIS收费金额是按数量换算成盒后*单价取的，因此我们的收费数量也是按换算后取的
2.抗菌药物计算使用强度时，需要使用最小数量单位，按infoMZSF.sl/infoMZSF.gg 转换即可
3.sflbdm 收费大类代码，sjfmdm 收费次分类代码，sfxmdm 收费明细项代码
 

*/
     Set @SQLText= 
  'INSERT INTO #MZSF
           ([gid],[BRID]
           ,[mzid],[sflbdm]
           ,[sflbmc],[sfxmdm]
           ,[sfxmmc],[sjfmdm]
           ,[sjfmmc],[kdysdm]
           ,[kdysxm],[kdksdm]
           ,[kdksmc],[brksdm]
           ,[brksmc],[zxksdm]
           ,[zxksmc],[jfsj]
           ,[kfsj],[gg]
           ,[je],[sl]
           ,[dj],[dw],[cfdjh]
           ,[yzid],[yzzxid]
           ,[SRXMID],[IsJZ],[IsTJ]
           ,[JLZT],[JLXZ],[JLBZ],[hzxm])
  Select * From OpenQuery(dqhis, ''
      Select cast(a.RECIPE_NO as varchar(20))||''''_''''||cast(a.SEQUENCE_NO as varchar(20))||''''_''''||cast(a.TRANS_TYPE as varchar(20))||''''_''''||substr(replace(to_char(A.fee_date,''''yyyy-mm-dd hh24:mi:ss''''),'''':'''',''''''''),12)  gid, a.CLINIC_CODE brid,b.EMR_REGID mzid, a.fee_code sflbdm, c.fee_stat_name sflbmc, 
             a.ITEM_CODE sfxmdm, a.ITEM_name sfxmmc, a.fee_code sjfmdm, d.name sjfmmc, a.DOCT_CODE kdysdm, e.empl_name kdysxm,
             a.REG_DPCD kdksdm,f.dept_name kdksmc,
             null brksdm, null  brksmc, a.EXEC_DPCD zxksdm,a.EXEC_DPNM zxksmc,
             a.fee_date jfsj, null kfsj,
             a.pack_qty gg, cast(a.qty*a.unit_price/a.pack_qty as decimal(18,4)) je,cast(a.qty/a.pack_qty as decimal(18,4))  sl, a.unit_price dj, a.price_unit dw,a.RECIPE_NO cfdjh, a.MO_ORDER YZID,
             null YZZXID, null SRXMID,
            null IsJZ,null IsTJ,
            null JLZT, null JLXZ, null JLBZ,b.name hzxm
    From dqhis.fin_opb_feedetail a  left join dqhis.fin_opr_register b on  a.clinic_code=b.clinic_code and b.TRANS_TYPE = ''''1'''' AND b.VALID_FLAG = ''''1''''  
                                    left join dqhis.fin_com_feecodestat c on  a.fee_code=c.fee_code and c.report_code = ''''TJ04''''  
                                    left join dqhis.com_dictionary d on d.type =''''MINFEE'''' and a.fee_code=d.code  
                                    left join dqhis.com_employee e on a.DOCT_CODE=e.empl_code    
                                    left join dqhis.com_department f on a.REG_DPCD =f.dept_code     
    Where A.fee_date>=to_date('''''+@StartDate+''''', ''''YYYY-MM-DD'''') and A.fee_date<to_date('''''+@EndDate+''''', ''''YYYY-MM-DD'''') '')'
  exec (@SQLText)
  
  --drop table aa
  
  --SELECT * INTO aa FROM #MZSF
  
  ----SELECT TOP 1000 * FROM aa WHERE gid='3514892_3_082449'
  
  --SELECT gid,COUNT(*) FROM aa GROUP BY gid HAVING COUNT(*)>1


  Delete infoMZSF
    Where Exists(Select 1 From #MZSF Where #MZSF.GID=infoMZSF.GID)
    
    
  INSERT INTO infoMZSF
           ([gid],[BRID]
           ,[mzid],[sflbdm]
           ,[sflbmc],[sfxmdm]
           ,[sfxmmc],[sjfmdm]
           ,[sjfmmc],[kdysdm]
           ,[kdysxm],[kdksdm]
           ,[kdksmc],[brksdm]
           ,[brksmc],[zxksdm]
           ,[zxksmc],[jfsj]
           ,[kfsj],[gg]
           ,[je],[sl]
           ,[dj],[dw],[cfdjh]
           ,[yzid],[yzzxid]
           ,[SRXMID],[IsJZ],[IsTJ]
           ,[JLZT],[JLXZ],[JLBZ],[hzxm])
    Select [gid],[BRID]
           ,[mzid],[sflbdm]
           ,[sflbmc],[sfxmdm]
           ,[sfxmmc],[sjfmdm]
           ,[sjfmmc],[kdysdm]
           ,[kdysxm],[kdksdm]
           ,[kdksmc],[brksdm]
           ,[brksmc],[zxksdm]
           ,[zxksmc],[jfsj]
           ,[kfsj],[gg]
           ,[je],[sl]
           ,[dj],[dw],[cfdjh]
           ,[yzid],[yzzxid]
           ,[SRXMID],[IsJZ],[IsTJ]
           ,[JLZT],[JLXZ],[JLBZ],[hzxm]
      From #MZSF
      
  --Exec P_UpdateYSDM @StartDate, @EndDate, 'infoMZSF', 'jfsj', 'kdysdm', 'kdysxm'

End

/*
Exec P_infoMZSF_ETL '2016-05-01', '2016-05-31'

select top 1000 * from infoMZSF where brid='0000610008'  and convert(varchar(10),jfsj,120)='2015-10-18'  

truncate table infoMZSF
*/

