USE [hbidata]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[P_xinglin_INFECTION]

as
begin

Declare @SQLText varchar(8000) 

Select * into #Gr_GrInfo From Gr_GrInfo Where 1=2 

--select * from aa where  rid='INF1543551478467133714'

Set @SQLText=
  'INSERT INTO #Gr_GrInfo([ID], [GRSJ],[brbh],[zyh], [zycs],[grks],[grbw],[grssbh],[NNIS],[groupid])
  Select *
  From OpenQuery(xlgr, ''Select a.rid id,a.INFECTED_TIME grsj,caseid brbh,substr(a.caseid,5,6) zyh,1 zycs,a.INFECTED_DEPT grks,a.INFECTED_PART grbw,cast(null as varchar(50)) grssbh,cast(null as int) NNIS,a.groupid
                         From  INFECTION a  where ISNOSOCOMIAL=''''院内'''' and STATE=''''确认'''' '')'

exec(@SQLText)

CREATE TABLE #SS(operid VARCHAR(20),brbh VARCHAR(20),nnis INT,infgroupid VARCHAR(50))

SET @SQLText=
     'INSERT INTO #ss([operid],[brbh], [nnis],[INFgroupid])
      Select operid,caseid brbh,nnis,INFgroupid
      From OpenQuery(xlgr, ''Select * From  oper2   '')'
      
exec(@SQLText)

--更新感染手术编号grssbh和NNIS 
UPDATE a 
SET grssbh=b.operid,nnis=b.nnis
FROM #Gr_GrInfo a,#ss b 
WHERE a.brbh=b.brbh AND a.groupid=b.INFgroupid



TRUNCATE TABLE Gr_GrInfo

INSERT INTO [HBIDATA].[dbo].[Gr_GrInfo]
           ([id]
           ,[grsj]
           ,[brbh]
           ,[zyh]
           ,[zycs]
           ,[grks]
           ,[grbw]
           ,[grssbh]
           ,[NNIS]
           ,[groupid])
SELECT ID, GRSJ,brbh,zyh, zycs,grks,grbw,grssbh,NNIS,groupid FROM #Gr_GrInfo





end   

--exec P_xinglin_INFECTION
--select * from Gr_GrInfo where brbh='0000779134(1)'