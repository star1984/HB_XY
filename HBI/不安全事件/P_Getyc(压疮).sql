USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[P_GetYC]    Script Date: 10/18/2016 20:00:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_GetYC]
(@startdate Varchar(10),@EndDate Varchar(10))
AS
Begin
--declare @serverDay Datetime,@EndDate datetime 
--set @serverDay='2015-05-17'
--set @EndDate='2015-06-18'

--ycly 0 家庭，1 养老院，2 其他医院，3 其他来源，4 院内
--根据需要的指标取出对应的值（入院前）  Drop table #YC,#YC_BW
Select a.sbsj RQ, a.bgks iDeptId,a.brbh,
       A.Mid,a.ycly,
       kysbzzss=MAX( Case When B.fq='5'  Then 1 Else 0 End),--可疑深部组织损伤
       yyjyc=MAX( Case When B.fq='1'  Then 1 Else 0 End),--一级压疮
       yejyc=MAX( Case When B.fq='2'  Then 1 Else 0 End),--二级压疮
       ysjyc=MAX( Case When B.fq='3'  Then 1 Else 0 End),--三级压疮
       ysijyc=MAX(Case When B.fq='4'  Then 1 Else 0 End),--四级压疮
       fsbnfqyc=MAX( Case When B.fq='6'  Then 1 Else 0 End),--发生不能分期压疮
       jtrzsyycdhz=MAX(Case When a.ycly = '0'  Then 1 Else 0 End) ,--家庭
       zylyrzsyycdhz=MAX(Case When a.ycly = '1'  Then 1 Else 0 End) ,--养老院
       zqtyyzrsyycdhz=MAX(Case When a.ycly = '2'  Then 1 Else 0 End) ,--其他医院
       zqtlyrzsyycdhz=MAX(Case When a.ycly = '3'  Then 1 Else 0 End),  --其他来源
       dwzgycrs=max(Case When B.bw in ('00') Then 1 Else 0 End),  --是否骶尾椎骨处压疮发生
       zgcycrs=max(Case When B.bw in ('42','43','44','45') Then 1 Else 0 End),  --是否坐骨椎骨处压疮发生
       ggclycrs=max(Case When B.bw in ('06','07') Then 1 Else 0 End),  --是否股骨椎骨处压疮发生
       gengycrs=max(Case When B.bw in ('03','04') Then 1 Else 0 End),  --是否跟骨椎骨处压疮发生
       zlcycrs=max(Case When B.bw in ('21','22','28','29','39','40') Then 1 Else 0 End),  --是否足踝椎骨处压疮发生
       jjgycrs=max(Case When B.bw in ('11','12') Then 1 Else 0 End),  --是否肩胛骨椎骨处压疮发生
       zgycrs=max(Case When B.bw in ('36')  Then 1 Else 0 End),  --是否枕骨椎骨处压疮发生
       jizhuycrs= max(Case When B.bw in ('05','08') Then 1 Else 0 End),  --是否脊柱处压疮发生           
       kuanbuycrs= max(Case When B.bw in ('14','15') Then 1 Else 0 End),  --是否髋部处压疮发生        
       tunbuycrs= max(Case When B.bw in ('35','41') Then 1 Else 0 End),  --是否臀部处压疮发生
       qbwycrs=max(Case When B.bw not in ('00','42','43','44','45','06','07','03','04','21','22','28','29','39','40','11','12','36','05','08','14','15','35','41')
                          Then 1 Else 0 End),  --是否其他处压疮发生
       dcycfsrs=MAX(CASE WHEN ISNULL(c.cs,0)>1 THEN 1 ELSE 0 END ) --是否多处压疮
  INTO #YC
  from MPEHR.dbo.THL_YCSB_M A With(nolock)  --压疮上报表
       Left join MPEHR.dbo.THL_YCSB_D B on A.Mid=B.Mid  --压疮部位分期明细表
       LEFT JOIN (SELECT mid,COUNT(DISTINCT bw) cs FROM MPEHR.dbo.THL_YCSB_D  GROUP BY mid) c ON a.Mid=c.mid
      left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
 where  S.shzt=1 AND CONVERT(VARCHAR(10),a.sbsj,120) BETWEEN @startdate AND @EndDate
 GROUP BY a.mid,a.brbh,a.bgks,a.sbsj,a.ycly


