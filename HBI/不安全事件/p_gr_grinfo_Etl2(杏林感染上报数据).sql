
/****** Object:  StoredProcedure [dbo].[p_blsj_zybl_Etl]    Script Date: 07/03/2016 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[p_gr_grinfo_Etl2]

as
begin
-- 从中间库更新杏林感染上报表
	begin try      
	  Exec hbidata.dbo.P_xinglin_INFECTION         
	end Try              
	begin catch              
	 insert into hbidata.dbo.error_Log(ZxDate,error_step,error_text)               
	 values(getdate(),'杏林感染上报表(P_xinglin_INFECTION)',ERROR_MESSAGE())               
	end CATCH 

--更新BI
truncate table Gr_GrInfo
Insert into Gr_GrInfo(biyear,biquarter,bimonth,biweek,bidate,grgid,ksCode,blh,zyh,zycs,grbw,grssbh,nnis)
Select DATEPART(YY,a.grsj) biyear,DATEPART(QQ,a.grsj) biquarter,DATEPART(MM,a.grsj)biMonth,DATEPART(WW,a.grsj) biweek,
       CONVERT(varchar(10),a.grsj,120) bidate,a.ID,a.grks,a.brbh,a.zyh,a.zycs,a.grbw,a.grssbh,a.nnis  from hbidata..Gr_GrInfo a

end
/*
	exec p_gr_grinfo_Etl2

*/

--


