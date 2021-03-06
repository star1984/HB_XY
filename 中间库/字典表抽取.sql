USE [HBIData]
GO
/****** Object:  StoredProcedure [dbo].[P_Dictionary_ETL]    Script Date: 03/07/2015 11:42:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_Dictionary_ETL]

As
begin
--DROP TABLE #Doctor
Declare @SQLText varchar(8000)
-- 医务人员详细信息表
-- Select * From OpenQuery(dqhis, 'Select *  From dqhis.com_employee ')
Truncate Table WB_Doctor
Select * into #Doctor From WB_Doctor Where 1=2
  Set @SQLText='
INSERT INTO #Doctor
           ([UserID]
           ,[GH]
           ,[TName]
           ,[DeptID]
           ,[zc]
           ,[IsTy]
           ,[pym]
           ,[ptown])
  Select * From OpenQuery(dqhis, ''
Select A.EMPL_CODE USERID, A.EMPL_CODE  GH,
       A.EMPL_NAME TName, a.dept_code DeptID,
       B.NAME zc,
       Case When A.VALID_STATE=''''0'''' or A.VALID_STATE=''''2'''' Then 1 Else 0 End  IsTy, A.SPELL_CODE PYM,
       A.EXT1_FLAG  ptown
From dqhis.com_employee a left join dqhis.com_dictionary b on a.levl_code=b.code and b.type=''''LEVEL'''' 
 '')'
Exec (@SQLText) 
Insert WB_Doctor
  Select * From #Doctor

-- 医院部门表drop table #Dept
-- Select * From OpenQuery(dqhis, 'Select *  From dqhis.com_department ')
Truncate Table WB_Dept
Select * into #Dept From WB_Dept Where 1=2
  Set @SQLText='
INSERT INTO #Dept
           ([DeptID]
           ,[DeptName]
           ,[XH]
           ,[IsMz]
           ,[IsZy]
           ,[IsSS]
           ,[IsJZ]
           ,[IsYJ]
           ,[CWS]
           ,[BZCWS]
           ,[JCS]
           ,[IsTy]
           ,[PYM]
           ,[DEPTTOWN])
  Select * From OpenQuery(dqhis, ''
  Select A.dept_code DeptID, A.dept_name  DeptName, A.dept_code XH, 
         Case When dept_type=''''C'''' Then 1 Else 0 End IsMz, 
         Case When dept_type=''''I'''' Then 1 Else 0 End IsZy,
         Case When DEPT_PRO=''''1'''' Then 1 Else 0 End IsSS,
         null IsJZ,
         Case When dept_type=''''T'''' Then 1 Else 0 End IsYJ, Null CWS, Null BZCWS, Null JCS,
         Case When VALID_STATE=''''0'''' or VALID_STATE=''''2'''' Then 1 Else 0 End IsTy,spell_code pym,
         a.deptown
    From dqhis.com_department a
      '')'
Exec (@SQLText) 

update #Dept 
set DeptName=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DeptName,'（','('),'）',')'),' ',''),'	',''),CHAR(10),''),CHAR(13),'')

Insert WB_Dept
Select * From #Dept

/* 
-- 医院科室病区床位表
Truncate Table WB_KSCW
Select * into #KSCW From WB_KSCW Where 1=2

  Set @SQLText='
INSERT INTO #KSCW
           ([gid]
           ,[bqid]
           ,[DeptID]
           ,[BedID]
           ,[BedName]
           ,[BedKind])
  Select * From OpenQuery(dqhis, ''
  Select A.床号||''''_''''||To_Char(A.病区ID) GID,病区ID,(case when 科室ID is null then ''''999999999999''''  else to_char(科室ID) end) as  DeptID, 
         床号 BedID, 床号 BedName,
         (Case When 床位编制=''''在编'''' Then 0 Else 1 End) BedKind
    From 床位状况记录 A '')' 
  exec (@SQLText)
Insert WB_KSCW
  Select * From #KSCW

Update [WB_Dept]
  Set [CWS]=C1, [BZCWS]=C2, [JCS]=C3 From
       (Select [DeptID] DID, Count(*) C1,
               Sum(Case When [BedKind]=0 Then 1 Else 0 End) C2,
               Sum(Case When [BedKind]=1 Then 1 Else 0 End) C3
          From [WB_KSCW]
          Group By [DeptID]) T
  Where [WB_Dept].[DeptID]=T.DID

Update WB_Dept
  Set IsZy=1
  Where CWS>0

*/
-- 医务人员可查看病区表select * from WB_Doctor_ks where userid=462
---- Select * From OpenQuery(dqhis, 'Select *  From dqhis.com_employee ')
Truncate Table WB_Doctor_ks
Select * into #Doctor_ks From WB_Doctor_ks Where 1=2
  Set @SQLText='
