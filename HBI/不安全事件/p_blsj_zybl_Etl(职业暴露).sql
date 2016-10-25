
/****** Object:  StoredProcedure [dbo].[p_blsj_zybl_Etl]    Script Date: 07/03/2016 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[p_blsj_zybl_Etl]
@startdate Varchar(10),@EndDate Varchar(10)
as
begin
 -- 杏林感染职业暴露表
	begin try      
	  Exec hbidata.dbo.P_xinglin_EXPOSURE        
	end Try              
	begin catch              
	 insert into hbidata.dbo.error_Log(ZxDate,error_step,error_text)               
	 values(getdate(),'杏林感染职业暴露表(P_xinglin_EXPOSURE)',ERROR_MESSAGE())               
	end CATCH 
	
----由于杏林的职业暴露里存的是科室名称，而且和HIS的不完全一样，因此单独建个维表
--select distinct fsks into #fsks from hbidata..EXPOSURE  

--truncate table W_zybl_ks 
--insert into W_zybl_ks(xh,dm,mc) 
--select ROW_NUMBER() OVER(ORDER BY fsks) xh,fsks dm,fsks mc from #fsks 






--职业暴露事实表  select * from T_zybl
delete from   T_zybl where CONVERT(varchar(10),bidate,120) between @startdate and @EndDate


Select DATEPART(YY,a.fssj) biyear,DATEPART(QQ,a.fssj) biquarter,DATEPART(MM,a.fssj)biMonth,DATEPART(WW,a.fssj) biweek,
       CONVERT(varchar(10),a.fssj,120) bidate,a.id,a.name,a.fsks
       into #EXPOSURE
       from hbidata..EXPOSURE a 
where CONVERT(varchar(10),a.fssj,120) between @startdate and @EndDate 

UPDATE a 
SET fsks=b.kscode
from #EXPOSURE  a,mpehr..TUseKs b
WHERE a.fsks=b.ksname


Insert into T_zybl(biyear,biquarter,bimonth,biweek,bidate,id,name,fsks)
select biyear,biquarter,bimonth,biweek,bidate,id,name,fsks from #EXPOSURE





end
/*
	exec p_blsj_zybl_Etl '2016-09-01','2016-10-23'
	select * from hbidata..WB_Dept where deptname like '%妇科%'
	select * from MPEHR_HL..TSF_Zybl   
	select * from T_zybl
	
alter table T_zybl drop column fskscode
*/

--


