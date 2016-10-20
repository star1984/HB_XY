USE [hbidata]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[P_xinglin_EXPOSURE]

as
begin

Declare @SQLText varchar(8000) 

Select * into #EXPOSURE From EXPOSURE Where 1=2 

--select * from aa where  rid='INF1543551478467133714'

Set @SQLText=
  'INSERT INTO #EXPOSURE(id,fssj,name,fsks,shr)
  Select *
  From OpenQuery(xlgr, ''Select cid id,  EVENT_TIME fssj,P_NAME name,P_DEPARTMENT fsks,REVIEWER shr  from C_EXPOSURE where nvl(REVIEWER,'''''''')<>'''''''' '')'

exec(@SQLText)



TRUNCATE TABLE EXPOSURE

INSERT INTO EXPOSURE(id,fssj,name,fsks,shr)
SELECT id,fssj,name,fsks,shr  FROM #EXPOSURE





end   

--exec P_xinglin_EXPOSURE
--select * from Gr_GrInfo where brbh='0000779134(1)'

