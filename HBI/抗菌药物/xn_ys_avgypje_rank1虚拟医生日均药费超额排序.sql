USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[xn_ys_avgypje_rank1]    Script Date: 04/24/2015 18:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER ProceDure [dbo].xn_ys_avgypje_rank1   
 @StartDate varchar(10),
 @EndDate varchar(10),
 @je int
 

as
Begin 
--select  top 1000 * from K_Ypxx where bimonth=5

--排除医生当天发药,病人隔天退药,而医生隔天没有出诊的情况，因此算医生出诊日数时应该排除这样的bidate
select yscode,ysname,bidate into #ysdays0 from K_Ypxx 
where CONVERT(VARCHAR(10),bidate,120) BETWEEN @StartDate AND @EndDate
group by yscode,ysname,bidate
having max(xssl)>0


SELECT  yscode,ysname,CAST(NULL AS VARCHAR(3000)) ks_stuff,COUNT(DISTINCT bidate) fydays  INTO #ysdays  FROM #ysdays0 
GROUP BY  yscode,ysname



SELECT a.yscode INTO  #ys FROM K_Ypxx  a INNER JOIN #ysdays b ON a.yscode=b.yscode 
WHERE CONVERT(VARCHAR(10),a.bidate,120) BETWEEN @StartDate AND @EndDate 
GROUP BY a.yscode
HAVING SUM(a.cfje)/MAX(b.fydays)>@je

--因为有同名同姓的医生，统计发药金额数量时，报表上不能体现出来。因此要用科室区分开来，由于一个医生可能存在对应多个科室，因此合并科室到一个字段里  
select distinct  yscode,ksname   into #ysks from K_Ypxx
where convert(varchar(10),bidate,120)  between @StartDate And @EndDate  

Update #ysdays Set ks_stuff= Stuff((Select ','+cast(aa.ksname As Varchar(4000)) From #ysks aa      --更新ks_stuff
									       Where  aa.yscode=#ysdays.yscode  
									For Xml Path('')
									),1,1,'')  
   From #ysks a 
Where  a.yscode=#ysdays.yscode 



--结果展现
SELECT  a.biyear,a.biquarter,a.bimonth,a.biweek,a.bidate,a.yscode,b.fydays,SUM(a.cfje) cfje,b.ks_stuff,b.ysname,a.blh  FROM K_Ypxx a,#ysdays b
WHERE   a.yscode IN (SELECT yscode FROM #ys) AND a.yscode=b.yscode and CONVERT(VARCHAR(10),bidate,120) BETWEEN @StartDate AND @EndDate 
GROUP BY a.biyear,a.biquarter,a.bimonth,a.biweek,a.bidate,a.yscode,b.fydays,b.ks_stuff,b.ysname,a.blh  


       





end