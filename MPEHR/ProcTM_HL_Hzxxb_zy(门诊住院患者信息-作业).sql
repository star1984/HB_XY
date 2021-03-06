USE [mpehr]
GO
/****** Object:  StoredProcedure [dbo].[ProcTM_HL_Hzxxb_zy]    Script Date: 08/10/2016 11:20:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter Procedure [dbo].[ProcTM_HL_Hzxxb_zy]
  @begindate datetime,
  @enddate datetime
As
Begin

     
     declare @SDate Varchar(10),@DEnd Varchar(10)
     set @SDate=Convert(Varchar(10),Convert(datetime,@begindate),120)
     set @DEnd=Convert(Varchar(10),Convert(datetime,@enddate),120)

--获取患者基本信息

   --住院患者基本信息 Select top 1000 * From HBIData.dbo.infoRYDJB where zyh='ZY010000761002' 
     Select Gid,bah,zyh,A.zycs,zgysdm zgys_ID,zgysxm,ryksmc,ryksdm,cyksmc,cyksdm,hzxm,(Case When hzxb=1 Then '男' Else '女' End) XB ,
           hznl,nldw,csrq,rysj,cycwdm,cycwmc,cysj,Convert(numeric(18,2),0) zyzfy,Convert(numeric(18,2),0) YF,
           Convert(numeric(18,2),0) SSF,CASE WHEN datediff(dd,rysj,cysj)=0 THEN 1 ELSE datediff(dd,rysj,cysj) end zyts, ryzd , ryzdICD ,cyzd,cyzdicd,
           zssrq=(Select max(ssrq) From HBIData.dbo.infoBrsssqd I 
                   where Convert(varchar(20),A.bah)+Convert(varchar(20),A.zycs)=Convert(varchar(20),I.bah)+Convert(varchar(20),I.zycs) ),
           zssmc,zssICCM,null zssBw,lxr_dz lxdz,zjhm zjh,tel,ryksdm dqszks_ID,ryksmc dqszks,(Case When zssICCM Like '13.71%' Then 1 Else 0 End) IsIsBNZ,
           ryzgysdm,ryzgysxm
      Into #BRXX_ZY
      from HBIData.dbo.infoRYDJB A 
      where  (CONVERT(varchar(10),cysj,120) between CONVERT(varchar(10),@begindate,120) and CONVERT(varchar(10),@enddate,120) OR ISNULL(cysj,'')='') 
              AND bah NOT LIKE 'B%'
      
    --门诊患者基本信息SELECT TOP 1000 gid,brid,mzh,ghysdm,ghysxm,ghksdm,ghksmc,hzxm,(Case When hzxb=1 Then '男' Else '女' End) XB ,sfzhm,hznl,NLDW,csrq,ghsj,jzsj,mzzd_ICD,mzzd_mc FROM hbidata..infoMZGH
    SELECT  gid,brid,mzh,ghysdm,ghysxm,ghksdm,ghksmc,hzxm,(Case When hzxb=1 Then '男' Else '女' End) XB,sfzhm ,hznl,NLDW,csrq,ghsj,jzsj,mzzd_ICD,mzzd_mc INTO  #BRXX_MZ FROM  hbidata..infoMZGH
    WHERE CONVERT(varchar(10),ghsj,120) between CONVERT(varchar(10),@begindate,120) and CONVERT(varchar(10),@enddate,120)
      
    
    --提取住院患者费用信息  select top 1000 *  from HBIData.dbo.infoZYSF where sflbmc like '%药%'
    Select A.bah,zycs,Sum(je) zyzfy ,SSF=Sum(Case When sflbmc like '%手术%' Then je Else 0 End),  
           YF=Sum(Case When sflbmc like '%药%' Then je Else 0 End)
      Into #BRZYZFY 
      from HBIData.dbo.infoZYSF A
     where Exists (Select 1 From #BRXX_ZY B where Convert(varchar(20),A.bah)+Convert(varchar(20),A.zycs)=Convert(varchar(20),B.bah)+Convert(varchar(20),B.zycs))
     Group by A.bah,A.zycs
    --修改住院患者费用信息
    UpDate #BRXX_ZY set zyzfy= A.zyzfy,YF=A.YF,SSF=A.SSF from #BRZYZFY A
    where Convert(varchar(20),A.bah)+Convert(varchar(20),A.zycs)=Convert(varchar(20),#BRXX_ZY.bah)+Convert(varchar(20),#BRXX_ZY.zycs) 
          AND isnull(cysj,'')<>''
  
    --修改病人当前所在科室 select top 1000 * from  HBIData.dbo.infoBrZhuankJL
     Select zkrq,zycs,zyh,zrksdm,zrksmc  Into #ZKXX 
     from HBIData.dbo.infoBrZhuankJL 
     where valid =1 
           and zkrq=(select max(zkrq) from  HBIData.dbo.infoBrZhuankJL a where a.valid=1 and  HBIData.dbo.infoBrZhuankJL.zyh=a.zyh and HBIData.dbo.infoBrZhuankJL.zycs=a.zycs   )
  
     Update #BRXX_ZY 
     set dqszks_ID=zrksdm,dqszks=zrksmc
     from #ZKXX B
     where  #BRXX_ZY.zyh=b.zyh and #BRXX_ZY.zycs=b.zycs 

--向2个患者信息表表灌入数据
  --向住院患者信息表Thzxxb灌入数据 truncate table  Thzxxb    select top 1000 * from    Thzxxb
    delete Thzxxb where brbh in (Select Gid from #BRXX_ZY)
    Insert Into Thzxxb(brbh,zyh,zycs,zgys_ID,zgys,ryks_ID,ryKs,cyks_ID,cyKs,hzxm,XB,NL,NL_DW,csDate,ryDate,CH_ID,CH,cyDate,
                       zyzfy,yf,ssf,zyts,ryzdmc,ryzdICD10,cyzdmc,cyzdICD10,zssrq,zssmc,zssbm,zssBw,lxdz,zjh,lxdh,dqszks_ID,dqszks)
    Select Gid,zyh,zycs,zgys_ID,zgysxm,ryksdm,ryksmc,cyksdm,cyksmc,hzxm,XB,hznl,nldw,csrq,rysj,cycwdm,cycwmc,cysj,
           zyzfy,YF,SSF,zyts,ryzd ,ryzdICD ,cyzd,cyzdicd, zssrq,zssmc,zssICCM, zssBw, lxdz,zjh,tel,dqszks_ID,dqszks
      From #BRXX_ZY 
      
    UPDATE  Thzxxb 
    SET NL_DW=REPLACE(nl_dw,'天','日')
  
    
   
  --向门诊、住院患者信息表Thzxxb_all灌入数据truncate table Thzxxb_all   select top 1000 * from Thzxxb_all where zyh like 'ZY%'
    delete Thzxxb_all where brGId in (Select gid from #BRXX_ZY)
    
    INSERT INTO [mpehr].[dbo].[THzxxb_ALL]([brGId],[hzType],[mzh],[mzghcs],[zyh],[zycs],[tjh],[bah],[sfzhm],[jzkh],[hzxm],[hznl],[hznl_dw],[hzxb],[csrq],[IsYY],[mzghys_mc],[mzghys_dm],[mzghks_mc],[mzghks_dm],[mzghsj],[mzjzsj]
                                          ,[zyzgys_mc],[zyzgys_dm],[zyszks_mc],[zyszks_dm],[rysj],[cysj],[hzlxdh],[lxrxm],[lxrdh],[minzu],[hyqk],[mzzdmc],[mzzdICD],[brid],[mzkh],[lzsj],[zxsj],[lxdz],[CardID],[hzzy],[dwdz]
                                          ,[zssbw],[IsBNZ],[TZ],[NO],[fb],[zssbm],[ryks_ID],[ryks],[cyks_ID],[cyks],[CH],[CH_ID],[zyzfy],[yf],[ssf],[zyts],[ryzdmc],[ryzdICD10],[cyzdmc],[cyzdICD10],[zssrq],[zssmc])                                     
    SELECT gid,3 hzType,NULL mzh,NULL mzghcs, zyh ,zycs,NULL tjh,bah,NULL sfzhm ,NULL jzkh,hzxm,hznl,nldw hznl_dw,xb hzxb,csrq,NULL isyy,NULL mzghys_mc,NULL mzghys_dm,NULL mzghks_mc,NULL mzghks_dm,NULL mzghsj,NULL mzjzsj
          ,ryzgysxm zyzgys_mc,ryzgysdm zyzgys_dm,dqszks zyszks_mc,dqszks_ID zyszks_dm,rysj,cysj,NULL hzlxdh,NULL lxrxm,NULL lxrdh,NULL minzu,NULL hyqk,NULL mzzdmc,NULL mzzdICD,bah brid,NULL mzkh,NULL lzsj,NULL zxsj,NULL lxdz,1 CardID,NULL hzzy,NULL dwdz
          ,NULL zssbw,NULL IsBNZ,NULL TZ,NULL AS NO,NULL fb,NULL zssbm,ryksdm ryks_ID,ryksmc ryks,cyksdm cyks_ID,cyksmc cyks,NULL CH,NULL CH_ID,zyzfy,yf,ssf,zyts,ryzd ryzdmc,ryzdICD ryzdICD10,cyzd cyzdmc,cyzdICD cyzdICD10,zssrq,zssmc
    FROM  #BRXX_ZY 

    
   delete Thzxxb_all where brGId in (Select gid from #BRXX_MZ)
   INSERT INTO [mpehr].[dbo].[THzxxb_ALL]([brGId],[hzType],[mzh],[mzghcs],[zyh],[zycs],[tjh],[bah],[sfzhm],[jzkh],[hzxm],[hznl],[hznl_dw],[hzxb],[csrq],[IsYY],[mzghys_mc],[mzghys_dm],[mzghks_mc],[mzghks_dm],[mzghsj],[mzjzsj]
                                      ,[zyzgys_mc],[zyzgys_dm],[zyszks_mc],[zyszks_dm],[rysj],[cysj],[hzlxdh],[lxrxm],[lxrdh],[minzu],[hyqk],[mzzdmc],[mzzdICD],[brid],[mzkh],[lzsj],[zxsj],[lxdz],[CardID],[hzzy],[dwdz]
                                      ,[zssbw],[IsBNZ],[TZ],[NO],[fb],[zssbm],[ryks_ID],[ryks],[cyks_ID],[cyks],[CH],[CH_ID],[zyzfy],[yf],[ssf],[zyts],[ryzdmc],[ryzdICD10],[cyzdmc],[cyzdICD10],[zssrq],[zssmc])                                     
    SELECT gid,1 hzType, mzh,NULL mzghcs,mzh zyh ,NULL zycs,NULL tjh,brid bah, sfzhm ,NULL jzkh,hzxm,hznl,nldw hznl_dw,xb hzxb,csrq,NULL isyy,ghysxm mzghys_mc,ghysdm mzghys_dm,ghksmc mzghks_mc,ghksdm mzghks_dm,ghsj mzghsj,jzsj mzjzsj
          ,ghysxm zyzgys_mc,null zyzgys_dm,ghksmc zyszks_mc,null zyszks_dm,ghsj rysj,NULL cysj,NULL hzlxdh,NULL lxrxm,NULL lxrdh,NULL minzu,NULL hyqk,mzzd_mc mzzdmc,mzzd_ICD mzzdICD, brid,NULL mzkh,NULL lzsj,NULL zxsj,NULL lxdz,1 CardID,NULL hzzy,NULL dwdz
          ,NULL zssbw,NULL IsBNZ,NULL TZ,NULL AS NO,NULL fb,NULL zssbm,null ryks_ID,null  ryks,null cyks_ID,null cyks,NULL CH,NULL CH_ID,NULL zyzfy,NULL yf,NULL ssf,NULL zyts,NULL  ryzdmc,NULL  ryzdICD10,NULL cyzdmc,NULL  cyzdICD10,NULL zssrq,NULL zssmc
    FROM  #BRXX_MZ
 
     
   
 
--------抽取诊断信息select top 1000 * from  THzxxb_Zdxx  where brbh='ZY010000783553_1'   
    Select brid brbh,zdlx zdlb,identity(int,1,1) xh,zdICD,ZDMC 
      Into #ZDXX 
      from HBIData.dbo.WB_zdxx
     where brid in (Select gid From #BRXX_ZY) 
     
     UPDATE #ZDXX 
     SET zdICD=LEFT(ZDMC,8)  
     WHERE ISNULL(zdICD,'')=''
    
    delete THzxxb_Zdxx where brbh in (Select brbh From #ZDXX)
    Insert Into THzxxb_Zdxx
    Select * from #ZDXX  
    
    
 --襄阳人民医院，根据患者最后一次院内压疮上报，更新压疮预报表上的“是否发生”标志 select * from    mpehr..THL_YCSB_M
 SELECT  a.* INTO #yc from MPEHR.dbo.THL_YCSB_M A With(nolock) INNER JOIN MPEHR.dbo.T_shyj S on a.Gid=S.Gid 
 WHERE s.shzt=1 AND ycly='4' 
       AND sbsj=(SELECT  MAX(sbsj) FROM MPEHR.dbo.THL_YCSB_M b INNER JOIN MPEHR.dbo.T_shyj c on a.Gid=S.Gid
                 WHERE a.brbh=b.brbh AND b.ycly='4' AND c.shzt=1 )
 
 UPDATE a
 SET   isfsyc=1,IsFSYC_RQ=b.sbsj
 FROM  mpehr..THL_YCYB a,#yc b 
 WHERE a.brbh=b.brbh

 UPDATE a
 SET   isfsyc=1,IsFSYC_RQ=b.sbsj
 FROM  mpehr..THL_YCYB_ET a,#yc b 
 WHERE a.brbh=b.brbh
 
End

/*

Exec ProcTM_HL_Hzxxb_zy '2016-10-01','2016-10-18'

Select * From THzxxb Where zyh='0338248'
Select * From sxdt_dtmkzyy_lc.tmkyymz.dbo.pubdictstaff Where No_Staff='687'
select top 1000  * from THzxxb_ALL
Select DoutDate,* From sxdt_dtmkzyy_lc.Tmkyymz.dbo.hrFirstpage Where cCaseCode='0338248'

Select * From THZXXB Where dqszks='眼科'

exec sp_executesql N'Exec dbo.ProcTM_HL_Hzxxb_zy @begindate = @p0, @enddate = @p1',N'@p0 datetime,@p1 datetime',@p0='2013-01-22 00:00:00:000',@p1='2013-01-23 00:00:00:000'

  Select iOPSList,iDiagnoseID,IDoctorID,iOnePerson,iTwoPerson,iThreePerson,dOpsdate,cOPSName,cOPSCode,cOPSLocation
    Into #hropsList From sxdt_dtmkzyy_lc.Tmkyymz.dbo.hropsList A 
   Where Exists(Select 1 From THZXXB B Where A.iDiagnoseID=B.brbh)


  Update THZXXB Set IsBNZ=1 Where Exists(Select 1 From #hropsList A Where THZXXB.brbh=A.iDiagnoseID And cOPSCode Like '13.71%')



*/

