/*
 功能 计算HIS病人在科记录 
 
*/
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'P_infoBrzkjl_ETL' AND type = 'P')
   DROP PROCEDURE P_infoBrzkjl_ETL
GO

Create PROCEDURE P_infoBrzkjl_ETL
  -- @StartDate varchar(10), @EndDate varchar(10)

As 
-- 
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
	Where cysj is  null and ISNULL(a.ryksdm,'')<>''
	union 
	select a.bah,a.zyh,a.zycs,a.brid,  
		   a.zrksdm,a.zkrq, --转科时间
		   a.zcksdm,
		   a.zrzgysdm,
		   a.zrcwdm rkcwdm from infoBrZhuankJL a inner join infoRYDJB b on b.gid=a.bah 
    Where b.cysj is  null and ISNULL(b.ryksdm,'')<>''
		   
) a

       
delete a from infoBrzkjl a,infoRYDJB b 
where  a.bah=b.gid and b.cysj is null  
    
declare @xh int,@brid varchar(50),@zyh varchar(50),@zycs int,@bah varchar(50),@zrksdm varchar(50),@zkrq datetime,
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
		  
		  if exists (select 1  from  #aa where zyh=@zyh and zycs=@zycs and xh=@i+2) --第一次循环：患者第二条科室变动信息,即第一条转科信息
		     select  @rq=zkrq  from  #aa where zyh=@zyh and zycs=@zycs and xh=@i+2  
		  else 
		     set @rq=dateadd(dd,-1,GETDATE())      --dateadd(dd,-1,GETDATE())  --每天凌晨取数据，数据更新至-1天
		     
		    
			  
			  while convert(varchar(10),@zkrq,120)<=convert(varchar(10),@rq,120)
			  begin 
	    
				insert into infoBrzkjl(brid,zyh,zycs,bah,zkrq,ksdm,zgysdm,cwdm,rkcs)  --zkrq 在科日期
				select brid,zyh,zycs,bah,@zkrq zkrq,zrksdm,zrzgysdm,rkcwdm,@i+1 from #aa 
				where zyh=@zyh and zycs=@zycs and xh=@i+1 
				      --and not exists (select 1 from infoBrzkjl b where #aa.bah=b.bah and #aa.zrksdm=b.ksdm and convert(varchar(10),@zkrq,120)=convert(varchar(10),b.zkrq,120) )
		    
				set @zkrq=DATEADD(DD,1,@zkrq)
			         
			  end
			  
		   set @i=@i+1 
	  
	       end
	 end
     else --不存在转科的情况，至（当前日期-1天）插入数值 
     begin
     
		 select @zkrq=zkrq from  #aa where zyh=@zyh and zycs=@zycs and xh=1 
		 set @rq=dateadd(dd,-1,GETDATE()) 
	     
		 while convert(varchar(10),@zkrq,120)<=convert(varchar(10),@rq,120)
			begin 
		    
				insert into infoBrzkjl(brid,zyh,zycs,bah,zkrq,ksdm,zgysdm,cwdm,rkcs)  --zkrq 在科日期
				select brid,zyh,zycs,bah,@zkrq zkrq,zrksdm,zrzgysdm,rkcwdm,1 from #aa where zyh=@zyh and zycs=@zycs and xh=1
		    
				set @zkrq=DATEADD(DD,1,@zkrq)
		        
		        
			end
     end

		
FETCH NEXT FROM js_zkxx INTO @zyh ,@zycs
END


close js_zkxx
deallocate js_zkxx 

--删除实际出院，但HIS里出院时间未更新，导致根据病案更新患者出院时间后，在科表里存在患者出院后依然在科的信息 
delete from infoBrzkjl  
where exists (select 1 from infoRYDJB b where infoBrzkjl.bah=b.gid and convert(varchar(10),infoBrzkjl.zkrq,120)>convert(varchar(10),b.cysj,120))

  
 
End

/*
Exec P_infoBrzkjl_ETL '2015-01-01', '2015-03-10' 

select top 10 * from brzkcwxx 

select top 10 * from infoRYDJB
*/

