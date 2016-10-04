USE [hbidata]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[P_diedaopf_ETL]
   @StartDate varchar(10), @EndDate varchar(10)
as
begin

Declare @SQLText varchar(8000) 

Select * into #diedaopf From infoDdzcpf Where 1=2  

Set @SQLText=
  'INSERT INTO #diedaopf([GID], [brbh],[zyh], [zycs],[pgsj],[pg_fz])
  Select * From OpenQuery(DHHIS, ''
  Select d.id gid,cast(b.PAPMI_no as varchar(12))||''''_''''||cast(A.PAADM_InPatNo as varchar(10)) brbh,b.PAPMI_Medicare zyh, A.PAADM_InPatNo zycs,
         cast(convert(varchar(10),d.RecDate,120)||'''' ''''||CONVERT(varchar(100), d.RecTime, 108) as datetime) pgsj,d.item7 pg_fz
    From PA_Adm a left  join PA_PATMAS b on a.PAADM_Papmi_dr=b.papmi_rowid1 
                  left  join nur.dhcnurserecparent c on a.paadm_rowid=c.adm 
                  left  join nur.dhcnurserecsub d  on c.id=d.RecParref
    Where a.PAADM_Type=''''I'''' and PAADM_VisitStatus!=''''C''''  and d.RecTyp=''''DHCNURBG_MORSEDDPGB''''
          and convert(varchar(10),d.RecDate,120)>='''''+@StartDate+''''' and convert(varchar(10),d.RecDate,120)<='''''+@EndDate+'''''
          and  b.PAPMI_Medicare Is Not Null   '')'

exec(@SQLText)

delete infoDdzcpf where CONVERT(varchar(10),pgsj,120) between @StartDate and @EndDate 



insert into infoDdzcpf(gid,brbh,zyh,zycs,pgsj,pg_fz)
select gid,brbh,zyh,zycs,pgsj,pg_fz from #diedaopf



end   

--exec P_diedaopf_ETL '2016-01-01','2016-01-15'
--select * from infoDdzcpf order by pgsj