--将指定时间的值添加到事实表Select * from [压疮明细表]  Select * from #YC  truncate table [压疮明细表]
DELETE FROM  [压疮明细表] WHERE CONVERT(VARCHAR(10),bidate,120) BETWEEN @startdate AND @EndDate
Insert Into [压疮明细表](biyear,biquarter,bimonth,biweek,bidate,iDeptId,brbh,mid,ycly,
                                     kysbzzss,yyjyc,yejyc,ysjyc,ysijyc,fsbnfqyc,jtrzsyycdhz,zylyrzsyycdhz,zqtyyzrsyycdhz,zqtlyrzsyycdhz,
                                     dwzgycrs,zgcycrs,ggclycrs,gengycrs,zlcycrs,jjgycrs,zgycrs,jizhuycrs,kuanbuycrs,tunbuycrs,qbwycrs,dcycfsrs)
 Select YEAR(A.RQ),DATEPART(qq,A.RQ),DATEPART(mm,A.RQ),DATEPART(ww,A.RQ),A.RQ,a.iDeptId,a.brbh,a.mid,a.ycly,
        a.kysbzzss,a.yyjyc,a.yejyc,a.ysjyc,a.ysijyc,a.fsbnfqyc,a.jtrzsyycdhz,a.zylyrzsyycdhz,a.zqtyyzrsyycdhz,a.zqtlyrzsyycdhz,
        dwzgycrs,zgcycrs,ggclycrs,gengycrs,zlcycrs,jjgycrs,zgycrs,jizhuycrs,kuanbuycrs,tunbuycrs,qbwycrs,dcycfsrs
 from #YC a
 
 DROP TABLE #YC
 
 
--压疮一览表
SELECT  c.hzxm,c.zyh,a.mid,ltrim(hznl)+nldw nl,CASE WHEN hzxb=1 THEN '男' 
                                                    WHEN hzxb=2 THEN '女' ELSE NULL END hzxb,
        c.cysj cyrq,a.Braden_fz wxdpf,a.ycly,NULL zd,a.qzwx,e.wbname zgqk,a.bgks iDeptid,a.sbsj ,a.hlcs,a.sbsj sbrq,CAST(null AS varchar(200)) fsbwfq
INTO #ycbgmx 
FROM   MPEHR.dbo.THL_YCSB_M A With(nolock)  --压疮上报表
       LEFT JOIN hbidata..infoRYDJB c ON a.brbh=c.gid 
       --LEFT JOIN mpehr..TWordBook d ON  a.ycly=d.WBCode AND d.wbtypecode='11050' 
       LEFT JOIN mpehr..TWordBook e ON  a.zgqk=e.WBCode AND e.wbtypecode='11052' 
       left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
where  S.shzt=1 AND CONVERT(VARCHAR(10),a.sbsj,120) BETWEEN @startdate AND @EndDate

SELECT a.mid, g.wbname+','+f.wbname bwfq
INTO #bwfq
FROM  MPEHR.dbo.THL_YCSB_M A With(nolock) 
LEFT JOIN MPEHR.dbo.THL_YCSB_D B on A.Mid=B.Mid  --压疮部位分期明细表
LEFT JOIN mpehr..TWordBook f ON  b.fq=f.WBCode AND f.wbtypecode='11053' 
LEFT JOIN mpehr..TWordBook g ON  b.bw=g.WBCode AND g.wbtypecode='11054'
left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
where  S.shzt=1 AND CONVERT(VARCHAR(10),a.sbsj,120) BETWEEN @startdate AND @EndDate


--将压疮部位和分期合并
update #ycbgmx 
set fsbwfq=Stuff((Select ';'+b.bwfq From #ycbgmx a                    
									 INNER Join #bwfq b On A.Mid=B.Mid 
                  where a.mid=#ycbgmx.mid           
		   For Xml Path('')),1,1,'')
		    
--将压疮潜在风险合并

