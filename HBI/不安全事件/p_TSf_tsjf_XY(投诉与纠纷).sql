USE [HBI_hmi]
GO
/****** Object:  StoredProcedure [dbo].[p_TSf_blsj_XY]    Script Date: 07/03/2016 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[p_TSf_tsjf_XY]
@startDate varchar(10),
@endDate varchar(10)
AS

begin
--投诉纠纷投诉类别    
truncate table W_xytsjf_lb
Insert into W_xytsjf_lb(xh,dm,mc)
select ROW_NUMBER() over(order by WBCode) xh ,WBCode,WBName from MPEHR..TWordBook 
where WBTypeCode=500

--投诉纠纷被投诉科室类别      
truncate table W_xytsjf_btskslb
Insert into W_xytsjf_btskslb(xh,dm,mc)
select ROW_NUMBER() over(order by WBCode) xh ,WBCode,WBName from MPEHR..TWordBook 
where WBTypeCode=509

--投诉纠纷相关职能科室维表 
truncate table W_xytsjf_xgznks
Insert into W_xytsjf_xgznks(xh,dm,mc)
select ROW_NUMBER() over(order by WBCode) xh ,WBCode,WBName from MPEHR..TWordBook 
where WBTypeCode=516



--综合不良事件事实表  SELECT XGZNKS,xb,nl,tslb,* FROM mpehr..TSF_Ts    SELECT * FROM  MPEHR.dbo.T_shyj where gid='B08D3B99-56FD-4A77-B5DC-6E9D49CB4DB1'
  --flid 1:服务办;2:医务科  服务办与医务科共用一张表单， 报表统计及写指标时注意区分
SELECT DATEPART(YY,a.tssj) biyear,DATEPART(QQ,a.tssj) biquarter,DATEPART(MM,a.tssj) biMonth,DATEPART(WW,a.tssj) biweek,
       a.tssj bidate,a.gid,a.tsrxm,a.zyh,a.hzxm,a.xb,a.nl,a.tslb,a.btskslb,a.btsks,a.btsrxm,a.XGZNKS,b.shr,a.clsj,a.jdsj,a.ZYZNBM_TXSJ,a.flid,
       CAST(NULL AS VARCHAR(200)) XGZNKS_mc
INTO #tsjf_XY
FROM  mpehr..TSF_Ts a LEFT JOIN  MPEHR.dbo.T_shyj b ON a.gid=b.gid
WHERE CONVERT(VARCHAR(10),a.tssj,120) BETWEEN @startDate AND @endDate 


--拆分、按字典替换、合并
DECLARE @gid VARCHAR(50),@xgznks VARCHAR(200),@j int

IF EXISTS (Select 1 FROM sysobjects
           Where name = '#tsjf_XY_xgznks' AND type = 'U')
drop  table  #tsjf_XY_xgznks 

create table #tsjf_XY_xgznks(gid VARCHAR(50),xgznks VARCHAR(200))

declare get_tsjf_XY cursor for 
select  gid,XGZNKS from #tsjf_XY

open get_tsjf_XY 

fetch next from get_tsjf_XY into @gid,@xgznks 


--拆分
while @@fetch_status = 0
begin 

  set @j=1
  while @j<=dbo.Get_StrArrayLength(@xgznks,',')
  begin
  insert into #tsjf_XY_xgznks(gid,xgznks)
  select @gid,dbo.Get_StrArrayStrOfIndex(@xgznks,',',@j)
  set @j=@j+1
  END 

fetch next from get_tsjf_XY into @gid,@xgznks 

END

close get_tsjf_XY
deallocate get_tsjf_XY  

--替换 
UPDATE a 
SET  xgznks=b.WBName
FROM #tsjf_XY_xgznks a,mpehr..TWordBook b 
WHERE a.xgznks=b.WBCode AND b.WBTypeCode=516 

--合并
  update #tsjf_XY
  set xgznks_mc=Stuff((Select ','+b.xgznks From #tsjf_XY a                    
										        Join  #tsjf_XY_xgznks b On a.gid=b.gid
					where #tsjf_XY.gid=a.gid                
		            For Xml Path('')),1,1,'') 
  
  
Delete from T_tsjf_XY where CONVERT(varchar(10),bidate,120) between @startDate and @endDate 

INSERT INTO [HBI_HMI].[dbo].[T_tsjf_XY]
           ([biyear],[biquarter],[bimonth],[biweek],[bidate],[gid],tsrxm,zyh,hzxm,xb,nl,tslb,btskslb,btsks,btsrxm,XGZNKS,shr,clsj,jdsj,ZYZNBM_TXSJ,flid
           )
SELECT biyear, biquarter, biMonth, biweek,bidate,
       gid,tsrxm,zyh,hzxm,xb,nl,tslb,btskslb,btsks,btsrxm,XGZNKS_mc,shr,clsj,jdsj,ZYZNBM_TXSJ,flid        
FROM  #tsjf_XY




end
/*
	exec p_TSf_tsjf_XY '2015-01-01','2016-09-22'
	select * from T_tsjf_XY
	select * from MPEHR_HL..TSF_Zybl   
	select * from T_Zysh
	truncate table T_tsjf_XY

*/

--


