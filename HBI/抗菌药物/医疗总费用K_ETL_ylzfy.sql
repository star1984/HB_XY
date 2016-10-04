USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[K_ETL_brjbxx]    Script Date: 04/08/2015 17:01:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter ProceDure [dbo].[K_ETL_ylzfy]      
 @StartDate varchar(10),   
 @EndDate Varchar(10)   
as   
Begin   

delete from T_ks_ylzfy where convert(varchar(10),bidate,120) between @StartDate  and @EndDate
--�������Ҫʹ��ʱ����Ҫ�����Ҹ�Ϊ�շѱ��е� �����˿��ң���ҽ����ҽ�����ڿ��ң���Ŀǰ״̬�� δ�޸�
insert into T_ks_ylzfy(biyear,biquarter,bimonth,biweek,bidate,kstype,kscode,je)
select DATEPART(yy,jfsj) biyear,DATEPART(qq,jfsj) biquarter,DATEPART(mm,jfsj) bimonth,DATEPART(ww,jfsj) biweek,convert(varchar(10),jfsj,120) bidate,
       Case when brksmc Like '%����%' Then '012' Else '011' End kstype,brksdm,sum(je) je  from HBIData..infoMZSF 
where convert(varchar(10),jfsj,120) between @StartDate  and @EndDate
group by  DATEPART(yy,jfsj),DATEPART(qq,jfsj),DATEPART(mm,jfsj),DATEPART(ww,jfsj) ,convert(varchar(10),jfsj,120),Case when brksmc Like '%����%' Then '012' Else '011' End,brksdm
union 
select DATEPART(yy,jfsj) biyear,DATEPART(qq,jfsj) biquarter,DATEPART(mm,jfsj) bimonth,DATEPART(qq,jfsj) biweek,convert(varchar(10),jfsj,120) bidate,
       Case when brksmc Like '%����%' Then '022' Else '021' End kstype,brksdm,sum(je) je  from HBIData..infoZYSF 
where convert(varchar(10),jfsj,120) between @StartDate  and @EndDate 
group by  DATEPART(yy,jfsj),DATEPART(qq,jfsj),DATEPART(mm,jfsj),DATEPART(ww,jfsj) ,convert(varchar(10),jfsj,120),Case when brksmc Like '%����%' Then '022' Else '021'  End,brksdm




end



 
