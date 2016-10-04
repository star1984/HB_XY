/*
 功能 读取入院登记表 按入院时间范围读取
 作者 ZMJ
 日期 2013-10-31
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_VsCH0A_ETL' AND type = 'P')
   DROP PROCEDURE P_VsCH0A_ETL
GO

Create PROCEDURE P_VsCH0A_ETL
   @StartDate varchar(10), @EndDate varchar(10)

As
begin 
  SET @EndDate=CONVERT(varchar(10),GETDATE(),120)
  SET @StartDate=CONVERT(varchar(10),DATEADD(MM,-3,@EndDate),120)

  Declare @SQLText varchar(8000)
  Select * into #CH0A From VsCH0A Where 1=2

  --TOFFIM 科室字典表 TSOFFM 卫生部标准的科目字典  tICD10 ICD10编码字典表  TMRDZD 诊断信息表   TOUSTA 转归字典 TNATIOM 民族 
  --tworkm 职业 TIHSTA 入院情况字典表    TMRDDE_ADD  病案附页信息  TOPSM 手术ICCM   TCHTYP 付费方式
  Set @SQLText= 
  'INSERT INTO #CH0A 
           (CHYear, CH0A00,zycs, CH0A01, CH0A02, CH0A03,CH0A03_MC,
         --病案年度，住院号，住院次数,病案号，患者姓名，患者性别，性别名称，
             CH0A04, CH0A05, CH0A06, CH0AA1, ryks,CH0A21, CH0A21_MC,CH0A56,CH0A56_mc,
         --出生日期，身份证号，年龄，年龄单位，入院科室代码,入院科别，入院科别名称,入院途径代码,入院途径名称
            CH0A24,cyks, CH0A23, CH0A23_MC, CH0A27, CH0A33, CH0A34, CH0A37, CH0A37_MC, CH0A38, CH0A38_MC,
         --入院日期，出院科室代码，出院科别，出院科别名称，出院日期，主治医师，住院医师，入院诊断ICD码，入院诊断名称，出院主诊断ICD编码，出院主诊断名称
            CH0A41, CH0A41_MC, Ch0ANE, Ch0ANE_MC,CH0A82,CH0A82_mc,
         --转归代码，转归名称，离院方式，离院方式名称，付费方式，付费方式名称
            CH0A10, CH0A10_MC, CH0A07, CH0A07_MC, CH0A08, CH0A08_MC,
         --民族代码，民族名称，婚姻状况代码，婚姻状况名称，职业代码，职业名称
            CH0A20, CH0A20_MC,   CH0A44, CH0ACD, CH0A60, CH0AN5,isbdyslzd,CH0A74,
         --入院情况代码，入院情况名称，入出院诊断符合标志，术前术后诊断符合标志，录入日期,病人来源,冰冻与石蜡诊断是否符合,是否危重
            CH0A57,CH0A58,isrgqdtc,isfyqcfzzyxk,cficujgsj,CH0A46
         --输血反应,输液反应,是否人工气道脱出,是否非预期重返重症医学科,重返ICU间隔时间,抢救次数
            )
  Select * From OpenQuery(jcba, ''
    Select substr(to_char(a.fodate,''''yyyy-mm-dd''''),1,4) chyear,a.FBIHID,a.FBINCU,a.FMRDID,a.FNAME,a.FSEX,cast(case when a.FSEX=''''1'''' then ''''男''''  
                                                                                                                       when a.FSEX=''''2'''' then ''''女''''  end as varchar(30)) CH0A03_MC,
           to_char(a.FBDATE,''''yyyy-mm-dd''''),a.FIDCD,a.FAGE,case when a.FAGED=''''Y''''  then  ''''年'''' 
																	when a.FAGED=''''M''''  then  ''''月''''  
																	when a.FAGED=''''D''''  then  ''''日''''
																	when a.FAGED=''''H''''  then  ''''小时''''  
																	when a.FAGED=''''S''''  then  ''''分钟'''' end CH0AA1,a.FIOFFI,b.fcode CH0A21,c.fdesc CH0A21_MC,a.frysource,n.fdesc CH0A56_mc,
           to_char(a.FIHDAT,''''yyyy-mm-dd''''),a.FOOFFI,d.fcode CH0A23,e.fdesc CH0A23_MC,to_char(a.FODATE,''''yyyy-mm-dd''''),a.FZZYS,a.FZYYS,a.FRYZD,f.fdesc CH0A37_MC,g.ficd,g.fdesc_doc,
           g.FOTHST,h.fdesc CH0A41_MC,flevway,i.fdesc Ch0ANE_MC,a.FCHTYP CH0A82 ,r.fdesc CH0A82_mc,
           j.fid CH0A41,a.FNATIO,a.FMARRY,case when a.FMARRY=1 then ''''未''''
                                               when a.FMARRY=2 then ''''已''''
                                               when a.FMARRY=3 then ''''丧''''
                                               when a.FMARRY=4 then ''''离''''
                                               when a.FMARRY=9 then ''''其他'''' end CH0A07_MC,a.FWORK,k.fdesc CH0A08_MC,
           a.FIHSTA,l.fdesc CH0A20_MC,a.FRYYCY,a.FSQYSH,to_char(a.fudate,''''yyyy-mm-dd''''),a.FSOURCE,case when m.F27=1 then ''''是'''' 
                                                                                                            when m.F27=2 then ''''否'''' else null  end isbdyslzd,a.FBWBZ,
           a.FSXFY,a.FSYFY,m.f17,m.f18,m.f19,a.FSALCU
           from TMRDDE a left join TOFFIM b on a.FIOFFI=b.FOFFN 
                         left join TSOFFM c on b.FCODE=c.fid 
                         left join TOFFIM d on a.FOOFFI=d.FOFFN 
                         left join TSOFFM e on d.fcode=e.fid
                         left join tICD10 f on a.FRYZD=f.FICD10
                         left join TMRDZD g on a.FMRDID=g.FMRDID and  g.FZDTYP=''''1''''
                         left join TOUSTA h on g.FOTHST=h.fid 
                         left join TSTAND_LIST i on a.flevway=i.fid and i.FTYPE=''''MRD200LY''''
                         left join TNATIOM j on a.FNATIO=j.fdesc 
                         left join tworkm k on a.FWORK=k.fid 
                         left join TIHSTA l on a.FIHSTA=l.fid 
                         left join TMRDDE_ADD m on a.FMRDID=m.FMRDID 
                         left join (select distinct fid,fdesc from TSTAND_LIST where  FTYPE=''''mrd200ry'''') n on a.frysource=n.fid 
                         LEFT JOIN TMRDOP O ON a.FMRDID=O.FMRDID and O.fseq=''''1''''
                         left join (SELECT FID,FQUN,FDESC FROM TOPSM WHERE FST IS NULL) p on o.FOPID=P.FID 
                         left join (SELECT distinct FID,FQUN,FDESC FROM TSTAND_LIST WHERE FTYPE=''''MRD200.DW_31.FS06'''') q on o.FS06=q.fdesc   
                         left join TCHTYP r on   a.FCHTYP=r.fid                                                                            
    Where (to_char(a.fudate,''''yyyy-mm-dd'''')>='''''+@StartDate+''''' and to_char(a.fudate,''''yyyy-mm-dd'''')<='''''+@EndDate+''''')or
          (to_char(a.fodate,''''yyyy-mm-dd'''')>='''''+@StartDate+''''' and to_char(a.fodate,''''yyyy-mm-dd'''')<='''''+@EndDate+''''') '')'
--  print (@SQLText)  
  exec (@SQLText)
 
  -- alter table   VsCH0A alter column CH0A03 varchar(10) 
  
  --HIS新增科室时，如果病案没做科室对照，则会导致cyks和ch0a23为null值
  update  a 
  SET cyks=B.FOFFIB,CH0A23=C.FCODE
  from #CH0A a,(select * from jcba..MHIS.T_ITF_OFFI) B,(select * from jcba..MHIS.TOFFIM ) C
  WHERE a.cyks=b.FOFFIA AND b.FOFFIA=C.FOFFN  AND ISNUMERIC(A.CYKS)<>1
                                  
                                  
--将主治医生、住院医生、手术医生、麻醉医生姓名替换为ID


  Delete VsCH0A
  Where Exists(Select 1 From #CH0A Where VsCH0A.CHYear=#CH0A.CHYear and VsCH0A.CH0A01=#CH0A.CH0A01)
  
  Select CHYear,FMRDID into #a From OpenQuery(jcba,'select substr(to_char(fodate,''yyyy-mm-dd''),1,4) CHYear,FMRDID from TMRDDE where substr(to_char(fodate,''yyyy-mm-dd''),1,4)>=''2015''')
  
  Delete VsCH0A
  Where not Exists(select 1 from #a B 
                   Where VsCH0A.CHYear=B.chyear and VsCH0A.CH0A01=B.FMRDID)

  Insert Into VsCH0A( CHYear, CH0A00,zycs, CH0A01, CH0A02, CH0A03,CH0A03_MC,
                     CH0A04, CH0A05, CH0A06, CH0AA1, ryks,CH0A21, CH0A21_MC,CH0A56,CH0A56_mc,
                     CH0A24,cyks, CH0A23, CH0A23_MC, CH0A27, CH0A33, CH0A34, CH0A37, CH0A37_MC, CH0A38, CH0A38_MC,
                     CH0A41, CH0A41_MC, Ch0ANE, Ch0ANE_MC,CH0A82,CH0A82_mc,
                     CH0A10, CH0A10_MC, CH0A07, CH0A07_MC, CH0A08, CH0A08_MC,
                     CH0A20, CH0A20_MC,   CH0A44, CH0ACD, CH0A60, CH0AN5,isbdyslzd,CH0A74,
                     CH0A57,CH0A58,isrgqdtc,isfyqcfzzyxk,cficujgsj,CH0A46 ) 
  Select CHYear,CH0A00,zycs,CH0A01,CH0A02,CH0A03,CH0A03_MC,
         CH0A04,CH0A05,CH0A06,CH0AA1,ryks,CH0A21, CH0A21_MC,CH0A56,CH0A56_mc,
         CH0A24,cyks, CH0A23, CH0A23_MC, CH0A27, CH0A33, CH0A34, CH0A37, CH0A37_MC, CH0A38, CH0A38_MC,
         CH0A41, CH0A41_MC, Ch0ANE, Ch0ANE_MC,CH0A82,CH0A82_mc,
         CH0A10, CH0A10_MC, CH0A07, CH0A07_MC, CH0A08, CH0A08_MC,
         CH0A20, CH0A20_MC,   CH0A44, CH0ACD, CH0A60, CH0AN5,isbdyslzd,CH0A74,
         CH0A57,CH0A58,isrgqdtc,isfyqcfzzyxk,cficujgsj,CH0A46
  From #CH0A

End

/*
Select * From VsCH0A Where CH0A27>='2014-03-01' and Convert(varchar(10), CH0A27, 120)<='2014-03-31'
Exec P_VsCH0A_ETL '2015-01-01', '2015-10-29'
alter table VsCH0A alter column CH0A82 varchar(10)
*/