--SELECT * FROM [压疮报告一览表]
 TRUNCATE TABLE  [压疮报告一览表]
 Insert Into [压疮报告一览表](biyear,biquarter,bimonth,biweek,bidate,xm,zyh,ID,nl,xb,cyrq,wxdpf,ycly,zd,qzwx,
                               zgqk,iDeptid,fsbwfq,ycfssj,sbrq,hlcs)
 SELECT YEAR(A.sbsj),DATEPART(qq,A.sbsj),DATEPART(mm,A.sbsj),DATEPART(ww,A.sbsj),A.sbsj,a.hzxm,a.zyh,a.mid,a.nl,a.hzxb,a.cyrq,
        a.wxdpf,a.ycly,a.zd,a.qzwx,a.zgqk,a.iDeptid,a.fsbwfq,a.sbsj ycfssj,a.sbrq,a.hlcs
 FROM #ycbgmx a
 
----------------------------------压疮预报一览表
select '1' as isCR,a.brbh,h.hzxm,h.zyh,h.XB,h.NL,h.NL_DW,h.ryDate,a.sbks,a.zdxxmc,a.Braden_FZ,a.ybyy,a.hlcs,a.hsqm,a.hszqmrq,
 IsFs=(Case When A.isfsyc=1 Then '发生' Else '未发生' End),a.GID  
 into #YCYBYLB 
 from MPEHR.dbo.THL_YCYB A
 --left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
 left join MPEHR.dbo.THzxxb H on a.brbh=H.brbh
 Where --S.shzt=1 AND 
      CONVERT(VARCHAR(10),a.hszqmrq,120) BETWEEN @startdate AND @EndDate
 union
 select '0' as isCR,a.brbh,h.hzxm,h.zyh,h.XB,h.NL,h.NL_DW,h.ryDate,a.sbks,a.zdxxmc,a.Braden_FZ,a.ybyy,a.hlcs,a.hsqm,a.hszqmrq,
 IsFs=(Case When A.isfsyc=1 Then '发生' Else '未发生' End),a.GID   
 from MPEHR.dbo.THL_YCYB_ET A
 --left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
 left join MPEHR.dbo.THzxxb H on a.brbh=H.brbh
 Where --S.shzt=1 AND 
       CONVERT(VARCHAR(10),a.hszqmrq,120) BETWEEN @startdate AND @EndDate


delete [压疮预报一览表] where CONVERT(VARCHAR(10),bidate,120) BETWEEN @startdate AND @EndDate
 Insert Into [压疮预报一览表](biyear,biquarter,bimonth,biweek,bidate,ksbh,hzxm,xb,nl,wxdpf,ryrq,sbsj,zyh,IsFs,GID,isCR,hsqm,ybyy,hlcs)
 Select YEAR(hszqmrq) biyear,DATEPART(qq,hszqmrq) biquarter,DATEPART(mm,hszqmrq) bimonth,DATEPART(ww,hszqmrq) biweek,
 hszqmrq bidate,sbks as ksbh,hzxm, XB,(Nl+NL_DW) nl,Braden_FZ wxdpf,ryDate ryrq,hszqmrq sbsj,zyh,IsFs,GID,isCR,hsqm,ybyy,hlcs   
   from #YCYBYLB    


--压疮评分 select top 1000 * from mpehr..THL_YCPF
select b.zyh,b.hzxm,b.XB,LTRIM(b.nl)+b.NL_DW nldw,a.pgsj,a.Braden_FZ,a.pgks,a.pgr,a.pfqk into #ycpf  from mpehr..THL_YCPF a inner join mpehr..THzxxb b on a.brbh=b.brbh 
where CONVERT(VARCHAR(10),a.pgsj,120) BETWEEN @startdate AND @EndDate 
union 
select b.zyh,b.hzxm,b.XB,LTRIM(b.nl)+b.NL_DW nldw,a.pgsj,a.Braden_FZ,a.pgks,a.pgr,a.PFQK from mpehr..THL_YCPF_ET a inner join mpehr..THzxxb b on a.brbh=b.brbh 
where CONVERT(VARCHAR(10),a.pgsj,120) BETWEEN @startdate AND @EndDate 


delete from T_ycpf where CONVERT(VARCHAR(10),bidate,120) BETWEEN @startdate AND @EndDate 