INSERT INTO #Doctor_ks
           ([Gid]
           ,[UserID]
           ,[DeptID])
  Select * From OpenQuery(dqhis, ''
  Select empl_code||''''_''''||dept_code  GID, empl_code, dept_code
  From dqhis.com_employee   '')'
Exec (@SQLText)
Insert WB_Doctor_ks
 Select A.* From #Doctor_ks A

/*
Insert WB_Doctor_ks
  Select A.* From #Doctor_ks A
  Inner Join WB_Doctor B on A.UserID=B.UserID and A.DeptID=
     (Case When (B.zc in ('主任医师','副主任医师','主治医师','医师','医士'))and(not(B.DeptID in ('110', '135'))) Then B.DeptID Else A.DeptID End)
*/
-- 药品字典表drop table #YPZD
  --和收费项目编码inner join，即医院没有销售的药品，则不会存到药品字典中去  
  /*DRUG_TYPE    dqhis.com_dictionary  where type='ITEMTYPE'  西药、中成药、中草药 
    USAGE_CODE   dqhis.com_dictionary  where type='USAGE';    用法
    DOSE_MODEL_CODE   dqhis.com_dictionary  where type='DOSAGEFORM';    剂型编码 
    oct_flag 是否抗菌药物
  */ 
Truncate Table WB_YPZD
Select * into #YPZD From WB_YPZD Where 1=2
  Set @SQLText='
