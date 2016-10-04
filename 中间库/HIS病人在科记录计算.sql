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
			 a.ryksdm zrksdm,--���ڿ���
			 a.rysj zkrq,--���ʱ��
		   --null cksj,--����ʱ��cysj
			 a.cyksdm zcksdm,--��Ժ���Ҵ���
			 a.ryzgysdm zrzgysdm,--����ҽ��
			 a.rycwdm rkcwdm--��λ��
	From infoRYDJB a 
	Where   ISNULL(a.ryksdm,'')<>'' AND cysj is  null
	union 
	select a.bah,a.zyh,a.zycs,a.brid,  
		   a.zrksdm,a.zkrq, --ת��ʱ��
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
    
	if @num>1 --����ת�Ƶ���� 
	begin 
		  while @i<@num 
		  begin 
		  
		  select @zkrq=zkrq from  #aa where zyh=@zyh and zycs=@zycs and xh=@i+1 --��һ��ѭ�������߳���Ժ������Ϣ
		  
		  if exists (select 1  from  #aa where zyh=@zyh and zycs=@zycs and xh=@i+2) --��һ���жϣ����ߵڶ������ұ䶯��Ϣ,����һ��ת����Ϣ
		     select  @rq=zkrq  from  #aa where zyh=@zyh and zycs=@zycs and xh=@i+2  
		  ELSE if exists (SELECT 1 From infoRYDJB WHERE zyh=@zyh and zycs=@zycs AND cysj IS NOT NULL )--���û��������Ϣ�����жϻ����Ƿ��Ժ��ȡ��Ժ���ڣ�����ȡ��ǰ����-1
		     SELECT @rq=cysj From infoRYDJB WHERE zyh=@zyh and zycs=@zycs AND cysj IS NOT NULL
		  ELSE 
		     set @rq=dateadd(dd,-1,GETDATE())        --ÿ���賿ȡ���ݣ����ݸ�����-1��
		     
		    
			  
			  while convert(varchar(10),@zkrq,120)<=convert(varchar(10),@rq,120)
			  begin 
	    
				insert into #infoBrzkjl(brid,zyh,zycs,bah,zkrq,ksdm,zgysdm,cwdm,rkcs)  --zkrq �ڿ�����
				select brid,zyh,zycs,bah,@zkrq zkrq,zrksdm,zrzgysdm,rkcwdm,@i+1 from #aa 
				where zyh=@zyh and zycs=@zycs and xh=@i+1 
				      --and not exists (select 1 from #infoBrzkjl b where #aa.bah=b.bah and #aa.zrksdm=b.ksdm and convert(varchar(10),@zkrq,120)=convert(varchar(10),b.zkrq,120) )
		    
				set @zkrq=DATEADD(DD,1,@zkrq)
			         
			  end
			  
		   set @i=@i+1 
	  
	       end
	 end
     else if @num=1    --������ת�Ƶ������������ǰ����-1�죩������ֵ 
     begin
     
		 select @zkrq=zkrq from  #aa where zyh=@zyh and zycs=@zycs and xh=1 
		 
		 if exists (SELECT 1 From infoRYDJB WHERE zyh=@zyh and zycs=@zycs AND cysj IS NOT NULL )--�жϻ����Ƿ��Ժ��ȡ��Ժ���ڣ�����ȡ��ǰ����-1
		     SELECT @rq=cysj From infoRYDJB WHERE zyh=@zyh and zycs=@zycs AND cysj IS NOT NULL
		  ELSE 
		     set @rq=dateadd(dd,-1,GETDATE())  
	     
		 while convert(varchar(10),@zkrq,120)<=convert(varchar(10),@rq,120)
			begin 
		    
				insert into #infoBrzkjl(brid,zyh,zycs,bah,zkrq,ksdm,zgysdm,cwdm,rkcs)  --zkrq �ڿ�����
				select brid,zyh,zycs,bah,@zkrq zkrq,zrksdm,zrzgysdm,rkcwdm,1 from #aa where zyh=@zyh and zycs=@zycs and xh=1
		    
				set @zkrq=DATEADD(DD,1,@zkrq)
		        
		        
			end
     end

		
FETCH NEXT FROM js_zkxx INTO @zyh ,@zycs
END


close js_zkxx
deallocate js_zkxx 

----ɾ��ʵ�ʳ�Ժ����HIS���Ժʱ��δ���£����¸��ݲ������»��߳�Ժʱ����ڿƱ�����ڻ��߳�Ժ����Ȼ�ڿƵ���Ϣ 
--delete from #infoBrzkjl  
--where exists (select 1 from infoRYDJB b where #infoBrzkjl.bah=b.gid and convert(varchar(10),#infoBrzkjl.zkrq,120)>convert(varchar(10),b.cysj,120)) 
 
--�����ڿ���Ϣ select * from infoBrzkjl_js 

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

   --���³�Ժ���ߵ����һ�ο��ұ䶯��Ϣ�ĳ���ʱ��
update a 
set cksj=b.cysj
from infoBrzkjl_js a,infoRYDJB b 
where a.bah=b.gid and b.cysj is not null and b.cyksdm is not null and a.cksj is null 


/*�����쳣����
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