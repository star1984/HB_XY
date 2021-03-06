USE [HBI_hmi]
GO
/****** Object:  StoredProcedure [dbo].[P_DBZWSBYLB]    Script Date: 08/14/2015 13:39:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[P_DBZWSBYLB]
@startDate Varchar(10),@EndDate Varchar(10)
AS
Begin
--declare @startDate Varchar(10),@EndDate Varchar(10)
--set @startDate='2015-07-14'
--set @EndDate='2015-08-14'
--drop table #YLB,#WSBDBZ

--取得主要诊断和手术编码
Select CH0A38 ICD,CH0A38_mc ICD_MC,CH0E08 SS_BM,CH0E08_MC SS_MC,a.CH0A56 rytj, Convert(Varchar(50),CH0A01)+'_'+Convert(Varchar(4),A.CHYear) GID,
       Convert(int,SubString(CH0A01,len(CH0A01)-1,2)) zycs,CH0A00 zyh
  Into #DBZZDXX       
  from HBIData.dbo.VsCH0A A
      Left join HBIData.dbo.VsCH0E e on a.CHYEAR=e.CHYEAR and a.CH0A01=e.CH0E01 and CH0E07='1'
  where CH0A27 between @startDate and @EndDate

--
Select brbh,hzxm,zgys_id,xb,nl,A.zyh,B.zycs,cyks_id,rydate,cydate,ICD_MC,ICD,SS_MC,SS_BM,zssrq,b.rytj
  Into #WSBDBZ 
  from MPEHR.dbo.THzxxb a inner join #DBZZDXX b on a.zyh=b.zyh and a.zycs=b.zycs 

--30天内同一病人同一病种不需要重复上报 
select * into #aa from 
(
Select a.brbh,cyDate,'髋关节置换术' mc from MPEHR.dbo.TBZ3_Kgjzhs a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
union 
Select a.brbh,cyDate,'肺炎(儿童)' mc from MPEHR.dbo.TBZ3_Sqhdxfy_ET a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
union 
Select a.brbh,cyDate,'冠状动脉' mc from MPEHR.dbo.TBZ3_Gzdmplyz a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
union 
Select a.brbh,cyDate,'脑梗塞' mc from MPEHR.dbo.TBZ3_Ngs a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
union 
Select a.brbh,cyDate,'肺炎(成人)' mc from MPEHR.dbo.TBZ3_Sqhdxfy_CR a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
union 
Select a.brbh,cyDate,'围手术' mc from MPEHR.dbo.TBZ3_Wssqyfgr a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
union 
Select a.brbh,cyDate,'膝关节' mc from MPEHR.dbo.TBZ3_Xgjzhs a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
union 
Select a.brbh,cyDate,'心肌梗死' mc from MPEHR.dbo.TBZ3_Jxxjgs a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
union 
Select a.brbh,cyDate,'心力衰竭' mc from MPEHR.dbo.TBZ3_Xlsj a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh
union 
Select a.brbh,cyDate,'剖宫产' mc from MPEHR.dbo.TBZ3_Pgc a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
union 
Select a.brbh,cyDate,'围手术期预防深静脉血栓栓塞' mc from MPEHR.dbo.TBZ3_Wssqyfsjmxs a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
union 
Select a.brbh,cyDate,'慢性阻塞性肺疾病' mc from MPEHR.dbo.TBZ3_mxzsxf a inner join  MPEHR.dbo.THzxxb b on A.brbh=B.brbh 
) a


Select brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,dbztype,isSB
 Into #YLB From (
--髋关节置换术未上报
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'1' dbztype,0 isSB
  from #WSBDBZ 
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Kgjzhs) 
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='髋关节置换术')
      and (   SS_BM in ('81.51003','81.52002','81.52003','81.53002') or left(ICD,5) between 'M16.0' and 'M16.9' 
           or  ICD between 'T84.000' and 'T84.003' OR ICD='T84.501' or ICD='T84.806' ) 
      and NL>18  and   DATEDIFF(DD,ryDate,cydate)<=120
 union
--肺炎(儿童)
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'2' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Sqhdxfy_ET) 
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='肺炎(儿童)' ) 
       and  (left(ICD,3) between 'J13' and 'J15'  OR left(ICD,3)='J18') 
       and rytj<>'3' and NL<=18 and DATEDIFF(DD,ryDate,cydate)<=60  
 union
--冠状动脉
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'3' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Gzdmplyz) 
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='冠状动脉' )
       and  ( LEFT(ICD,5) in ('I25.1','I25.2')  and LEFT(SS_BM,4) BETWEEN '36.10' AND '36.17' ) and NL>18  and  DATEDIFF(DD,ryDate,cydate)<=120 
 union
--脑梗塞
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'4' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Ngs) 
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='脑梗塞' ) 
       and  left(ICD,5) in ('I63.0','I63.1','I63.2','I63.3','I63.4','I63.5','I63.6','I63.8','I63.9')
       and rytj<>'3' and NL>18  and   DATEDIFF(DD,ryDate,cydate)<=120
 union
--肺炎(成人)
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'5' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Sqhdxfy_CR) 
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='肺炎(成人)' ) 
       and  (left(ICD,3) between 'J13' and 'J15'  OR left(ICD,3)='J18')  
       and rytj<>'3' and NL>18  and DATEDIFF(DD,ryDate,cydate)<=60     
 union
--围手术
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'6' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Wssqyfgr) 
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='围手术' ) 
       and   ( LEFT(SS_BM,3) in ('06.2','38.1','47.0','53.0','53.1','68.3','80.6') or
               LEFT(SS_BM,4) in ('01.24','35.00','35.01','35.02','35.03','35.04','51.23','80.50','81.11','81.12','81.13','81.14','81.15','81.16','81.17','81.18')
              ) and   DATEDIFF(DD,ryDate,cydate)<=120
 union
--膝关节
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'7' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Xgjzhs)  
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='膝关节' ) 
       and (SS_BM in ('81.54002','81.54004','81.54005','81.54007','81.55001')
       OR ICD between 'T84.000' and 'T84.001'  OR LEFT(ICD,5) between 'M17.0' and 'M17.9' OR ICD='T84.004' or ICD='T84.502' or ICD='T84.807')
       and NL>18  and DATEDIFF(DD,ryDate,cydate)<=120 
 union
--心肌梗死
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'8' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Jxxjgs) 
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='心肌梗死' ) 
       and left(ICD,5) in ('I21.0','I21.1','I21.2','I21.3','I21.9')  and rytj<>'3' and NL>18 
       and icd not in ('I21.401','I21.402','I21.403','I21.901') and DATEDIFF(DD,ryDate,cydate)<=120
 union
--心力衰竭
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'9' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Xlsj) 
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='心力衰竭' )  
       and LEFT(ICD,5) in ('I50.0','I50.1','I50.9') and LEFT(ICD,5) not in ('O75.4','O08.8','P29.0') and LEFT(ICD,3) not between 'O00' and 'O07' 
       AND LEFT(ICD,3)!='I15' AND SS_BM NOT BETWEEN '37.61003' AND '37.95001' 
       and rytj<>'3' and NL>18  and DATEDIFF(DD,ryDate,cydate)<=120

union
--剖宫产
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'10' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Pgc)  
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='剖宫产' )  
       --and ICD in ('O82.0','O82.1','O82.2','O82.8','O82.9')
       and SS_BM in ('74.0','74.1','74.2','74.4','74.9')
       and rytj<>'3' and NL>18   and DATEDIFF(DD,ryDate,cydate)<=120
union
--围手术期预防深静脉血栓栓塞
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'11' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_Wssqyfsjmxs) 
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='围手术期预防深静脉血栓栓塞' )
       and LEFT(SS_BM,3) in ('35.2','81.0','81.3')
       and rytj<>'3' and NL>18   and DATEDIFF(DD,ryDate,cydate)<=120
union
--慢性阻塞性肺疾病
Select distinct brbh,zyh,zycs,hzxm,zgys_id,xb,nl,cyks_id,rydate,cydate,ICD_MC,ICD,zssrq,SS_MC,SS_BM,'12' ,0 isSB
  from #WSBDBZ
 where brbh not in (Select brbh from MPEHR.dbo.TBZ3_mxzsxf) 
       and  not exists (select 1 from #aa where left(#WSBDBZ.brbh,CHARINDEX('_',#WSBDBZ.brbh)-1)=left(#aa.brbh,CHARINDEX('_',#aa.brbh)-1) 
                                                and right(#WSBDBZ.brbh,len(#WSBDBZ.brbh)-CHARINDEX('_',#WSBDBZ.brbh))=right(#aa.brbh,len(#aa.brbh)-CHARINDEX('_',#aa.brbh))+1 
                                                and DATEDIFF(DD,#aa.cydate,#WSBDBZ.cydate)<30 and #aa.mc='慢性阻塞性肺疾病' )
       and  ICD between 'J44.000' and  'J44.900'  AND  rytj<>'3' and NL>18 and DATEDIFF(DD,ryDate,cydate)<=120     
 ) A where cydate is not null


 
 Select GID,brbh,bgys,icd10,ICDMC,ssbm,dbztype,issb Into #DBZYSBHZ From (
   Select GID,brbh,bgys,zyzdICD10bmmc icd10, B.WbName ICDMC,'' ssbm,'8' dbztype ,1 issb 
     from MPEHR.dbo.TBZ3_Jxxjgs  a left Join MPEHR..TWordBook B on a.zyzdICD10bmmc=b.WBCode and b.WBTypeCode='20011'
    where bgsj between @startDate and @EndDate
    Union
   Select GID,brbh,bgys,(Case When zyzdICD10bmmc='1' Then '置换术' When zyzdICD10bmmc='2' Then '翻修术' Else zyzdICD10bmmc End) icd10,B.WbName,ICD9CM3bmmc,'1',1 issb 
     from MPEHR.dbo.TBZ3_Kgjzhs  a left Join MPEHR..TWordBook B on a.zyzdICD10bmmc=b.WBCode and b.WBTypeCode='23005'
    where bgsj between @startDate and @EndDate
    Union
   Select GID,brbh,bgys,zyzdICD10bmmc,B.WbName,ICD9CM3bmyssmc,'3',1 issb 
     from MPEHR.dbo.TBZ3_Gzdmplyz a left Join MPEHR..TWordBook B on a.zyzdICD10bmmc=b.WBCode and b.WBTypeCode='32005'
    where bgsj between @startDate and @EndDate
     Union
   Select GID,brbh,bgys,ICD10dm,B.WbName,'','12',1 issb 
     from MPEHR.dbo.TBZ3_mxzsxf a left Join MPEHR..TWordBook B on a.ICD10dm=b.WBCode and b.WBTypeCode='25027'
    where bgsj between @startDate and @EndDate
     Union
   Select GID,brbh,bgys,Icd10dm,B.WbName,icd9m3cdm,'4',1 issb 
     from MPEHR.dbo.TBZ3_Ngs a left Join MPEHR..TWordBook B on a.Icd10dm=b.WBCode and b.WBTypeCode='25088'
    where bgsj between @startDate and @EndDate
     Union
   Select GID,brbh,bgys,Icd10dm,B.WbName,icd9cm3,'10',1 issb 
     from MPEHR.dbo.TBZ3_Pgc  a left Join MPEHR..TWordBook B on a.Icd10dm=b.WBCode and b.WBTypeCode='25157'
    where bgsj between @startDate and @EndDate
     Union
   Select GID,brbh,bgys,zyzdICD10bmmc,B.WbName,'','5',1 issb 
     from MPEHR.dbo.TBZ3_Sqhdxfy_CR A left Join MPEHR..TWordBook B on a.zyzdICD10bmmc=b.WBCode and b.WBTypeCode='22004'
    where bgsj between @startDate and @EndDate
     Union
   Select GID,brbh,bgys,icd10dm,B.WbName,'','2',1 issb 
     from MPEHR.dbo.TBZ3_Sqhdxfy_ET a left Join MPEHR..TWordBook B on a.icd10dm=b.WBCode and b.WBTypeCode='25060'
    where bgsj between @startDate and @EndDate
     Union
   Select GID,brbh,bgys,'',B.WbName,icd9bm,'6',1 issb 
     from MPEHR.dbo.TBZ3_Wssqyfgr a left Join MPEHR..TWordBook B on a.icd9bm=b.WBCode and b.WBTypeCode='25005'
    where bgsj between @startDate and @EndDate
     Union
   Select GID,brbh,bgys,'',B.WbName,icdmc3,'11',1 issb 
     from MPEHR.dbo.TBZ3_Wssqyfsjmxs a left Join MPEHR..TWordBook B on a.icdmc3=b.WBCode and b.WBTypeCode='25205'
    where bgsj between @startDate and @EndDate
     Union
   Select GID,brbh,bgys,(Case When zyzdICD10bmmc='1' Then '置换术' When zyzdICD10bmmc='2' Then '翻修术' Else zyzdICD10bmmc End) icd10,B.WbName,ICD9CM3bmyssmc,'7',1 issb 
     from MPEHR.dbo.TBZ3_Xgjzhs  a left Join MPEHR..TWordBook B on a.zyzdICD10bmmc=b.WBCode and b.WBTypeCode='24005'
    where bgsj between @startDate and @EndDate
     Union
   Select GID,brbh,bgys,zyzdICD10bmmc,B.WbName,ICD9CM3ssbmmc,'9',1 issb 
     from MPEHR.dbo.TBZ3_Xlsj a left Join MPEHR..TWordBook B on a.zyzdICD10bmmc=b.WBCode and b.WBTypeCode='21005'
    where bgsj between @startDate and @EndDate
 ) A
 

Select brbh,hzxm,zyh,zycs,bgys,xb,nl,rydate,cydate,cyks_id,ICD_MC,ICD,zssrq,SS_MC,SS_BM,dbztype,isSB,ISCheck
  Into #YLB_ALL
  From (
  Select A.brbh,hzxm,zyh,zycs,bgys,xb,nl,rydate,cydate,cyks_id,a.ICDMC ICD_MC,a.icd10 ICD,
         '' zssrq,E.WBName SS_MC,E.WBCode SS_BM,dbztype, isSB,isnull(B.shzt,'') ISCheck
    from #DBZYSBHZ A 
         left Join MPEHR.dbo.T_SHYJ B on A.Gid=b.GID  
         Left Join MPEHR.dbo.THzxxb C on a.brbh=C.brbh
         Left Join MPEHR.dbo.TWordBook E on a.ssbm=E.WBCode and isnull(a.ssbm,'')<>''  
   Union
  Select brbh,hzxm,zyh,zycs,zgys_id,xb,nl,rydate,cydate,cyks_id,ICD_MC,ICD,zssrq,SS_MC,SS_BM,dbztype,isSB,'' from #YLB
  ) A


delete T_DBZ3_WSBBRYLB From #YLB_ALL B where T_DBZ3_WSBBRYLB.brbh=B.brbh and T_DBZ3_WSBBRYLB.dbztype=B.dbztype 
Insert Into T_DBZ3_WSBBRYLB(biyear,biquarter,bimonth,biweek,bidate,brbh,hzxm,zyh,zycs,zgys,xb,nl,rydate,
                            cydate,dqszks,cyzdmc,cyzdicd10,zssrq,zssmc,zssbm,dbztype,isSB,ISCheck)
Select distinct YEAR(cydate),DATEPART(qq,cydate),DATEPART(mm,cydate),DATEPART(ww,cydate),cydate, 
       brbh,hzxm,zyh,zycs,bgys,xb,nl,rydate,cydate,cyks_id,ICD_MC,ICD,zssrq,SS_MC,SS_BM,dbztype,isSB,ISCheck
  from #YLB_ALL order by brbh 
  
--当医生gh和医生userid不一致时执行这一步select * from  hbidata..WB_Doctor
update T_DBZ3_WSBBRYLB
set zgys=a.gh
from hbidata..WB_Doctor a 
where T_DBZ3_WSBBRYLB.zgys=a.UserID

End


/*
Select * from MPEHR.dbo.T_shyj
 truncate Table T_DBZ3_WSBBRYLB
 Update T_DBZ3_WSBBRYLB set issb=0
 Select * from T_DBZ3_WSBBRYLB
exec P_DBZWSBYLB '2015-11-01','2015-12-14'
Select * from MPEHR.dbo.TBZ3_NGS
truncate table T_DBZ3_WSBBRYLB
Select * from MPEHR.dbo.TUserInfo where UserName='陈云霞'
Select * from MPEHR.dbo.TuseKs where kscode='47' Ksname like '%呼吸科%'
Select * from T_DBZ3_WSBBRYLB 
exec P_DBZZDMC '0000558301_2015'
*/