INSERT INTO #YPZD
           ([YPID]
           ,[YPMC]
           ,[YPMC1]
           ,[YPPZDM]
           ,[YPPZMC]
           ,[DW]
           ,[MZDW]
           ,[MZBZ]
           ,[ZYDW]
           ,[ZYBZ]
           ,[GG]
           ,[JJ]
           ,[DJ]
           ,[JXDM]
           ,[JXMC]
           ,[GX]
           ,[IsZJ]
           ,[YPLX]
           ,[YPDLDM]
           ,[YPDLMC]
           ,[YPFLDM]
           ,[YPFLMC]
           ,[IsJBYW]
           ,[IsKSS]
           ,[IsMZ]
           ,[KSSLBDM]
           ,[KSSLBMC]
           ,[KSSXZLB]
           ,[DDDValue]
           ,[DDDUnit]
           ,[DDDConvert]
           ,[UnitConvert]
           ,[DLFLDM]
           ,[DLFLMC]
           ,[GYDW]
           ,[LYDW]
           ,[SCCJDM]
           ,[SCCJMC]
           ,[IsTy]
           ,[pym]
           ,[bssm]
           ,[jldw]
           ,[dtown]
           ,[pzwh]
          )
  Select * From OpenQuery(dqhis, ''
  Select a.drug_code YPID, a.trade_NAME YPMC, a.REGULAR_NAME YPMC1, b.drug_name YPPZDM, b.drug_name YPPZMC, a.MIN_UNIT DW, null MZDW,  null MZBZ, null ZYDW,  null ZYBZ,
         a.specs GG,a.PURCHASE_PRICE  JJ, a.RETAIL_PRICE DJ, a.DOSE_MODEL_CODE JXDM,c.name JXMC, Null GX, 
         Case When c.NAME LIKE ''''%注射%'''' Then 1 Else 0 End IsZJ, 
         Case a.fee_code When ''''002'''' Then 0 When ''''003'''' Then 1 When ''''004'''' Then 2 Else Null End YPLX,a.PHY_FUNCTION2 YPDLDM, e.NODE_name YPDLMC, 
         a.PHY_FUNCTION3 YPFLDM,f.NODE_name YPFLMC,case when a.EXTEND2 is not null or a.special_flag=''''1'''' then 1 else 0 end  IsJBYW, case when a.oct_flag=''''1'''' then 1 else 0 end IsKSS,
         null IsMZ, null KSSLBDM, null KSSLBMC, 
         CASE WHEN a.ITEM_GRADE=''''4'''' THEN 1 
              WHEN a.ITEM_GRADE=''''2'''' THEN 2 
              WHEN a.ITEM_GRADE=''''3'''' THEN 3 ELSE NULL end KSSXZLB, nvl(b.DDD_VALUE,0) DDDValue, Null DDDUnit,null  DDDConvert, a.PACK_QTY UnitConvert,
          null DLFLDM, null DLFLMC, null GYDW, a.MIN_UNIT LYDW, A.PRODUCER_CODE SCCJDM, g.fac_name SCCJMC,
          Case When a.VALID_STATE=''''0'''' or a.VALID_STATE=''''2'''' Then 1 Else 0 End IsTy,a.spell_code pym,null bssm,a.DOSE_UNIT jldw,a.area dtown,a.APPROVE_INFO pzwh
    From  dqhis.pha_com_baseinfo a LEFT JOIN  dqhis.pha_com_antibacteria b ON a.ATC_NO=b.kj_code
                                   LEFT JOIN  dqhis.com_dictionary c on c.type=''''DOSAGEFORM'''' AND a.DOSE_MODEL_CODE=c.code 
                                   LEFT JOIN  dqhis.com_dictionary d ON  d.type=''''MINFEE'''' AND a.fee_CODE=d.code 
                                   left join  dqhis.PHA_COM_FUNCTION e on a.PHY_FUNCTION2=e.NODE_CODE 
                                   left join  dqhis.PHA_COM_FUNCTION f on a.PHY_FUNCTION3=f.NODE_CODE 
                                   left join  dqhis.pha_com_company g on A.PRODUCER_CODE=G.fac_code
'')'
exec (@SQLText)
Insert WB_YPZD
  Select * From #YPZD 
