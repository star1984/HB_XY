USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[P_GetDiedao]    Script Date: 10/12/2016 09:54:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_GetDiedao]
(@startDate Varchar(10),@EndDate Varchar(10))
AS
BEGIN

--跌倒损伤严重程度维表select * from 跌倒_损伤程度   
TRUNCATE TABLE 跌倒_损伤程度
INSERT INTO 跌倒_损伤程度(序号,代码,名称)
SELECT  RIGHT(wbcode,1) xh,WBCode,LEFT(wbname,CHARINDEX('：',wbname)-1) FROM mpehr.dbo.TWordBook
WHERE wbtypecode=12053  

/*襄阳人民医院 发生地点为 外出 的，不作统计*/
--根据需要的指标取出主表对应的数据  Select * from mpehr.dbo.THL_Ddzcbg       Select ROW_NUMBER() OVER(PARTITION BY brbh ORDER BY fssj) xh,brbh from mpehr.dbo.THL_Ddzcbg 
 Select a.fssj, a.sbks iDeptId,a.brbh,
        a.gid,ddssyzcd,
        hzjkzkdddls=Case When A.ddyy like '%1%'  Then 1 Else 0 End,  --是否跌倒原因_健康状况原因,
        yzlywhmadddls=Case When A.ddyy like '%2%' Then 1 Else 0 End, --是否治疗、药物和（或）麻醉反应原因 ,
        yhjzwxfzdddls=Case When A.ddyy like '%3%' Then 1 Else 0 End, --是否环境中危险因素原因
        hlcsbddd=Case When A.ddyy like '%4%' Then 1 Else 0 End,      --是否护理措施不当跌倒
        yqtysdddls=Case When A.ddyy like '%5%' Then 1 Else 0 End,    --是否其他原因跌倒
        zcfsddls=Case When b.DDCS>=2 Then 1 Else 0 End  --是否再次跌倒例数
   Into #DD
 from mpehr.dbo.THL_ddzcbg A 
      INNER JOIN (Select ROW_NUMBER() OVER(PARTITION BY brbh ORDER BY fssj) ddcs,brbh,fssj from mpehr.dbo.THL_Ddzcbg ) b ON a.brbh=b.brbh AND a.fssj=b.fssj
      left join mpehr.dbo.T_shyj S on a.Gid=S.Gid 
 Where S.shzt=1 AND CONVERT(VARCHAR(10),a.fssj,120) BETWEEN @startDate AND  @EndDate AND  a.fsdd<>'6'

