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
--SELECT  top 10 * FROM mpehr..THL_Gdpg_M --管道评估主表

--select top 10 * from mpehr..thzxxb

--SELECT * FROM mpehr..THL_Xmsz  --内容设置表



--管道风险评估表
SELECT DATEPART(YY,a.bgrq) biyear,DATEPART(QQ,a.bgrq) biquarter,DATEPART(MM,a.bgrq) biMonth,DATEPART(WW,a.bgrq) biweek,
       a.bgrq bidate,a.id,a.brbh,LEFT(a.brbh,14) zyh,b.hzxm,b.xb,LTRIM(b.nl)+b.NL_DW nl, a.ks,a.bgr,ROUND(a.zf,0) zf
INTO #Gdpg_XY
FROM  mpehr..THL_Gdpg_M a INNER JOIN mpehr..thzxxb b ON a.brbh=b.brbh
WHERE CONVERT(VARCHAR(10),a.bgrq,120) BETWEEN @startDate AND @endDate 

  
Delete from T_Gdpg where CONVERT(varchar(10),bidate,120) between @startDate and @endDate 

INSERT INTO [HBI_HMI].[dbo].[T_Gdpg]
           ([biyear],[biquarter],[bimonth],[biweek],[bidate],[id],brbh,zyh,hzxm,xb,nl,ks,bgr,zf
           )
SELECT biyear, biquarter, biMonth, biweek,bidate,id,brbh,zyh,hzxm,xb,nl,ks,bgr,zf FROM  #Gdpg_XY




end
/*
	exec p_gdpg_XY '2016-01-01','2016-10-10'
	select * from T_Gdpg

ZY010000789929_1

*/

--


