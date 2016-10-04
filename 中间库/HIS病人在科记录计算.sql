USE [hbidata]
GO
/****** Object:  StoredProcedure [dbo].[P_infoBrzkjl_js]    Script Date: 08/10/2016 09:14:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_infoBrzkjl_js]
  -- @StartDate varchar(10), @EndDate varchar(10)
WITH ENCRYPTION

As 

begin 


select ROW_NUMBER() over(PARTITION by zyh,zycs order by zyh,zycs,zkrq) xh,* into #aa from 
(  Select    a.gid bah,a.zyh,a.zycs,a.bah brid , 
			 a.ryksdm zrksdm,--所在科室
			 a.rysj zkrq,--入科时间
		   --null cksj,--出科时间cysj
			 a.cyksdm zcksdm,--出院科室代码
			 a.ryzgysdm zrzgysdm,--主管医生
			 a.rycwdm rkcwdm--床位号
	From infoRYDJB a 
	Where   ISNULL(a.ryksdm,'')<>'' AND cysj is  null
	union 
	select a.bah,a.zyh,a.zycs,a.brid,  
		   a.zrksdm,a.zkrq, --转科时间
		   a.zcksdm,
		   a.zrzgysdm,
		   a.zrcwdm rkcwdm from infoBrZhuankJL a inner join infoRYDJB b on b.gid=a.bah 
    Where  ISNULL(b.ryksdm,'')<>''  AND a.valid=1  AND b.cysj is  null 
		   
) a



create table #infoBrzkjl (
   gid                  varchar(50)          null,
   BRID                 varchar(50)          null,
   bah                  varchar(50)          not null,
   zyh                  varchar(50)          null,
   zycs                 int                  null,
   zkrq                 datetime             not null,
   cwdm                 varchar(20)          null,
   cwmc                 varchar(30)          null,
   zgysdm               varchar(30)          null,
   zgysxm               varchar(30)          null,
   ksdm                 varchar(30)          not null,
   ksmc                 varchar(50)          null,
   rkcs                 int                  null,
   constraint PK_INFOBRZKJL primary key (bah, zkrq, ksdm)
)
          
    
declare @brid varchar(50),@zyh varchar(50),@zycs int,@bah varchar(50),@zrksdm varchar(50),@zkrq datetime,
        @zcksdm varchar(50),@zrzgysdm varchar(50),@rkcwdm varchar(50)
        
declare @rq datetime ,@num int,@i int
     
       
DECLARE js_zkxx  CURSOR FOR
select zyh,zycs from #aa  
where xh=1


OPEN js_zkxx

FETCH NEXT FROM js_zkxx INTO @zyh ,@zycs

while @@fetch_status = 0
begin
    select @num=MAX(xh) from #aa where zyh=@zyh and zycs=@zycs
    
    set @i=0  
    
	if @num>1 --存在转科的情况 
	begin 
		  while @i<@num 
		  begin 
		  
		  select @zkrq=zkrq from  #aa where zyh=@zyh and zycs=@zycs and xh=@i+1 --第一次循环：患者初入院科室信息
		  
		  if exists (select 1  from  #aa where zyh=@zyh and zycs=@zycs and xh=@i+2) --第一次判断：患者第二条科室变动信息,即第一条转科信息
		     select  @rq=zkrq  from  #aa where zyh=@zyh and zycs=@zycs and xh=@i+2  
		  ELSE if exists (SELECT 1 From infoRYDJB WHERE zyh=@zyh and zycs=@zycs AND cysj IS NOT NULL )--如果没有下条信息，则判断患者是否出院，取出院日期，否则取当前日期-1
		     SELECT @rq=cysj From infoRYDJB WHERE zyh=@zyh and zycs=@zycs AND cysj IS NOT NULL
		  ELSE 
		     set @rq=dateadd(dd,-1,GETDATE())        --每天凌晨取数据，数据更新至-1天
		     
		    
			  
			  while convert(varchar(10),@zkrq,120)<=convert(varchar(10),@rq,120)
			  begin 
	    
				insert into #infoBrzkjl(brid,zyh,zycs,bah,zkrq,ksdm,zgysdm,cwdm,rkcs)  --zkrq 在科日期
				select brid,zyh,zycs,bah,@zkrq zkrq,zrksdm,zrzgysdm,rkcwdm,@i+1 from #aa 
				where zyh=@zyh and zycs=@zycs and xh=@i+1 
				      --and not exists (select 1 from #infoBrzkjl b where #aa.bah=b.bah and #aa.zrksdm=b.ksdm and convert(varchar(10),@zkrq,120)=convert(varchar(10),b.zkrq,120) )
		    
				set @zkrq=DATEADD(DD,1,@zkrq)
			         
			  end
			  
		   set @i=@i+1 
	  
	       end
	 end
     else if @num=1    --不存在转科的情况，至（当前日期-1天）插入数值 
     begin
     
		 select @zkrq=zkrq from  #aa where zyh=@zyh and zycs=@zycs and xh=1 
		 
		 if exists (SELECT 1 From infoRYDJB WHERE zyh=@zyh and zycs=@zycs AND cysj IS NOT NULL )--判断患者是否出院，取出院日期，否则取当前日期-1
		     SELECT @rq=cysj From infoRYDJB WHERE zyh=@zyh and zycs=@zycs AND cysj IS NOT NULL
		  ELSE 
		     set @rq=dateadd(dd,-1,GETDATE())  
	     
		 while convert(varchar(10),@zkrq,120)<=convert(varchar(10),@rq,120)
			begin 
		    
				insert into #infoBrzkjl(brid,zyh,zycs,bah,zkrq,ksdm,zgysdm,cwdm,rkcs)  --zkrq 在科日期
				select brid,zyh,zycs,bah,@zkrq zkrq,zrksdm,zrzgysdm,rkcwdm,1 from #aa where zyh=@zyh and zycs=@zycs and xh=1
		    
				set @zkrq=DATEADD(DD,1,@zkrq)
		        
		        
			end
     end

		
FETCH NEXT FROM js_zkxx INTO @zyh ,@zycs
END


close js_zkxx
deallocate js_zkxx 

----删除实际出院，但HIS里出院时间未更新，导致根据病案更新患者出院时间后，在科表里存在患者出院后依然在科的信息 
--delete from #infoBrzkjl  
--where exists (select 1 from infoRYDJB b where #infoBrzkjl.bah=b.gid and convert(varchar(10),#infoBrzkjl.zkrq,120)>convert(varchar(10),b.cysj,120)) 
 
--计算在科信息 select * from infoBrzkjl_js 

select a.bah,a.zyh,a.zycs,MIN(a.zkrq) rksj,MIN(b.zkrq)  cksj,a.ksdm,a.zgysdm,a.cwdm,a.rkcs into #temp from #infoBrzkjl a left join #infoBrzkjl b on a.bah=b.bah and a.rkcs+1=b.rkcs 
group by a.bah,a.zyh,a.zycs,a.ksdm,a.zgysdm,a.cwdm ,a.rkcs

INSERT INTO [infoBrzkjl_js]
           ([bah]
           ,[zyh]
           ,[zycs]
           ,[rksj]
           ,[cksj]
           ,[szks]
           ,[zgysdm]
           ,[cwdm]
           ,[rkcs])
select * from #temp 
where not exists (select 1 from infoBrzkjl_js b where #temp.bah=b.bah and #temp.ksdm=b.szks and #temp.rksj=b.rksj)

   --更新出院患者的最后一次科室变动信息的出科时间
update a 
set cksj=b.cysj
from infoBrzkjl_js a,infoRYDJB b 
where a.bah=b.gid and b.cysj is not null and b.cyksdm is not null and a.cksj is null 


/*更新异常数据
bah		           rksj	                 cksj	                 szks	  rkcs
0000005222_4   2015-05-25 10:51:34.000	2015-05-25 11:16:00.000	  174		1
0000005222_4   2015-05-25 11:16:00.000	2015-05-27 15:48:00.000	  174   	2
0000005222_4   2015-05-27 15:48:00.000	2015-06-15 16:21:00.000	  6		    3
0000005222_4   2015-06-15 16:21:00.000	2015-07-06 10:22:00.000	  10	    4
*/
update a 
set   cksj=b.cksj
from  infoBrzkjl_js a,infoBrzkjl_js b 
where a.bah=b.bah and a.szks=b.szks and  a.rkcs+1=b.rkcs 

delete b 
from  infoBrzkjl_js a,infoBrzkjl_js b 
where a.bah=b.bah and a.szks=b.szks and  a.rkcs+1=b.rkcs 

drop table  #infoBrzkjl

End

/*
Exec P_infoBrzkjl_js

select top 10 * from brzkcwxx 
truncate table infoBrzkjl_js


select top 1000 * from hbidata..infoRYDJB WHERE gid='ZY010000761011_1'

select top 1000 * from hbidata..infoBrZhuankJL  WHERE bah='ZY010000761011_1'

select top 1000 * from infoBrzkjl_js where  bah='ZY010000761011_1'

*/