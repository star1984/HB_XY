USE [hbidata]
GO
/****** Object:  StoredProcedure [dbo].[P_ycpf_ETL]    Script Date: 04/07/2016 14:15:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_ycpf_ETL]
   @StartDate varchar(10), @EndDate varchar(10)
as
begin

Declare @SQLText varchar(8000) 

Select * into #ycpf From infoYCPF Where 1=2  

Set @SQLText=
  'INSERT INTO #ycpf([GID], [brbh],[zyh], [zycs],[pgsj],[Braden_FZ])
  Select * From OpenQuery(DHHIS, ''
  Select d.id gid,cast(b.PAPMI_no as varchar(12))||''''_''''||cast(A.PAADM_InPatNo as varchar(10)) brbh,b.PAPMI_Medicare zyh, A.PAADM_InPatNo zycs,
         cast(convert(varchar(10),d.RecDate,120)||'''' ''''||CONVERT(varchar(100), d.RecTime, 108) as datetime) pgsj,d.item1 Braden_FZ
    From PA_Adm a left  join PA_PATMAS b on a.PAADM_Papmi_dr=b.papmi_rowid1 
                  left  join nur.dhcnurserecparent c on a.paadm_rowid=c.adm 
                  left  join nur.dhcnurserecsub d  on c.id=d.RecParref
    Where a.PAADM_Type=''''I'''' and PAADM_VisitStatus!=''''C''''  and d.RecTyp=''''DHCNURBG_FFYCYYCJLD''''
          and convert(varchar(10),d.RecDate,120)>='''''+@StartDate+''''' and convert(varchar(10),d.RecDate,120)<='''''+@EndDate+'''''
          and  b.PAPMI_Medicare Is Not Null   '')'

exec(@SQLText)

--Braden_FZ的值都是 11分，45分 更新为 11，45
update #ycpf 
set Braden_FZ=cast(LEFT(Braden_FZ,LEN(Braden_FZ)-1) as int)



delete infoYCPF where CONVERT(varchar(10),pgsj,120) between @StartDate and @EndDate 

insert into infoYCPF(gid,brbh,zyh,zycs,pgsj,Braden_FZ)
select gid,brbh,zyh,zycs,pgsj,Braden_FZ from #ycpf



end   

--exec P_ycpf_ETL '2016-01-01','2016-04-06'
--select * from infoYCPF
