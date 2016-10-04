USE [HBI_GR]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


alter ProceDure [dbo].[xn_ys_ypje_rank]   
 @StartDate varchar(10),
 @EndDate varchar(10),
 @je int
 

as
Begin 
--select  top 1000 * from K_Ypxx where yp05<0

select yscode,ysname,cast(null as varchar(4000)) ks_stuff  into #ys from K_Ypxx 
where convert(varchar(10),bidate,120) between @StartDate and @EndDate 
group by yscode,ysname
having sum(cfje) >@je

--��Ϊ��ͬ��ͬ�յ�ҽ����ͳ�Ʒ�ҩ�������ʱ�������ϲ������ֳ��������Ҫ�ÿ������ֿ���������һ��ҽ�����ܴ��ڶ�Ӧ������ң���˺ϲ����ҵ�һ���ֶ���  
select distinct  yscode,ksname   into #ysks from K_Ypxx
where convert(varchar(10),bidate,120)  between @StartDate And @EndDate  

Update #ys Set ks_stuff= Stuff((Select ','+cast(aa.ksname As Varchar(4000)) From #ysks aa      --����ks_stuff
									       Where  aa.yscode=#ys.yscode  
									For Xml Path('')
									),1,1,'')  
   From #ysks a 
Where  a.yscode=#ys.yscode 
       


select biyear,biquarter,bimonth,biweek, bidate,a.yscode ,sum(cfje) yp06 ,b.ks_stuff,b.ysname,a.blh
from K_Ypxx a left join #ys b on a.yscode=b.yscode
where  a.yscode in (select yscode from #ys ) and convert(varchar(10),bidate,120) between @StartDate and @EndDate 
group by biyear,biquarter,bimonth,biweek, bidate,a.yscode,b.ks_stuff,b.ysname,a.blh




end