/*
--得到入院时评估例数（预报）的例数
 Select C.doutdate,C.ideptid, Count(distinct A.brbh) YBRS  Into #YBRS
   from mpehr.dbo.THL_ddzcyb A
        left join mpehr.dbo.THL_ddzcbg B on A.brbh=B.brbh 
        Inner join #CYBR C On A.brbh=C.Gid
  where B.PG_FZ>=17
  Group by C.doutdate,C.ideptid
 Insert Into #DD(dOutDate,iDeptId,ryspgls,ddlsyybdls)
   Select dOutDate,iDeptId,0,0 From #YBRS Where Not Exists(Select 1 From #DD Where #YBRS.dOutDate=#DD.dOutDate And #YBRS.iDeptId=#DD.iDeptId)
 Update #DD Set ryspgls=A.YBRS From #YBRS A 
  Where A.dOutDate=#DD.dOutDate And A.iDeptId=#DD.iDeptId
 --得到跌倒例数有预报的例数
 Select C.doutdate,C.ideptid,Count(*) DDLSYBRS Into #DDLSYBRS from mpehr.dbo.THL_ddzcyb A
         left join #CYBR C on  A.brbh=C.Gid
  where brbh in (Select brbh from mpehr.dbo.THL_ddzcbg)
 group by C.doutdate,C.ideptid
 Select A.dOutDate,A.iDeptId,DDLSYBRS Into #DDLSYB from #YBRS A inner join #DDLSYBRS B  on A.dOutDate=B.dOutDate and A.iDeptId=B.iDeptId 
 Update #DD Set ddlsyybdls=A.DDLSYBRS From #DDLSYB A 
  Where A.dOutDate=#DD.dOutDate And A.iDeptId=#DD.iDeptId 
  
*/
 --将取出的数据insert到事实表 truncate table [跌倒坠床分析]
  DELETE FROM  [跌倒坠床分析] WHERE EXISTS (SELECT 1 FROM #dd WHERE [跌倒坠床分析].gid=#dd.gid ) 
 Insert Into [跌倒坠床分析](biyear,biquarter,bimonth,biweek,bidate,ideptid,brbh,gid,hzjkzkdddls,yzlywhmadddls,yhjzwxfzdddls,hlcsbddd,yqtysdddls,
                            ssyzcd,zcfsddls)
 Select YEAR(a.fssj),DATEPART(qq,a.fssj),DATEPART(mm,a.fssj),DATEPART(ww,a.fssj),a.fssj,A.ideptid,a.brbh,a.gid,hzjkzkdddls,yzlywhmadddls,yhjzwxfzdddls,hlcsbddd,yqtysdddls,
        ddssyzcd,zcfsddls      
 From #DD a
 


--SELECT TOP 1000 * FROM T_zyhzmxb  where gid='ZY010000781304_1'   select * from  mpehr.dbo.THL_ddzcbg 
 --将取出的数据insert到事实表 truncate table [跌倒病人一览表]   select top 10 * from  [跌倒病人一览表]   select * from  mpehr.dbo.THL_ddzcbg

 Select YEAR(a.fssj) yy,DATEPART(qq,a.fssj) qq,DATEPART(mm,a.fssj) mm,DATEPART(ww,a.fssj) ww ,a.fssj,a.gid ,b.hzxm cpatientName,
        b.zyh cpatientcode,CASE WHEN b.hzxb=1 THEN '男' 
                                       WHEN b.hzxb=2 THEN '女' ELSE NULL END iSex,a.sbks ideptid,LTRIM(b.nl)+b.nldw nl, 
        b.cysj dOutDate,a.PG_FZ wxyspf,LEFT(c.wbname,CHARINDEX('：',c.wbname)-1) ddsscd,a.ddyy,a.ddhcz,a.ddsqxms ddqxmx,
        d.ddcs,a.fsdd ,a.gbrq bgrq,CASE WHEN b.isddgfx=1 THEN '是' 
                                        WHEN b.isddgfx=0 THEN '否'  ELSE '未入院评估' END gfx,a.hlcs,a.DDORZZ,
       CAST(null as varchar(300)) ddyy_all,CAST(null as varchar(300)) fsdd_all,CAST(null as varchar(300)) ddhcz_all,CAST(null as varchar(20)) banbie
 INTO #ddmx 
 FROM mpehr.dbo.THL_ddzcbg a INNER JOIN T_zyhzmxb b ON a.brbh=b.gid 
                             inner JOIN mpehr..TWordBook c ON a.ddssyzcd=c.WBCode AND c.wbtypecode=12053  
                             INNER JOIN (Select ROW_NUMBER() OVER(PARTITION BY brbh ORDER BY fssj) ddcs,brbh,fssj from mpehr.dbo.THL_Ddzcbg ) d ON a.brbh=d.brbh AND a.fssj=d.fssj 
                             left join mpehr.dbo.T_shyj S on a.Gid=S.Gid
 Where S.shzt=1 AND CONVERT(VARCHAR(10),a.fssj,120) BETWEEN @startDate AND  @EndDate AND    a.fsdd<>'6' 
 
 
/*工作班别规则
白班：08:00-12:00,14:30-17:30
中班：17:30-23:00
夜班：23:00-08:00
中午：12:00-14:30
*/
--更新班别
UPDATE #ddmx 
SET banbie=CASE WHEN (CONVERT(VARCHAR(20),fssj, 114) >= CAST('08:00' AS time) AND CONVERT(VARCHAR(20),fssj, 114)< CAST('12:00' AS time)) OR (CONVERT(VARCHAR(20),fssj, 114) >= CAST('14:30' AS time) AND CONVERT(VARCHAR(20),fssj, 114)<CAST('17:30' AS time)) THEN '01' 
                WHEN  CONVERT(VARCHAR(20),fssj, 114) >= CAST('17:30' AS time) AND CONVERT(VARCHAR(20),fssj, 114)< CAST('23:00' AS time) THEN '02' 
                WHEN  CONVERT(VARCHAR(20),fssj, 114) >= CAST('23:00' AS time) AND CONVERT(VARCHAR(20),fssj, 114)< CAST('08:00' AS time) THEN '03' 
                WHEN  CONVERT(VARCHAR(20),fssj, 114) >= CAST('12:00' AS time) AND CONVERT(VARCHAR(20),fssj, 114)< CAST('14:30' AS time) THEN '04'  ELSE NULL end

--拆分、按字典替换、合并
DECLARE @gid VARCHAR(50),@ddyy VARCHAR(200),@fsdd VARCHAR(200),@ddhcz VARCHAR(200),@j int

IF EXISTS (Select 1 FROM sysobjects
     Where name = '#diedao_ddyy' AND type = 'U')
drop  table  #diedao_ddyy 

create table #diedao_ddyy (gid VARCHAR(50),ddyy VARCHAR(200))

IF EXISTS (Select 1 FROM sysobjects
     Where name = '#diedao_fsdd' AND type = 'U')
drop  table  #diedao_fsdd 

create table #diedao_fsdd(gid VARCHAR(50),fsdd VARCHAR(200))

IF EXISTS (Select 1 FROM sysobjects
     Where name = '#diedao_ddhcz' AND type = 'U')
drop  table  #diedao_ddhcz

create table #diedao_ddhcz(gid VARCHAR(50),ddhcz VARCHAR(200))



declare get_diedao cursor for 
select  gid,ddyy,fsdd,ddhcz from #ddmx


open get_diedao

fetch next from get_diedao into @gid,@ddyy,@fsdd,@ddhcz
while @@fetch_status = 0
begin 
--第一批while循环处理跌倒原因ddyy
  set @j=1
  while @j<=dbo.Get_StrArrayLength(@ddyy,'|')
  begin
  insert into #diedao_ddyy(gid,ddyy)
  select @gid,dbo.Get_StrArrayStrOfIndex(@ddyy,'|',@j)
  set @j=@j+1
  END 
  
--第二批while循环处理跌倒地点fsdd
  set @j=1
  while @j<=dbo.Get_StrArrayLength(@fsdd,'|')
  begin
  insert into #diedao_fsdd(gid,fsdd)
  select @gid,dbo.Get_StrArrayStrOfIndex(@fsdd,'|',@j)
  set @j=@j+1
  END 
  
--第三批while循环处理跌倒后措施ddhcz
  set @j=1
  while @j<=dbo.Get_StrArrayLength(@ddhcz,'|')
  begin
  insert into #diedao_ddhcz(gid,ddhcz)
  select @gid,dbo.Get_StrArrayStrOfIndex(@ddhcz,'|',@j)
  set @j=@j+1
  END 
  
fetch next from get_diedao into  @gid,@ddyy,@fsdd,@ddhcz

end

close get_diedao
deallocate get_diedao  

--按字典分别进行更新
--跌倒原因 
UPDATE a 
SET ddyy=b.WBName
FROM #diedao_ddyy a,mpehr.dbo.TWordBook b 
WHERE b.wbtypecode=12052   AND a.ddyy=b.WBCode

--发生地点
UPDATE a 
SET fsdd=b.WBName
FROM #diedao_fsdd a,mpehr.dbo.TWordBook b 
WHERE b.wbtypecode=12050   AND a.fsdd=b.WBCode 

--跌倒后处置
UPDATE a 
SET ddhcz=b.WBName
FROM #diedao_ddhcz a,mpehr.dbo.TWordBook b 
WHERE b.wbtypecode=12051   AND a.ddhcz=b.WBCode 
  
  --将选择"其他"的手填内容拼接到"其他"项
  UPDATE  a 
  SET   ddhcz=a.ddhcz+':'+b.ddhcz_qt
  FROM  #diedao_ddhcz a,mpehr.dbo.THL_ddzcbg  b 
  WHERE a.gid=b.gid AND a.ddhcz='其他'

--开始合并
  --跌倒原因合并
  update #ddmx
  set ddyy_all=Stuff((Select ','+b.ddyy From #ddmx a                    
										 Join  #diedao_ddyy b On a.gid=b.gid
					where #ddmx.gid=a.gid                
		            For Xml Path('')),1,1,'') 
		            
  --发生地点合并
  update #ddmx
  set fsdd_all=Stuff((Select ','+b.fsdd From #ddmx a                    
										 Join  #diedao_fsdd b On a.gid=b.gid
					where #ddmx.gid=a.gid                
		            For Xml Path('')),1,1,'') 
	            
  --跌倒后处置合并
  update #ddmx
  set ddhcz_all=Stuff((Select ','+b.ddhcz From #ddmx a                    
										 Join  #diedao_ddhcz b On a.gid=b.gid
					where #ddmx.gid=a.gid                
		            For Xml Path('')),1,1,'') 

 DELETE FROM  [跌倒病人一览表] WHERE EXISTS (SELECT 1 FROM #ddmx WHERE [跌倒病人一览表].idiagnoseid=#ddmx.gid )
 
 Insert Into [跌倒病人一览表](biyear,biquarter,bimonth,biweek,bidate,
                idiagnoseid,cpatientName,cpatientcode,iSex,ideptid,nl,dOutDate,wxyspf,ddsscd,ddyy,ddhcz,ddqxmx,
                ddcs,fsdd,bgrq,gfx,hlcs,isddzc,banbie)
 Select yy, qq, mm, ww ,fssj,
        gid,cpatientName,cpatientcode,iSex,ideptid,nl,dOutDate,wxyspf, ddsscd,ddyy_all,ddhcz_all, ddqxmx,
        ddcs,fsdd_all , bgrq, gfx,hlcs,DDORZZ isddzc,banbie
 from #ddmx 

 ---------------------------------------跌倒预报一览表 
 select '1' as isCR,a.brbh,h.hzxm,h.zyh,h.XB,h.NL,h.NL_DW,h.ryDate,a.sbks,a.zdxxmc,a.PGZF,a.hlcs,a.hsqm,a.hszqmrq,a.GID  
 into #ZCYCYLB 
 from MPEHR.dbo.THL_Ddzcyb A
 --left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
 left join MPEHR.dbo.THzxxb H on a.brbh=H.brbh
 Where --S.shzt=1 AND 
       CONVERT(VARCHAR(10),a.hszqmrq,120) BETWEEN @startdate AND @EndDate
 union
 select '0' as isCR,a.brbh,h.hzxm,h.zyh,h.XB,h.NL,h.NL_DW,h.ryDate,a.sbks,a.zdxxmc,a.PGZF,a.hlcs,a.hsqm,a.hszqmrq,a.GID  
 from MPEHR.dbo.THL_Ddzcyb_ET A
 --left join MPEHR.dbo.T_shyj S on a.Gid=S.Gid
 left join MPEHR.dbo.THzxxb H on a.brbh=H.brbh
 Where --S.shzt=1 AND 
       CONVERT(VARCHAR(10),a.hszqmrq,120) BETWEEN @startdate AND @EndDate
 
 delete DDYBYLB where CONVERT(VARCHAR(10),bidate,120) BETWEEN @startdate AND @EndDate
 insert into [DDYBYLB](biyear,biquarter,bimonth,biweek,bidate,hzxm,ksbh,isex,nl,ryrq,wxdpf,ybrq,zyh,hlcs,gid,iscr,hsqm)
 Select YEAR(hszqmrq) biyear,DATEPART(qq,hszqmrq) biquarter,DATEPART(mm,hszqmrq) bimonth,DATEPART(ww,hszqmrq) biweek,
 hszqmrq bidate,hzxm,sbks as ksbh, XB issex,(Nl+NL_DW) nl,ryDate ryrq,PGZF wxdpf,hszqmrq ybrq,zyh,hlcs,GID,isCR,hsqm
   from #ZCYCYLB 
                            
 --------跌倒坠床评分 truncate table 跌倒坠床评分
 --SELECT  TOP 100 * FROM mpehr..THL_Ddzcpf
 --SELECT  TOP 100 * FROM mpehr..THzxxb 
 --SELECT  TOP 100 * from mpehr..THL_Ddzcpf_ET
 
 SELECT LEFT(a.brbh,14) zyh,a.pgsj,a.pgks,a.pgzf,a.pgr,b.hzxm,b.xb,LTRIM(b.nl)+b.nl_dw nl 
 INTO #ddzcpf
 FROM mpehr..THL_Ddzcpf a INNER JOIN mpehr..THzxxb b ON a.brbh=b.brbh 
 WHERE CONVERT(VARCHAR(10),a.pgsj,120) BETWEEN @startdate AND @EndDate
 UNION 
 SELECT LEFT(a.brbh,14) zyh,a.pgsj,a.pgks,a.pgzf,a.pgr,b.hzxm,b.xb,LTRIM(b.nl)+b.nl_dw nl  
 FROM mpehr..THL_Ddzcpf_ET a INNER JOIN mpehr..THzxxb b ON a.brbh=b.brbh 
 WHERE CONVERT(VARCHAR(10),a.pgsj,120) BETWEEN @startdate AND @EndDate 
 
 DELETE 跌倒坠床评分 WHERE CONVERT(VARCHAR(10),bidate,120) BETWEEN @startdate AND @EndDate  
 
 INSERT INTO 跌倒坠床评分(biyear,biquarter,bimonth,biweek,bidate,zyh,hzxm,hzxb,hznl,pgzf,ideptid,pgr)
 Select YEAR(pgsj) biyear,DATEPART(qq,pgsj) biquarter,DATEPART(mm,pgsj) bimonth,DATEPART(ww,pgsj) biweek,
 pgsj bidate,zyh,hzxm,xb,nl,pgzf,pgks,pgr
 FROM #ddzcpf
 
 
                             
                             
 

 

/*
 --------跌倒坠床评分
 --得到预报例数和 评分编号代码   Select *  from mpehr.dbo.THL_ddzcpf
 Select C.dOutDate,pgks ideptid, ybls=Count(distinct Convert(Varchar(20),A.brbh)+'_'+Convert(Varchar(20),A.pgcs)),
        WXD2=Count((CASE WHEN A.PGZF between 8 and 16 THEN Convert(Varchar(20),A.brbh)+'_'+Convert(Varchar(20),A.pgcs) ELSE NULL END)),
        WXD3=Count((CASE WHEN A.PGZF>=17 THEN Convert(Varchar(20),A.brbh)+'_'+Convert(Varchar(20),A.pgcs) ELSE NULL END))
  Into #YB
  from mpehr.dbo.THL_ddzcpf A
       Inner join #CYBR C On A.brbh=C.GID
       right join #CYRS D on C.dOutDate=D.RQ and C.ideptid=D.ideptid
 Group by C.dOutDate, pgks

 --删除指定时间段的数据，并添加指定时间段的数据 truncate table [跌倒坠床评分]
 Delete [跌倒坠床评分] where dOutDate>=@serverDay and dOutDate<=@EndDate
 Insert into [跌倒坠床评分](biyear,biquarter,bimonth,biweek,bidate,dOutDate,IDeptID,WXD2,WXD3,CYRS)
 Select YEAR(a.RQ) Q,DATEPART(qq,a.RQ) W,DATEPART(mm,a.RQ) E,DATEPART(ww,a.RQ) R,a.RQ T,
        a.RQ,B.IDeptID,WXD2,WXD3,CYRS
  from (Select iDeptId,RQ From #CYRS union 
        Select iDeptId,Convert(DateTime,Convert(VarChar(10),dOutDate,120)) From #YB) A  
       left join #CYRS c on c.iDeptId=A.iDeptId and c.rq=a.rq
       left join #YB B on A.RQ=B.dOutDate and A.IDeptID=B.IDeptID
 where b.IDeptID is not null
--取出跌倒病人一览表的数据  Select * from mpehr.dbo.THL_ddzcbg
 Select A.brbh,C.hzxm,A.gbrq,A.fssj,C.zyh,a.sbks ideptid,C.nl,C.dOutDate,
        A.PG_FZ wxyspf,
        iSex=(Case When C.iSex='1' Then '男' When C.iSex='2' Then '女' End), 
        ddsscd=((Case When isnull(A.ddssyzcd,'')='1' Then '损伤程度I级' Else '' End)+
                (Case When isnull(A.ddssyzcd,'')='2' Then '损伤程度II级' Else '' End)+
                (Case When isnull(A.ddssyzcd,'')='3' Then '损伤程度III级' Else '' End)),
        ddyy=((Case When A.ddyy like '%1%' Then '健康状况原因、' Else '' End)+
              (Case When A.ddyy like '%2%' Then '治疗、药物和麻醉反应原因、' Else '' End)+
              (Case When A.ddyy like '%3%' Then '环境因中危险因素原因、' Else '' End)+
              (Case When A.ddyy like '%4%' Then '护理措施不当、' Else '' End)+
              (Case When A.ddyy like '%5%' Then '意外、' else null end)),
        '' hljb,
        ddhcz=((Case When A.ddhcz like '%1%' Then '无、' Else '' End)+
               (Case When A.ddhcz like '%2%' Then '涂药、' Else '' End)+
               (Case When A.ddhcz like '%3%' Then '缝合、' Else '' End)+
               (Case When A.ddhcz like '%4%' Then '影像学检查、' Else '' End)+
               (Case When A.ddhcz like '%5%' Then '打石膏、' Else '' End)+
               (Case When A.ddhcz like '%6%' Then '牵引、' Else '' End)+
               (Case When A.ddhcz like '%7%' Then '手术、' Else '' End)+
               (Case When A.ddhcz like '%8%' Then '其它('+ddhcz_qt+')' Else '' End)),
        ddsqxms ddqxmx,
        iNum=(Case When ddcs>1 Then '是' Else '否' End),
        ssnld=(Case When C.nl<=6 Then 1 
                    When C.nl between 7 and 50 Then 2
                    When C.nl between 51 and 60 Then 3
                    When C.nl between 61 and 70 Then 4
                    When C.nl between 71 and 80 Then 5
                    When C.nl>=81 Then 6 End),
        ddsj=(Case When DATEPART(hh,A.fssj) Between 7 and 11 Then 1 
                   When DATEPART(hh,A.fssj) Between 12 And 14 Then 2 
                   When DATEPART(hh,A.fssj) Between 15 And 20 Then 3 
                   When (DATEPART(hh,A.fssj)>= 21 And DATEPART(hh,A.fssj)<=23) or 
                       (DATEPART(hh,A.fssj)>= 0 And DATEPART(hh,A.fssj)<=1)  Then 4 
                   When DATEPART(hh,A.fssj) Between 2 And 6 then 5 end),    --跌倒时间别
        fsdd dzdd,      --跌倒地点
        '' nkwkorts      --=(Case When A.ideptid in('65','96','68','98','142','141','94','62','51','92','43','11','82','42','89','173','277') Then 1 
                       --When A.ideptid in('26','228','229','52','93','195','25','84','36','88','106','185','269','270','105','45','46',
                        --                 '63','175','55','95') Then 2 
                       --When A.ideptid in('47','53','137','208','100') Then 3 Else 4 End)    --内科系统外科系统或者特殊科室
 Into #YLB
 from mpehr.dbo.THL_ddzcbg a
      JOIN #CYBR C on A.brbh=C.GID
      left join mpehr.dbo.T_shyj  S on a.Gid=S.Gid
 Where S.shzt=1

 --将数据添加到事实表 drop table #YLB truncate table [跌倒病人一览表]   in (Select brbh From #YLB )
 Delete [跌倒病人一览表] where bidate between @serverDay and @EndDate
 Insert Into [跌倒病人一览表](biyear,biquarter,bimonth,biweek,bidate,
                idiagnoseid,cpatientName,bgrq,fssj,cpatientcode,iSex,ideptid,nl,dOutDate,wxyspf,ddsscd,ddyy,hljb,ddhcz,ddqxmx,
                iNum,ssnld,ddsj,dzdd,nkwkorts)
 Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,
        brbh,hzxm,gbrq,fssj,zyh,iSex,ideptid,nl,dOutDate,wxyspf,ddsscd,ddyy,hljb,ddhcz,
        ddqxmx,iNum,ssnld,ddsj,dzdd,nkwkorts
 From #YLB
 Update [跌倒病人一览表] Set ddyy=(Case When Right(ddyy,1)='、' Then Left(ddyy,Len(ddyy)-1) Else ddyy End),
                             ddhcz=(Case When Right(ddhcz,1)='、' Then Left(ddhcz,Len(ddhcz)-1) Else ddhcz End)

 ---------------------------------跌倒评分高风险一览表 truncate table DDPFGFX Select * from mpehr.dbo.THL_Ddzcpf
 Delete DDPFGFX where bidate between @serverDay and @EndDate
 Insert Into DDPFGFX(biyear,biquarter,bimonth,biweek,bidate,kscode,cyrq,ryrq,cpatientName,pffs,nl,isex,zyh)
 Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,
        pgks ideptid,dOutDate=Convert(VarChar(10),dOutDate,120),
        dinDate=Convert(VarChar(10),dinDate,120),
        C.hzxm ,max(PGZF),nl,
        isex=(Case When iSex='1' Then '男' When iSex='2' Then '女' End),zyh
   from mpehr.dbo.THL_Ddzcpf A
        Inner join #CYBR C On A.brbh=C.Gid
  where PGZF>=17 
  group by C.hzxm,pgks,nl,isex,dinDate,dOutDate, zyh 
  order by hzxm

 ---------------------------------------跌倒预报一览表 
 --取得预报表的数据 Select * from mpehr.dbo.THL_Ddzcyb
 Select Convert(Varchar(20),A.brbh)+'_'+Convert(varchar(20),ybid) brbh,C.hzxm,a.sbks ideptid,
        isex=(Case When C.iSex='1' Then '男' When C.iSex='2' Then '女' End),
        C.NL,C.dindate,PGZF,sffsdd='否',pfbsfcz='否',hszqmrq,C.doutDate,c.zyh
   Into #DDYBB
   FROM mpehr.dbo.THL_Ddzcyb A
        JOIN #CYBR C On A.brbh=C.Gid
       left join mpehr.dbo.T_shyj  S on a.Gid=S.Gid
 Where S.shzt=1
 --计算出预报表病人在评分表是否存在数据
 Select C.Gid,max(PGZF) fs Into #PFSJ from mpehr.dbo.THL_Ddzcpf A
        Inner join #CYBR C On A.brbh=C.GID
  where A.PGZF>=17 group By C.Gid
 update #DDYBB set pfbsfcz='是' from #PFSJ where #DDYBB.brbh=#PFSJ.Gid
 --计算出预报表病人是否发生跌倒
 Select a.brbh Into #DDHZ from mpehr.dbo.THL_Ddzcbg A
        join #CYBR C On A.brbh=C.GID
 update #DDYBB set sffsdd='是' from #DDHZ where #DDYBB.brbh=#DDHZ.brbh
 --添加数据 truncate table [DDYBYLB]
 --Select * from DDYBYLB
 delete DDYBYLB where cyrq between @serverDay and @EndDate
 insert into [DDYBYLB](biyear,biquarter,bimonth,biweek,bidate,idiagnoseid,hzxm,ksbh,isex,nl,ryrq,wxdpf,sffsdd,sfzpfbcz,ybrq,cyrq,zyh)
 Select YEAR(dOutDate),DATEPART(qq,dOutDate),DATEPART(mm,dOutDate),DATEPART(ww,dOutDate),dOutDate,
        brbh,hzxm,ideptid,isex,NL,dindate,PGZF,sffsdd,pfbsfcz,hszqmrq,doutDate,zyh
   From #DDYBB
   
   
 */
End




/*

Exec P_GetDiedao '2016-01-01','2016-10-10'

*/
