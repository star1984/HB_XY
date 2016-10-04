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
  --PATIENT_NOΪB��ͷ����������������Ժ��������Ժ����ʱ����ͳ����Ҫ���п���
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
      


--���ڶ������Ժ��û�л�����Ժ������Ϣ�����߿��ұ䶯��¼�������ݲ�׼ȷ���������˸���סԺҽ����ȡ��������ҽ���Ŀ�������Ϊ��Ժ����select top 100 *  from hbidata..infobryz 
select  * into #yzxx from hbidata..infobryz a
where exists (select 1 from #RYDJ b where a.BRID=b.GID)  

select a.BRID,a.kyzksdm,a.kyzksmc,kyzysdm,kyzysxm into #ryks from #yzxx a,(select brid,min(yzcjsj) yzcjsj from #yzxx group by brid) b
where a.BRID=b.BRID and a.yzcjsj=b.yzcjsj 

update #RYDJ 
set ryksdm=#ryks.kyzksdm ,ryksmc=#ryks.kyzksmc ,ryzgysdm=#ryks.kyzysdm,ryzgysxm=#ryks.kyzysxm
from #ryks 
where #RYDJ.gid=#ryks.brid  

--���ݻ��߱䶯��¼������Ժ����Ϊnull�����

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
   
   --�ų��ظ�����select * from aa where bah='ZY01B100778121_1'
   DELETE a 
   FROM aa5 a,(SELECT  bah ,MIN(ryrq) ryrq FROM aa5 GROUP BY bah) b 
   WHERE a.bah=b.bah AND a.ryrq>b.ryrq 
   
   UPDATE a 
   SET ryksdm=b.ryksdm,ryksmc=b.ryksmc
   FROM #RYDJ a,aa5 b 
   WHERE a.gid=b.bah AND a.ryksdm is null 
   
 
--���������Ϣ��������������������������������������������������
      

-- ��������
  Update #RYDJ
    Set hznl=nl, nldw=Anldw From (
  Select GID AGID, (Case When DateDiff(dd, csrq, rysj)<=30 Then (Case When DateDiff(dd, csrq, rysj)=0 Then 1 Else DateDiff(dd, csrq, rysj) End)
            Else (Case When DateDiff(mm, csrq, rysj)<=11 Then (Case When DateDiff(mm, csrq, rysj)=0 Then 1 Else DateDiff(mm, csrq, rysj) End)
              Else (Case When DateDiff(yy, csrq, rysj)=0 Then 1 Else DateDiff(yy, csrq, rysj) End) End) End) nl,
         (Case When DateDiff(dd, csrq, rysj)<=30 Then '��'
            Else (Case When DateDiff(mm, csrq, rysj)<=11 Then '��' Else '��' End) End) Anldw
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
             
   --�쳣������������
   UPDATE hbidata..infoRYDJB 
   SET ryksdm=1019,ryksmc='����A��' 
   where gid in ('ZY11B100778121_1','ZY11B200778121_1','ZY11B300778121_1','ZY11B400778121_1',
                 'ZY11B500778121_1','ZY11B600778121_1','ZY11B700778121_1','ZY11B800778121_1','ZY11B900778121_1')
         
            
    drop table aa5         
  -- --���ݲ������ݣ����³�Ժ����Ժʱ��ͳ�Ժ���Ҷ�Ϊnull�Ļ������� select DATEPART(dd,GETDATE())%3
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
��������������HQMS���������ϱ�ʱ���ӵ��ֶ�
if col_length('infoRYDJB', 'IsHQMSV01') is Null begin
alter table infoRYDJB Add IsHQMSV01 int -- ���ܹ�״������·��ֲ��
alter table infoRYDJB Add IsHQMSV02 int -- ���ܾ�Ƥ��״������������
alter table infoRYDJB Add IsHQMSV03 int -- ������Ѫ�������
alter table infoRYDJB Add IsHQMSV04 int -- �����Źؽ��û���
alter table infoRYDJB Add IsHQMSV05 int -- ���������Ĥ�û���
alter table infoRYDJB Add IsHQMSV06 int -- �����ӹ��г���
alter table infoRYDJB Add IsHQMSV07 int -- �����ط��������ٴ�����
alter table infoRYDJB Add IsHQMSV08 int -- ��Ѫ
alter table infoRYDJB Add IsHQMSV09 int -- ��Ѫ��Ӧ
alter table infoRYDJB Add IsHQMSV10 int -- ��Һ
alter table infoRYDJB Add IsHQMSV11 int -- ��Һ��Ӧ
alter table infoRYDJB Add IsHQMSV12 int -- ���߷��������Զ���Ժ

alter table infoRYDJB Add IsBFZ_his int -- �������߲���֢��������  ��������֢
alter table infoRYDJB Add IsFXS_his int -- �������������˨����������  ���������󲢷�֢����˨��  ��,��
alter table infoRYDJB Add IsSJMXX_his int -- �����������������Ѫ˨�������� ���������󲢷�֢�����Ѫ˨ ��,��
alter table infoRYDJB Add IsBXZ_his int -- ���������������Ѫ֢��������  ���������󲢷�֢����Ѫ֢ ��,��
alter table infoRYDJB Add IsCxOrLz_his int -- ���������������Ѫ��Ѫ�׷������� ���������󲢷�֢����Ѫ��Ѫ�� ��,��
alter table infoRYDJB Add IsSklk_his int -- �������������˿��ѿ���������  ���������󲢷�֢���˿��ѿ� ��,��
alter table infoRYDJB Add IsCs_his int -- �������������������������  ���������󲢷�֢����� ��,��
alter table infoRYDJB Add IsHxsj_his int -- �����������������˥�߷�������  ���������󲢷�֢������˥��  ��,��
alter table infoRYDJB Add IsSlDxsl_his int -- ������������������/��л���ҷ�������  ���������󲢷�֢������/��л���� ��,��
alter table infoRYDJB Add IsMz_his int -- ��������������֢��������  ������������֢ ��,��
end
*/
