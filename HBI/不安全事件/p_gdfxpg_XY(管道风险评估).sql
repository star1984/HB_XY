USE [HBI_hmi]
GO
/****** Object:  StoredProcedure [dbo].[p_gdpg_XY]    Script Date: 07/03/2016 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[p_gdpg_XY]
@startDate varchar(10),
@endDate varchar(10)
AS

BEGIN
--SELECT * FROM mpehr..THL_Gdpg_M --管道评估主表

--SELECT * FROM mpehr..THL_Xmsz  --内容设置表



--管道风险评估表
SELECT DATEPART(YY,a.bgrq) biyear,DATEPART(QQ,a.bgrq) biquarter,DATEPART(MM,a.bgrq) biMonth,DATEPART(WW,a.bgrq) biweek,
       a.bgrq bidate,a.id,a.brbh,a.ks,ROUND(a.zf,0) zf
INTO #Gdpg_XY
FROM  mpehr..THL_Gdpg_M a 
WHERE CONVERT(VARCHAR(10),a.bgrq,120) BETWEEN @startDate AND @endDate 

  
Delete from T_Gdpg where CONVERT(varchar(10),bidate,120) between @startDate and @endDate 

INSERT INTO [HBI_HMI].[dbo].[T_Gdpg]
           ([biyear],[biquarter],[bimonth],[biweek],[bidate],[id],brbh,ks,zf
           )
SELECT biyear, biquarter, biMonth, biweek,bidate,id,brbh,ks,zf FROM  #Gdpg_XY




end
/*
	exec p_gdpg_XY '2016-01-01','2016-09-26'
	select * from T_Gdpg



*/

--


