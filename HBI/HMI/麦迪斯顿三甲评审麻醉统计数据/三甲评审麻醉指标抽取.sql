
/****** Object:  StoredProcedure [dbo].[P_HMIdocare_ETL]    Script Date: 10/19/2015 14:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[P_HMIdocare_ETL]
  
   
As
begin
  Declare @SQLText varchar(8000),@StartDate varchar(10), @EndDate varchar(10)
  
  SET  @StartDate=convert(VARCHAR(10),dateadd(dd,-day(dateadd(month,-1,getdate()))+1,dateadd(month,-1,getdate())),120)  --�ϸ��µ�һ��
 
  set  @EndDate=convert(VARCHAR(10),DATEADD(DD,-DAY(DATEADD(M,1,GETDATE())),DATEADD(M,1,GETDATE())),120) --�������һ�� 
  
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
          --����������
          NVL(SUM(MZCOUNT),0) AS MZCOUNT,
              --ȫ����������
          NVL(SUM(QSMZCOUNT),0) AS QSMZCOUNT,
              --��������ѭ������
          NVL(SUM(TWXHCOUNT),0) AS TWXHCOUNT,
              --������������
          NVL(SUM(JSMZCOUNT),0) AS JSMZCOUNT,
              --������������
          NVL(SUM(MZCOUNT-(CASE WHEN QSMZCOUNT=1 OR TWXHCOUNT=1 OR JSMZCOUNT=1 THEN 1 ELSE 0 END)),0) AS QTMZCOUNT,
          --��ʹ����������
          NVL(SUM(ZTZLCOUNT),0) AS ZTZLCOUNT,
              --���ﻼ������
          NVL(SUM(MZHZCOUNT),0) AS MZHZCOUNT,
              --סԺ��������
          NVL(SUM(ZYHZCOUNT),0) AS ZYHZCOUNT,
              --��������ʹ����
          NVL(SUM(SHZTCOUNT),0) AS SHZTCOUNT,
          --ʵʩ�ķθ�������������
          NVL(SUM(XFFSCOUNT),0) AS XFFSCOUNT,
              --�ķθ������Ƴɹ�����
          NVL(SUM(XFFSOKCOUNT),0) AS XFFSOKCOUNT,
          --������������������
          NVL(SUM(PACUCOUNT),0) AS PACUCOUNT,
              --����ʱsteward����>=4������
          NVL(SUM(STEWARD4COUNT),0) AS STEWARD4COUNT,
              --�����з���δԤ�ڵ���ʶ�ϰ�������
          SUM(COUNT1) AS COUNT1,
              --�����г��������Ͷ��ضȽ�������
          SUM(COUNT2) AS COUNT2,
              --ȫ���������ʱʹ�ô���ҩ������
          SUM(COUNT3) AS COUNT3,
              --����������������������������������
          SUM(COUNT4) AS COUNT4,
              --����������������
          SUM(COUNT5) AS COUNT5,
              --������Ԥ�ڵ�����¼�����
          SUM(COUNT6) AS COUNT6,
          --6
          SUM(CASE WHEN ASA_GRADE = ''''��'''' OR ASA_GRADE = ''''��'''' OR ASA_GRADE =''''��'''' OR ASA_GRADE = ''''����'''' OR ASA_GRADE = ''''����'''' OR ASA_GRADE = ''''����'''' OR ASA_GRADE IS NULL  THEN 1 ELSE 0 END) AS ASACOUNT,
          SUM(CASE WHEN ASA_GRADE = ''''��'''' THEN 1 ELSE 0 END) AS ASACOUNT1,
          SUM(CASE WHEN ASA_GRADE = ''''��'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT1,
          SUM(CASE WHEN ASA_GRADE = ''''��'''' THEN 1 ELSE 0 END) AS ASACOUNT2,
          SUM(CASE WHEN ASA_GRADE = ''''��'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT2,
          SUM(CASE WHEN ASA_GRADE = ''''��'''' THEN 1 ELSE 0 END) AS ASACOUNT3,
          SUM(CASE WHEN ASA_GRADE = ''''��'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT3,
          SUM(CASE WHEN ASA_GRADE = ''''����'''' THEN 1 ELSE 0 END) AS ASACOUNT4,
          SUM(CASE WHEN ASA_GRADE = ''''����'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT4,
          SUM(CASE WHEN ASA_GRADE = ''''����'''' THEN 1 ELSE 0 END) AS ASACOUNT5,
          SUM(CASE WHEN ASA_GRADE = ''''����'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT5,
          SUM(CASE WHEN ASA_GRADE = ''''����'''' THEN 1 ELSE 0 END) AS ASACOUNT6,
          SUM(CASE WHEN ASA_GRADE = ''''����'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT6,
          SUM(CASE WHEN ASA_GRADE = ''''����'''' THEN 1 ELSE 0 END) AS ASACOUNT7,
          SUM(CASE WHEN ASA_GRADE = ''''����'''' AND DEATH_AFTER_OPER = 1 THEN 1 ELSE 0 END) AS DEATHCOUNT7
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
          CASE WHEN INSTR('''',1,��,һ,һ��,��,I��,I,1��,��,��E,��-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''��''''
        WHEN INSTR('''',2,��,��,����,��,II��,II,2��,11,��,����,��E,��-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''��''''
        WHEN INSTR('''',3,��,��,����,��,III��,III,3��,111,��,������,��E,��-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''��''''
        WHEN INSTR('''',4,����,��,�ļ�,��,IV��,IV,4��,1111,��,��E,��-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''����''''
        WHEN INSTR('''',5,����,��,�弶,��,V��,V,5��,11111,��,��E,��-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''����''''
        WHEN INSTR('''',6,����,��,����,��,VI��,VI,6��,111111,��,��E,��-E, '''',('''',''''||TRIM(M.ASA_GRADE)||'''',''''))>0 THEN ''''����''''
        ELSE ''''����'''' END AS ASA_GRADE,
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