insert into T_ycpf
           ([biyear]
           ,[biquarter]
           ,[bimonth]
           ,[biweek]
           ,[bidate]
           ,[zyh]
           ,[hzxm]
           ,[xb]
           ,[nldw]
           ,[pgfz]
           ,[pgks]
           ,[pgr]
           ,[pfqk])  
 Select YEAR(pgsj) biyear,DATEPART(qq,pgsj) biquarter,DATEPART(mm,pgsj) bimonth,DATEPART(ww,pgsj) biweek,pgsj bidate,
        zyh,hzxm,xb,nldw,Braden_FZ,pgks,pgr,pfqk from #ycpf
  
    /*
----------------------------------------------压疮与压疮危险度分级构成比---------------------------------------
--根据需要的指标得到值（危险度）
Select C.dOutDate,bgks iDeptId,
       Braden_DM=(Case When braden_fz<=9 Then 1 
                       When braden_fz Between 10 And 12 Then 2 
                       When braden_fz between 13 and 14 Then 3
                       When braden_fz between 15 and 17 Then 4
                       When braden_fz >17 Then 5 End),
       LY_DM=(Case When ycly='4' Then 1 Else 2 End),   --1.院内，2.院外
       YCLS=Count(A.Mid)
  into #YCWX
  from MPEHR.dbo.THL_Ycsb_M A 
       Inner jOin #CYBR C On A.brbh=C.GID
      left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
 Where S.shzt=1
 Group by bgks,C.dOutDate,(Case When ycly='4' Then 1 Else 2 End),
         (Case When braden_fz<=9 Then 1 When braden_fz Between 10 And 12 Then 2 When braden_fz between 13 and 14 Then 3
               When braden_fz between 15 and 17 Then 4 When braden_fz >17 Then 5 End)

--将指定时间段的值添加到事实表 
Delete [压疮与压疮危险度分级的关系] Where dOutDate>=@serverDay And dOutDate<=@EndDate
Insert into [压疮与压疮危险度分级的关系](biyear,biquarter,bimonth,biweek,bidate,Braden_DM,dOutDate,iDeptId,LY_DM,YCLS)
Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,
       Braden_DM,dOutDate,iDeptId,LY_DM,YCLS
 From #YCWX

--根据需要的指标得到值（时间段） Select hszqmrq,* From MPEHR.dbo.THL_Ycsb_M
Select A.hszqmrq dNurseDate,C.dOutDate,bgks iDeptId,
       SD_DM= (Case When DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq)) Between 7 and 11 Then 1 
                    When DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq)) Between 12 And 14 Then 2 
                    When DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq)) Between 15 And 20 Then 3 
                    When (DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq))>= 21 And DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq))<=23) or 
                         (DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq))>= 0 And DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq))<=1)  Then 4 
                    When DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq)) Between 2 And 6 then 5 end),
       LY_DM=(Case When ycly='4' Then 1 Else 2 End),   --1.院内，2.院外
       YCLS=Count(Distinct A.Mid)
 into #BTSD
  from MPEHR.dbo.THL_Ycsb_M A 
       Inner jOin #CYBR C On A.brbh=C.GID
      left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
 Where S.shzt=1
 Group by bgks,A.hszqmrq,C.dOutDate,(Case When ycly='4' Then 1 Else 2 End),
          (Case When DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq)) Between 7 and 11 Then 1 
                    When DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq)) Between 12 And 14 Then 2 
                    When DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq)) Between 15 And 20 Then 3 
                    When (DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq))>= 21 And DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq))<=23) or 
                         (DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq))>= 0 And DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq))<=1)  Then 4 
                    When DATEPART(hh,isnull(A.ynycfssj,A.hszqmrq)) Between 2 And 6 then 5 end)
--将指定时间段的值添加到事实表
Delete [不同时段发生压疮的构成比] Where dOutDate>=@serverDay And dOutDate<=@EndDate
Insert Into [不同时段发生压疮的构成比](biyear,biquarter,bimonth,biweek,bidate,dNurseDate,SD_DM,LY_DM,YCLS,dOutDate,iDeptId)
Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,
       dNurseDate,SD_DM,LY_DM,YCLS,dOutDate,iDeptId
 From #BTSD


--查询出需要的字段
Select C.dOutDate,bgks iDeptId,
       qy=Count(distinct Case When A.zgqk='1' Then A.Mid Else null End),        --痊愈
       hz=Count(distinct Case When A.zgqk='2' Then A.Mid Else null End),        --好转  
       wy=Count(distinct Case When A.zgqk='3' Then A.Mid Else null End),        --未愈       
       ycls=Count(Distinct A.Mid),                     -- 压疮例数
       ycly=(Case When ycly='4' Then 1 Else 2 End),   --1.院内，2.院外
       hznl=(Case When C.NL between 0 and 40 then 1
                  When C.NL between 41 and 50 then 2             
                  When C.NL Between 51 and 60 then 3
                  When C.NL Between 61 and 70 then 4
                  When C.NL between 71 and 80 then 5
                  When C.NL >=80 then 6 else 7 End)
 Into #QYYC
 from MPEHR.dbo.THL_Ycsb_M A 
       Inner jOin #CYBR C On A.brbh=C.GID
      left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
 Where S.shzt=1
 Group by C.dOutDate,bgks,(Case When ycly='4' Then 1 Else 2 End),
          (Case When C.NL between 0 and 40 then 1
                When C.NL between 41 and 50 then 2             
                When C.NL Between 51 and 60 then 3
                When C.NL Between 61 and 70 then 4
                When C.NL between 71 and 80 then 5
                When C.NL >=80 then 6 else 7 End)
--将指定时间段的数据添加到事实表
 delete [全院压疮愈合比例] Where dOutDate>=@serverDay And dOutDate<=@EndDate
 Insert Into [全院压疮愈合比例](biyear,biquarter,bimonth,biweek,bidate,iDeptId,dOutDate,ycly,qy,hz,wy,ycls,hznl)
Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,
        iDeptId,dOutDate,ycly,qy,hz,wy,ycls,hznl
 from #QYYC
 group by iDeptId,dOutDate,ycly,qy,hz,wy,ycls,hznl

----------------压疮报告一览表------------------
 --取得需要显示的字段 drop table  #YCYLB   Select * from MPEHR.dbo.THL_Ycsb_M
 Select A.Mid ipSoreReportID,C.Gid,C.hzxm,C.zyh,C.dOutDate,bgks iDeptId,C.NL,G.WbName ycly,
        A.hszqmrq sbrq,C.dInDate,
        iSex=(Case When C.iSex='1' Then '男' Else '女' End),
        ybrq=F.hszqmrq,
        ybfz=A.Braden_Fz,
        fsbwfq=CONVERT(varchar(3000),''),
        zgqk=(Case When A.zgqk='1' Then '痊愈'
                   When A.zgqk='2' Then '好转' 
                   When A.zgqk='3' Then '未愈' End),
        A.qzwx,
        D.ryzdmc as zd,
        0 YCBWCS,
        ynOryw=(Case When ycly='4' Then 1 Else 2 End),
        ynycfssj ycfssj,
        E.yy wyyy
   Into #YCYLB
   from MPEHR.dbo.THL_Ycsb_M A 
        Inner jOin #CYBR C on A.brbh=C.GID
        left join MPEHR.dbo.Thzxxb D on A.brbh=D.brbh 
        left join MPEHR.dbo.THL_YC_ZZ_M E on A.Mid=E.Mid
        left join (Select top 1 brbh,hszqmrq from MPEHR.dbo.THL_YCYB order by ybid desc) F on A.brbh=F.brbh
        left join MPEHR.dbo.TWordBook G on A.ycly=G.WbCode and WBTypecode='11050'
      left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
 Where S.shzt=1
 --使用游标将发生部位整个 Select * from sxdt_dtmkzyy_lc.tmkyymz.dbo.NSWorkPressSoreFocast where cPatientName='王生录'
 --定义游标  Select * from #zb drop table #zb,#YCYLB,#YBBFZ
  declare GetYcFsbw cursor for Select ipSoreReportID From #YCYLB 
  OPEN GetYcFsbw
  declare @ipSoreReportID varchar(20)
  FETCH NEXT FROM GetYcFsbw INTO @ipSoreReportID 
  Select Mid ipSoreReportID,BWFQ=WBName+(Case When fq='0' Then '(可疑深部组织损伤)、'
                               When fq='1' Then '(一期压疮)、'
                               When fq='2' Then '(二期压疮)、'
                               When fq='3' Then '(三期压疮)、'
                               When fq='4' Then '(四期压疮)、'
                               When fq='5' Then '(不能分期压疮)、' Else '' End)
    Into #ZB 
    from MPEHR.dbo.THL_Ycsb_D A
         left join MPEHR.dbo.TWordBook B on A.bw=B.WBCode and WBTypecode='11054'   
  declare @YCBWFQ varchar(3000),@YCBW varchar(100),@YCFQ varchar(500),@YCBWCS int
  While @@FETCH_STATUS = 0
  Begin    
    declare GetYcbw cursor for 
    Select ipSoreReportID,BWFQ From #ZB Where ipSoreReportID=@ipSoreReportID
    Set @YCBWFQ=''
    Set @YCBWCS=0
    OPEN GetYcbw    
     FETCH NEXT FROM GetYcbw INTO @YCBW,@YCFQ
    While @@FETCH_STATUS = 0
    Begin      
      set @YCBWFQ=@YCBWFQ+@YCFQ
      set @YCBWCS=@YCBWCS+1 
      FETCH NEXT FROM GetYcbw INTO @YCBW,@YCFQ
    End
    CLOSE GetYcbw
    DEALLOCATE GetYcbw   
    Update #YCYLB Set fsbwfq=isnull(@YCBWFQ,''),YCBWCS=@YCBWCS  Where ipSoreReportID=@ipSoreReportID
    FETCH NEXT FROM GetYcFsbw INTO @ipSoreReportID
  End  
  CLOSE GetYcFsbw 
  DEALLOCATE GetYcFsbw
  ---将数据添加到事实表 Select * from #YCYLB [压疮报告一览表] order by xm    drop table #ZB  GetStrBySplit
  delete [压疮报告一览表] where bidate>=@serverDay And bidate<=@EndDate
  Insert Into [压疮报告一览表](biyear,biquarter,bimonth,biweek,bidate,xm,zyh,ID,nl,xb,cyrq,wxdpf,ycly,zd,qzwx,
                               zgqk,iDeptid,ynOryw,fsbwfq,ybrq,sbrq,YCBWCS,ycfssj,wyyy)
  Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,hzxm,
         zyh,ipSoreReportID,NL,iSex,dOutDate,ybfz,ycly,zd,qzex=MPEHR.dbo.GetStrBySplit(qzwx,'|','11051'),zgqk,iDeptId,ynOryw,fsbwfq,ybrq,sbrq,YCBWCS,ycfssj,wyyy
    From #YCYLB  
  --添加压疮病人历史数据查询数据Select * from [压疮报告一览表]
  delete YCBRLSSHCX  where idiagnoseid in (select idiagnoseid From #YCYLB)
  Insert Into YCBRLSSHCX (biyear,biquarter,bimonth,biweek,bidate,xm,zyh,idiagnoseid,nl,xb,cyrq,wxdpf,ycls,zd,qzwx,
                         zgqk,iDeptid,ynOryw,fsbwfq,ybrq,sbrq,YCBWCS)
  Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,hzxm,
         zyh,GID,NL,iSex,dOutDate,ybfz,ycly,zd,qzwx,zgqk,iDeptId,ynOryw,fsbwfq,ybrq,sbrq,YCBWCS
    From #YCYLB  
 --------------------------------压疮预报一览表
 --得到需要的字段 Select * from MPEHR.dbo.THL_YCYB
 Select C.dOutDate,sbks iDeptId,C.dInDate,(Case When C.iSex='1' Then '男' Else '女' End) iSex,C.Gid iDiagnoseID,
        C.hzxm cPatientName,C.Nl,C.zyh cCaseCode,A.Braden_FZ iAssessResult,A.hszqmrq dNsDeptLeaderNamedate,
        IsFs=(Case When A.isfsyc=1 Then '发生' Else '未发生' End)
   Into #YCYBYLB
   from MPEHR.dbo.THL_YCYB A 
        inner join #CYBR C on A.brbh=C.GID
      left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
 Where S.shzt=1
 --删除时间范围的数据  Select * from [压疮预报一览表]
 
 delete [压疮预报一览表] where bidate>=@serverDay and bidate<=@EndDate
 Insert Into [压疮预报一览表](biyear,biquarter,bimonth,biweek,bidate,id,ksbh,hzxm,xb,nl,wxdpf,cyrq,ryrq,sbsj,zyh,IsFs,GID)
 Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,iDiagnoseID,
        iDeptId,cPatientName,iSex,Nl,iAssessResult,dOutDate,dInDate,dNsDeptLeaderNamedate,cCaseCode,IsFs,newID()
   from #YCYBYLB
 --------------------------------------压疮部位分析(本院)
 --去的部位的数据 drop table #BODY
 Select WBName Into #BODY from MPEHR.dbo.TWordBook where WBTypecode='11054' 
 --删除原来的数据 Select Sum(ycls) from #BYYC_BW where doutdate between '2013-04-01' and '2013-06-30' 
 truncate table [压疮_部位]
 Insert into [压疮_部位](dm,mc)
   Select WBName as dm ,WBName as mc from #BODY order by WBName
 --取得数据 Select * from MPEHR.dbo.THL_Ycsb_M
 Select bgks ideptid,C.doutdate,D.WBName iSoreBodySite,
        ynOryw=(Case When ycly='4' Then 1 Else 2 End),
        ycls=Count(A.Mid)
   Into #BYYC_BW 
   From MPEHR.dbo.THL_Ycsb_M A With(nolock)
        Left join MPEHR.dbo.THL_Ycsb_D B on A.Mid=B.Mid
        left join MPEHR.dbo.TWordBook D on B.bw=D.WBCode and WBTypecode='11054'
        Inner jOin #CYBR C On A.brbh=C.GID
  where isnull(hszqmrq,'')<>'' and isnull(D.WBName,'')<>''
  group by bgks,C.doutdate,D.WBName,(Case When ycly='4' Then 1 Else 2 End)
 --删除原来数据，添加查询的数据 Select * from #BYYC_BW
 delete [本院部位分析] where cyrq>=@serverDay and cyrq<=@EndDate
 Insert into [本院部位分析](biyear,biquarter,bimonth,biweek,bidate,ksbh,cyrq,YC_BW,LY_DM,ycls)
 Select YEAR(doutdate),DATEPART(qq,doutdate),DATEPART(mm,doutdate),DATEPART(ww,doutdate),doutdate,
        ideptid,doutdate,iSoreBodySite,ynOryw,ycls
   From #BYYC_BW
 --------------------------------------压疮部位分析(卫生部标准)
 --添加数据  Select Sum(qtbwls) from [压疮部位分析]
 delete [压疮部位分析] where cyrq>=@serverDay and cyrq<=@EndDate
 insert into [压疮部位分析](biyear,biquarter,bimonth,biweek,bidate,cyrq,ksbh,dwzgls,zgls,ggclls,gengls,zhuails,jjgls,zhengls,qtbwls,jizhuycrs,kuanbuycrs,tunbuycrs,LY_DM)
 Select * from (
  Select YEAR(RQ) a,DATEPART(qq,RQ) b,DATEPART(mm,RQ) c,DATEPART(ww,RQ) d ,RQ e,RQ f,iDeptId g,
         dwzgycrs h,zgcycrs i,ggclycrs j,gengycrs k,zlcycrs l,jjgycrs m,zgycrs n,qbwycrs o,
         jizhuycrs p,kuanbuycrs q,tunbuycrs r,2 s from #YC
   union
  Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,dOutDate,iDeptId,
         dwzgycrs,zgcycrs,ggclycrs,gengycrs,zlcycrs,jjgycrs,zgycrs,qbwycrs,jizhuycrs,kuanbuycrs,tunbuycrs,1 from #YC_BW) A 
   where  g is not null 

 ----------------------------------------压疮严重程度
 --添加数据
 delete [压疮发生严重程度] where cyrq>=@serverDay and cyrq<=@EndDate
 Insert Into [压疮发生严重程度](biyear,biquarter,bimonth,biweek,bidate,cyrq,ksbh,LY_DM,kysbzzss,YJYC,EJYC,SJYC,SIJYC,BKFQYC)
  Select * from (
    Select YEAR(RQ) a,DATEPART(qq,RQ) b,DATEPART(mm,RQ) c,DATEPART(ww,RQ) d ,RQ e,RQ f,iDeptId g,
           2 h,kysbzzss i,yyjyc j,yejyc k,ysjyc l,ysijyc m,fsbnfqyc n from #YC
     union
    Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,dOutDate,iDeptId,
           1,kysbzzychdcyc,yjycychdchz,ejycychdcyc,sjycychdchz,sijycychdchz,bnfqycychdchz from #YC_BW) A 
   where g is not null
      
 ------------------------------------------------一次或多次压疮
 --添加数据
 delete [一次或多次压疮比] where cyrq>=@serverDay and cyrq<=@EndDate
 Insert Into [一次或多次压疮比](biyear,biquarter,bimonth,biweek,bidate,ID,cyrq,YCYC,DCYC,LY_DM)
 Select YEAR(C.dOutDate),DATEPART(qq,C.dOutDate),DATEPART(mm,C.dOutDate),DATEPART(ww,C.dOutDate),C.dOutDate,
        C.GID,C.dOutDate,
        YCYC=(Case When Count(A.Mid)=1 Then '是' Else '否' End),
        DCYC=(Case When Count(A.Mid)>=2 Then '是' Else '否' End),
        LY_DM=(Case When ycly='4' Then 1 Else 2 End)   --1.院内，2.院外
   From MPEHR.dbo.THL_Ycsb_M A
        Inner Join #CYBR C On A.brbh=C.GID
  where isnull(hszqmrq,'')<>''
 Group By C.GID,C.dOutDate,(Case When ycly='4' Then 1 Else 2 End)
 ---------------------------------------压疮患者数与住院患者数
 --算出数据 
 Select RQ,ideptid,Sum(hzryqyyc) hzryqyyc,Sum(i) yychdcyc 
   Into #AA from (
    Select RQ,iDeptId , hzryqyyc,0 i from #YC
     union
    Select dOutDate,iDeptId,0 , yychdcyc from #YC_BW) A 
  where iDeptId is not null
 Group BY  RQ,ideptid
 --添加数据
 delete [压疮病人数与住院患者数] where cyrq>=@serverDay and cyrq<=@EndDate
 Insert Into [压疮病人数与住院患者数](biyear,biquarter,bimonth,biweek,bidate,cyrq,kscode,RYQ_YCHZ,ZYQJ_YCHZ,cyrs)
 Select YEAR(A.RQ) a,DATEPART(qq,A.RQ) b,DATEPART(mm,A.RQ) c,DATEPART(ww,A.RQ) d,A.RQ,A.RQ,A.ideptid,hzryqyyc,yychdcyc,Cyrs
   From (Select RQ,iDeptID From #CYRS Union Select RQ,iDeptID From #AA) A
        Left Join #CYRS On A.RQ=#CYRS.RQ And A.iDeptID=#CYRS.iDeptID
        Left Join #AA On A.RQ=#AA.RQ And A.iDeptID=#AA.iDeptID
 ------------------------------------------压疮程度
 Delete [全院压疮严重程度] where cyrq>=@serverDay and cyrq<=@EndDate
 Insert Into [全院压疮严重程度](biyear,biquarter,bimonth,biweek,bidate,cyrq,ksbh,kysbzzss,yijiyachuang,erjiyachuang,sanjiyachuang,sijiyachuang,bnfqyc,LY_DM)
 Select YEAR(A.RQ),DATEPART(qq,A.RQ),DATEPART(mm,A.RQ),DATEPART(ww,A.RQ),RQ,RQ,ideptid,
        Sum(kysbzzss),Sum(yyjyc),Sum(yejyc),Sum(ysjyc),Sum(ysijyc),Sum(fsbnfqyc),YC_DM 
   From (
   Select RQ,ideptid,kysbzzss,yyjyc,yejyc,ysjyc,ysijyc,fsbnfqyc, 2 YC_DM from #YC
    union
   Select doutdate,ideptid,kysbzzychdcyc,yjycychdchz,ejycychdcyc,sjycychdchz,sijycychdchz,bnfqycychdchz,1 From #YC_BW
  ) A where ideptid is not null Group by RQ,ideptid,YC_DM
*/

End
/*
Select * from [压疮报告一览表]
Exec P_GetYC '2015-05-17','2015-06-18'

*/


