/*
 ���� ��ȡ��Ժ�ǼǱ� ����Ժʱ�䷶Χ��ȡ
 ���� ZMJ
 ���� 2013-10-31
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

  --TOFFIM �����ֵ�� TSOFFM ��������׼�Ŀ�Ŀ�ֵ�  tICD10 ICD10�����ֵ��  TMRDZD �����Ϣ��   TOUSTA ת���ֵ� TNATIOM ���� 
  --tworkm ְҵ TIHSTA ��Ժ����ֵ��    TMRDDE_ADD  ������ҳ��Ϣ  TOPSM ����ICCM   TCHTYP ���ѷ�ʽ
  Set @SQLText= 
  'INSERT INTO #CH0A 
           (CHYear, CH0A00,zycs, CH0A01, CH0A02, CH0A03,CH0A03_MC,
         --������ȣ�סԺ�ţ�סԺ����,�����ţ����������������Ա��Ա����ƣ�
             CH0A04, CH0A05, CH0A06, CH0AA1, ryks,CH0A21, CH0A21_MC,CH0A56,CH0A56_mc,
         --�������ڣ����֤�ţ����䣬���䵥λ����Ժ���Ҵ���,��Ժ�Ʊ���Ժ�Ʊ�����,��Ժ;������,��Ժ;������
            CH0A24,cyks, CH0A23, CH0A23_MC, CH0A27, CH0A33, CH0A34, CH0A37, CH0A37_MC, CH0A38, CH0A38_MC,
         --��Ժ���ڣ���Ժ���Ҵ��룬��Ժ�Ʊ𣬳�Ժ�Ʊ����ƣ���Ժ���ڣ�����ҽʦ��סԺҽʦ����Ժ���ICD�룬��Ժ������ƣ���Ժ�����ICD���룬��Ժ���������
            CH0A41, CH0A41_MC, Ch0ANE, Ch0ANE_MC,CH0A82,CH0A82_mc,
         --ת����룬ת�����ƣ���Ժ��ʽ����Ժ��ʽ���ƣ����ѷ�ʽ�����ѷ�ʽ����
            CH0A10, CH0A10_MC, CH0A07, CH0A07_MC, CH0A08, CH0A08_MC,
         --������룬�������ƣ�����״�����룬����״�����ƣ�ְҵ���룬ְҵ����
            CH0A20, CH0A20_MC,   CH0A44, CH0ACD, CH0A60, CH0AN5,isbdyslzd,CH0A74,
         --��Ժ������룬��Ժ������ƣ����Ժ��Ϸ��ϱ�־����ǰ������Ϸ��ϱ�־��¼������,������Դ,������ʯ������Ƿ����,�Ƿ�Σ��
            CH0A57,CH0A58,isrgqdtc,isfyqcfzzyxk,cficujgsj,CH0A46
         --��Ѫ��Ӧ,��Һ��Ӧ,�Ƿ��˹������ѳ�,�Ƿ��Ԥ���ط���֢ҽѧ��,�ط�ICU���ʱ��,���ȴ���
            )
  Select * From OpenQuery(jcba, ''
    Select substr(to_char(a.fodate,''''yyyy-mm-dd''''),1,4) chyear,a.FBIHID,a.FBINCU,a.FMRDID,a.FNAME,a.FSEX,cast(case when a.FSEX=''''1'''' then ''''��''''  
                                                                                                                       when a.FSEX=''''2'''' then ''''Ů''''  end as varchar(30)) CH0A03_MC,
           to_char(a.FBDATE,''''yyyy-mm-dd''''),a.FIDCD,a.FAGE,case when a.FAGED=''''Y''''  then  ''''��'''' 
																	when a.FAGED=''''M''''  then  ''''��''''  
																	when a.FAGED=''''D''''  then  ''''��''''
																	when a.FAGED=''''H''''  then  ''''Сʱ''''  
																	when a.FAGED=''''S''''  then  ''''����'''' end CH0AA1,a.FIOFFI,b.fcode CH0A21,c.fdesc CH0A21_MC,a.frysource,n.fdesc CH0A56_mc,
           to_char(a.FIHDAT,''''yyyy-mm-dd''''),a.FOOFFI,d.fcode CH0A23,e.fdesc CH0A23_MC,to_char(a.FODATE,''''yyyy-mm-dd''''),a.FZZYS,a.FZYYS,a.FRYZD,f.fdesc CH0A37_MC,g.ficd,g.fdesc_doc,
           g.FOTHST,h.fdesc CH0A41_MC,flevway,i.fdesc Ch0ANE_MC,a.FCHTYP CH0A82 ,r.fdesc CH0A82_mc,
           j.fid CH0A41,a.FNATIO,a.FMARRY,case when a.FMARRY=1 then ''''δ''''
                                               when a.FMARRY=2 then ''''��''''
                                               when a.FMARRY=3 then ''''ɥ''''
                                               when a.FMARRY=4 then ''''��''''
                                               when a.FMARRY=9 then ''''����'''' end CH0A07_MC,a.FWORK,k.fdesc CH0A08_MC,
           a.FIHSTA,l.fdesc CH0A20_MC,a.FRYYCY,a.FSQYSH,to_char(a.fudate,''''yyyy-mm-dd''''),a.FSOURCE,case when m.F27=1 then ''''��'''' 
                                                                                                            when m.F27=2 then ''''��'''' else null  end isbdyslzd,a.FBWBZ,
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
  
  --HIS��������ʱ���������û�����Ҷ��գ���ᵼ��cyks��ch0a23Ϊnullֵ
  update  a 
  SET cyks=B.FOFFIB,CH0A23=C.FCODE
  from #CH0A a,(select * from jcba..MHIS.T_ITF_OFFI) B,(select * from jcba..MHIS.TOFFIM ) C
  WHERE a.cyks=b.FOFFIA AND b.FOFFIA=C.FOFFN  AND ISNUMERIC(A.CYKS)<>1
                                  
                                  
--������ҽ����סԺҽ��������ҽ��������ҽ�������滻ΪID


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

