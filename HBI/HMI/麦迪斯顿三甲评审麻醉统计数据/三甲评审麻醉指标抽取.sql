
/****** Object:  StoredProcedure [dbo].[P_HMIdocare_ETL]    Script Date: 10/19/2015 14:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[P_HMIdocare_ETL]
  
   
As
begin
  Declare @SQLText varchar(8000),@StartDate varchar(10), @EndDate varchar(10)
  
  SET  @StartDate=convert(VARCHAR(10),dateadd(dd,-day(dateadd(month,-1,getdate()))+1,dateadd(month,-1,getdate())),120)  --上个月第一天
 
  set  @EndDate=convert(VARCHAR(10),DATEADD(DD,-DAY(DATEADD(M,1,GETDATE())),DATEADD(M,1,GETDATE())),120) --本月最后一天 
  
  delete yyps_ms 
  where (biyear=datepart(yy,@StartDate) and bimonth=datepart(mm,@StartDate)) or (biyear=datepart(yy,@EndDate) and bimonth=datepart(mm,@EndDate))
   
  Set @EndDate=Convert(varchar(10), Dateadd(dd, 1, Convert(DateTime, @EndDate)), 120)
  
  IF OBJECT_ID('aa')>0 
  BEGIN 
  DROP TABLE aa 
  end
  
  Set @SQLText=
  '
Select * into aa From OpenQuery(MDSDSS, ''
      SELECT to_char(START_DATE_TIME,''''YYYY'''') yy,   to_char(START_DATE_TIME,''''MM'''') mm, 
          --麻醉总例数
          NVL(SUM(MZCOUNT),0) AS MZCOUNT,
              --全身麻醉例数
          NVL(SUM(QSMZCOUNT),0) AS QSMZCOUNT,
              --其中体外循环例数
          NVL(SUM(TWXHCOUNT),0) AS TWXHCOUNT,
              --脊髓麻醉例数
          NVL(SUM(JSMZCOUNT),0) AS JSMZCOUNT,
              --其他麻醉例数
          NVL(SUM(MZCOUNT-(CASE WHEN QSMZCOUNT=1 OR TWXHCOUNT=1 OR JSMZCOUNT=1 THEN 1 ELSE 0 END)),0) AS QTMZCOUNT,
          --镇痛治疗总例数
          NVL(SUM(ZTZLCOUNT),0) AS ZTZLCOUNT,
              --门诊患者例数
          NVL(SUM(MZHZCOUNT),0) AS MZHZCOUNT,
              --住院患者例数
          NVL(SUM(ZYHZCOUNT),0) AS ZYHZCOUNT,
              --手术后镇痛例数
          NVL(SUM(SHZTCOUNT),0) AS SHZTCOUNT,
          --实施心肺复苏治疗总例数
          NVL(SUM(XFFSCOUNT),0) AS XFFSCOUNT,
              --心肺复苏治疗成功例数
          NVL(SUM(XFFSOKCOUNT),0) AS XFFSOKCOUNT,
          --进入麻醉复苏室总例数
          NVL(SUM(PACUCOUNT),0) AS PACUCOUNT,
              --离室时steward评分>=4分例数
          NVL(SUM(STEWARD4COUNT),0) AS STEWARD4COUNT,
              --麻醉中发生未预期的意识障碍总例数
          SUM(COUNT1) AS COUNT1,
              --麻醉中出现氧饱和度重度降低例数
          SUM(COUNT2) AS COUNT2,
              --全身麻醉结束时使用催醒药物例数
          SUM(COUNT3) AS COUNT3,
              --麻醉中因误咽误吸引发呼吸道梗阻例数
          SUM(COUNT4) AS COUNT4,
              --麻醉意外死亡例数
          SUM(COUNT5) AS COUNT5,
              --其他非预期的相关事件例数
          SUM(COUNT6) AS COUNT6,
          --6
          SUM(CASE WHEN ASA_GRADE = ''''Ⅰ级'''' OR ASA_GRADE = ''''Ⅱ级'''' OR ASA_GRADE =''''Ⅲ级'''' OR ASA_GRADE = ''''Ⅳ级'''' OR ASA_GRADE = ''''Ⅴ级'''' OR ASA_GRADE = ''''Ⅵ级'''' OR ASA_GRADE IS NULL  THEN 1 ELSE 0 END) AS ASACOUNT,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅰ级'''' THEN 1 ELSE 0 END) AS ASACOUNT1,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅰ级'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT1,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅱ级'''' THEN 1 ELSE 0 END) AS ASACOUNT2,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅱ级'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT2,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅲ级'''' THEN 1 ELSE 0 END) AS ASACOUNT3,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅲ级'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT3,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅳ级'''' THEN 1 ELSE 0 END) AS ASACOUNT4,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅳ级'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT4,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅴ级'''' THEN 1 ELSE 0 END) AS ASACOUNT5,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅴ级'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT5,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅵ级'''' THEN 1 ELSE 0 END) AS ASACOUNT6,
          SUM(CASE WHEN ASA_GRADE = ''''Ⅵ级'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT6,
          SUM(CASE WHEN ASA_GRADE = ''''其他'''' THEN 1 ELSE 0 END) AS ASACOUNT7,
          SUM(CASE WHEN ASA_GRADE = ''''其他'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT7
        FROM (SELECT  START_DATE_TIME,        
          --1
          1 AS MZCOUNT,
          (CASE WHEN A.ALL_ANESTHESIA = 1 THEN 1 ELSE 0 END) AS QSMZCOUNT,
          (CASE WHEN M.EXTRA_CIRCULATION = 1 THEN 1 ELSE 0 END) AS TWXHCOUNT,
          (CASE WHEN A.SPINAL_ANESTHESIA = 1 THEN 1 ELSE 0 END) AS JSMZCOUNT,
          --2
          (CASE WHEN ANALGESIA_THERAPY = 1 THEN 1 ELSE 0 END) AS ZTZLCOUNT,
          (CASE WHEN VISIT_ID = 0 AND ANALGESIA_THERAPY = 1 THEN 1 ELSE 0 END) AS MZHZCOUNT,
          (CASE WHEN VISIT_ID > 0 AND ANALGESIA_THERAPY = 1 THEN 1 ELSE 0 END) AS ZYHZCOUNT,
          (CASE WHEN AFTER_ANALGESIA = 1 THEN 1 ELSE 0 END) AS SHZTCOUNT,
          --3
          (CASE WHEN MONARY_RES = 1 THEN 1 ELSE 0 END) AS XFFSCOUNT,
          (CASE WHEN MONARY_RES_OK = 1 THEN 1 ELSE 0 END) AS XFFSOKCOUNT,
          --4
          (CASE WHEN IN_PACU_DATE_TIME IS NOT NULL THEN 1 ELSE 0 END) AS PACUCOUNT,
          (CASE WHEN IN_PACU_DATE_TIME IS NOT NULL AND PACU_STEWARD >= 4 THEN 1 ELSE 0 END) AS STEWARD4COUNT,
          --5
          (CASE WHEN CONS_DISTURBANCE = 1 THEN 1 ELSE 0 END) AS COUNT1,
          (CASE WHEN OXYGEN_SATURATION = 1 THEN 1 ELSE 0 END) AS COUNT2,
          (CASE WHEN USE_REMINDERS = 1 THEN 1 ELSE 0 END) AS COUNT3,
          (CASE WHEN RES_TRACT_OBSTRUCE = 1 THEN 1 ELSE 0 END) AS COUNT4,
          (CASE WHEN ANES_DEATH = 1 THEN 1 ELSE 0 END) AS COUNT5,
          (CASE WHEN OTHER_NOT_EXP = 1 THEN 1 ELSE 0 END) AS COUNT6,
          --6
          CASE WHEN INSTR('''',1,Ⅰ级,一,一级,Ⅰ,I级,I,1级,１,ⅠE,Ⅰ-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''Ⅰ级''''
        WHEN INSTR('''',2,Ⅱ级,二,二级,Ⅱ,II级,II,2级,11,２,１１,ⅡE,Ⅱ-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''Ⅱ级''''
        WHEN INSTR('''',3,Ⅲ级,三,三级,Ⅲ,III级,III,3级,111,３,１１１,ⅢE,Ⅲ-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''Ⅲ级''''
        WHEN INSTR('''',4,Ⅳ级,四,四级,Ⅳ,IV级,IV,4级,1111,４,ⅣE,Ⅳ-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''Ⅳ级''''
        WHEN INSTR('''',5,Ⅴ级,五,五级,Ⅴ,V级,V,5级,11111,５,ⅤE,Ⅴ-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''Ⅴ级''''
        WHEN INSTR('''',6,Ⅵ级,六,六级,Ⅵ,VI级,VI,6级,111111,６,ⅥE,Ⅵ-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''Ⅵ级''''
        ELSE ''''其他'''' END AS ASA_GRADE,
          DEATH_AFTER_OPER
        FROM V_MED_ANES_INFO M
        LEFT JOIN MED_ANESTHESIA_METHOD_TYPE A ON A.ANESTHESIA_METHOD=M.ANESTHESIA_METHOD
        WHERE OPER_STATUS >= 35
              AND (OPERATING_ROOM= '''''''' OR '''''''' IS NULL)
              AND START_DATE_TIME >= to_date('''''+@StartDate+''''',''''yyyy-mm-dd hh24:mi:ss'''')
              AND START_DATE_TIME < to_date('''''+@EndDate+''''',''''yyyy-mm-dd hh24:mi:ss'''')
          AND (ANES_START_TIME IS NOT NULL OR ANES_START_TIME != '''''''')
        ) M 
        group by to_char(START_DATE_TIME,''''YYYY'''') ,   to_char(START_DATE_TIME,''''MM'''')  
   '')'
  exec (@SQLText) 



    
  insert into yyps_ms(biyear,bimonth,bidate,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21)
  select yy biyear,mm bimonth,ltrim(yy)+'-'+right(mm+100,2)+'-'+'01',mzcount c1,QSMZCOUNT c2,TWXHCOUNT c3,JSMZCOUNT c4,QTMZCOUNT c5,
         ZTZLCOUNT c6,MZHZCOUNT c7,ZYHZCOUNT c8,SHZTCOUNT c9,XFFSCOUNT C10,XFFSOKCOUNT C11,
         PACUCOUNT C12,PACUCOUNT C13,STEWARD4COUNT c14,cast(COUNT1 as int)+cast(COUNT2 as int)+cast(COUNT3 as int)+cast(COUNT4 as int)+cast(COUNT5 as int)+cast(COUNT6 as int) c15,
         COUNT1 c16,COUNT2 c17,COUNT3 c18,COUNT4 c19,COUNT5 c20,COUNT6 c21 from aa
 
  drop table aa 



End

/*
select yzyl,yznr,yzcjsj b,* from infoBryz where bah='0000603341' and convert(varchar(10),yzcjsj,120) between '2015-10-15' and '2015-10-16' order by yzcjsj
Exec P_HMIdocare_ETL 
select * from yyps_ms
select * from aa
*/