--  select * from WB_YPZD



  

  
  /* 
--用药频率
Truncate Table WB_YYPL
Select * into #WB_YYPL From WB_YYPL Where 1=2
  Set @SQLText='
  INSERT INTO #WB_YYPL([BM],[MC],[PYM],[PLCS],[PLJG],[JGDW])
  Select * From OpenQuery(dqhis, ''
  Select 编码,名称,简码,频率次数,频率间隔,间隔单位 From 诊疗频率项目 '')'
Exec (@SQLText)
Insert WB_YYPL
  Select * From #WB_YYPL
  */
  
  --DROP TABLE #TempYppz
 /*
--临汾市人民医院
--抗菌药物品种从别名中获取
CREATE TABLE #TempYppz(ypid VARCHAR(50),ypmc VARCHAR(100),YPPZDM varchar(50),YPPZMC varchar(100))
INSERT into #TempYppz
Select * From OpenQuery(dqhis,'
    select distinct
           a.药品id,a.名称,
           Case When 诊疗项目id is not null Then C.诊疗项目id Else A.药名ID End YPPZDM, 
           Case When C.名称 is not null Then C.名称 Else D.名称 End YPPZMC
      From 药品目录 A
     Inner Join 药品特性 B on A.药名ID=B.药名ID
      Left Join 诊疗项目别名 C on A.药名ID=C.诊疗项目id And 性质=9  And 码类=1
      Left Join 诊疗项目目录 D on B.药名ID=D.ID 
     Where B.抗生素 in (1,2,3)') 

UPDATE WB_YPZD SET YPPZMC=a.YPPZMC FROM #TempYppz a WHERE WB_YPZD.YPPZDM=a.YPPZDM
*/ 
/*
-- 维表_LIS抗菌素药品表
-- 中联中分 尿药浓度1 和 血药浓度1 ，2
Truncate Table WB_LisKss
Select * into #LisKss From WB_LisKss Where 1=2
  Set @SQLText='
INSERT INTO #LisKss
           ([ypdm]
           ,[ypmc]
           ,[yf]
           ,[xynd]
           ,[yymc]
           ,[pym]
           ,[yptype]
           ,[isty])
  Select * From OpenQuery(dqhis, ''
  Select ID, 中文名, 用法用量1, 血药浓度1, 英文名, 简码, Null yptype, 0 isty
    From 检验用抗生素 A'')'
Exec (@SQLText)
Insert WB_LisKss
  Select * From #LisKss

-- 维表_LIS病原体设置表
Truncate Table WB_Lis_byt
Select * into #Lis_byt From WB_Lis_byt Where 1=2
  Set @SQLText='
INSERT INTO #Lis_byt
           ([bytID]
           ,[bytmc]
           ,[iszj]
           ,[fl]
           ,[PYM]) 
  Select * From OpenQuery(dqhis, ''
  Select ID, 中文名, Null iszj, Null fl, 简码 From 检验细菌记录 A'')'
Exec (@SQLText)
Insert WB_Lis_byt
  Select * From #Lis_byt
*/

-- dqhis.com_dictionary  where type='MINFEE'  最小收费项目

/*
Truncate Table WB_SFXMXM
Select * into #SFXMXM From WB_SFXMXM Where 1=2
  Set @SQLText='
INSERT INTO #SFXMXM
           ([xmid]
           ,[xmmc]
           ,[xmfldm]
           ,[xmflmc]
           ,[bafm])
  Select * From OpenQuery(dqhis, ''
  Select A.ID xmid, A.名称 xmmc, A.类别 xmfldm, B.名称 xmflmc,a.病案费目
    From 收费项目目录 A 
      Left Join 收费项目类别 B on A.类别=B.编码'')'
Exec (@SQLText)
Insert WB_SFXMXM
  Select * From #SFXMXM

  Truncate Table WB_SRXM
Select * into #SRXM From WB_SRXM Where 1=2
  Set @SQLText='
  INSERT INTO #SRXM
           ([xmid]
           ,[xmmc]
           ,[xmdldm]
           ,[xmdlmc]
           ,[xmxldm]
           ,[xmxlmc])
  Select * From OpenQuery(dqhis, ''
  Select A.ID xmid, A.名称 xmmc, B.ID xmdldm, B.名称 xmdlmc, C.ID xmxldm, C.名称 xmxlmc
  From  收入项目 A
    Inner Join 收入项目 B on A.上级ID=B.ID
    Left Join 收入项目 C on B.上级ID=C.ID
  Where A.末级=1'')'
Exec (@SQLText)
Insert WB_SRXM
  Select * From #SRXM
  
 -- create table wb_zy(zydm varchar(20),zymc varchar(50))
 --职业字典表
 Truncate Table wb_zy
 Select * into #wb_zy From wb_zy Where 1=2
 Set @SQLText='
  INSERT INTO #wb_zy
           ([zydm]
           ,[zymc])
  Select * From OpenQuery(dqhis, ''
  Select 编码,名称  From  职业 '')'
 Exec (@SQLText)
 Insert wb_zy
 Select * From #wb_zy
 
*/
End
/*
Exec P_Dictionary_ETL 
select top 1000 * from  wb_ypzd where ypmc like '%胞磷胆碱钠注射液%'
*/
