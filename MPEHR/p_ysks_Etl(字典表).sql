USE [mpehr]
GO
/****** Object:  StoredProcedure [dbo].[p_ysks_Etl]    Script Date: 08/10/2016 09:26:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER ProceDure [dbo].[p_ysks_Etl]
As
Begin 
----同煤
----往HBI里抽取医生维表
--Truncate Table HBI_New.Dbo.TM_YS_WB
--Insert Into HBI_New.Dbo.TM_YS_WB(YSCode,YsName,YsDeptCode,YsDeptName,IsYS)  
--  Select A.No_Staff,A.cName,A.iDeptid,B.deptName,A.bDoctor
--    from sxdt_dtmkzyy_lc.tmkyymz.dbo.pubdictstaff A
--         Left Join sxdt_dtmkzyy_lc.tmkyymz.dbo.dictdept B On A.iDeptid=B.no_dept
----bDoctor=1医生
----bNurse=1护士
----bOperator=1科主任
----0行政
----1医生
----2护士
--Select distinct Identity(int,1,1) AutoID,cStaffCode,iDeptid,cName,bDoctor,bNurse,bOperator into #Tempys
--  from sxdt_dtmkzyy_lc.tmkyymz.dbo.pubdictstaff Where iDeptid Is Not Null
--  
----No_Deptclinicattr=1住院0门诊
----BIsJiZhen=1急诊
--Select no_dept,deptName,No_Deptclinicattr,BIsJiZhen into #Tempks from sxdt_dtmkzyy_lc.tmkyymz.dbo.dictdept 
--
----提取医生所在科室
-- Insert into TUserInfo_SZKS
--   Select distinct cStaffCode,iDeptid From #Tempys 
--    Where Not Exists(Select 1 From TUserInfo_SZKS Where #Tempys.cStaffCode=TUserInfo_SZKS.LoginName And #Tempys.iDeptid=szks)
----创建工号 
--Insert into Tuserinfo (UserYear,Jgdm,xzqh,IsAdminUnit,AdminUnitCode,LoginName,
--                       Pwd,UserName,UserTypeCode,PageSize,UserClass)  
--  Select distinct year(Getdate()) UserYear,'T13626580' Jgdm,'140203' xzqh,0 IsAdminUnit,0 AdminUnitCode,cStaffCode LoginName,
--         'C4CA4238A0B923820DCC509A6F75849B' Pwd,cName UserName,(Case When bnurse=1 Then 3 Else 8 End) UserTypeCode,10 PageSize,
--         (Case When bnurse=1 Then 2 Else 1 End) UserClass
--    from (Select * From #Tempys Where AutoID in (Select Min(AutoID) AutoID From #Tempys Group By cStaffCode)) a 
--   Where not Exists(Select * from Tuserinfo b where a.cStaffCode=b.loginName) 
----提取科室信息 
--Insert into Tuseks(Xzqh,Jgdm,KsCode,KsName,ShortName,WBCode,KsType,KsTag,SerialNumber,IsHJKS,HjType,IsSSKS,KMZ,KZY,KsCws,pym,KYJ,KJZ,Isnk)
--Select '140203' xzqh,'T13626580' Jgdm,no_dept,deptName ksname,deptName shortName,null WBcode,'1' kstype,
--       '2' ksTag,null SerialNumber,null isHjks,null Hjtype,0 isSSKS,
--       Case When No_Deptclinicattr='1' Then 0 Else 1 End KMz,
--       Case When No_Deptclinicattr='1' Then 1 Else 0 End kzy,
--       0 kscws,dbo.fGetPy(DeptName) pym,
--       0 kyj,
--       Case When BIsJiZhen='1' Then 1 Else 0 End kjz,
--       Case When DeptName Like '%内科%' Then 1 Else 0 End isNk 
--  from #Tempks a 
-- Where not exists(Select * from Tuseks b where convert(varchar,a.No_Dept)=b.kscode )

 declare @StartDate datetime,@EndDate datetime
 set @StartDate =Convert(Varchar(10),dateadd(dd,-30,getDate()),120)
 set @EndDate =Convert(Varchar(10),getdate(),120)
 --提取用户信息select * from Tusertype  
 Insert Into TuserInfo(UserYear,JGDM,Xzqh,IsAdminUnit,AdminUnitCode,LoginName,PWD,UserName,UserTypeCode,OfficePhone,HomePhone,
            MobilePhone,UserEmail,[Address],UserClass,isQy,PageSize,MenuType,GID,LoginCount,LoginTime)
 Select '2016' UserYear,'420424272' JGDM,'420606' Xzqh,0 IsAdminUnit,0 AdminUnitCode,gh LoginName,'C4CA4238A0B923820DCC509A6F75849B' PWD,TName UserName,
        (CASE When zc LIKE '%医%' Then '8' 
              When ZC LIKE '%护%' Then '3' 
              When ZC LIKE '%药%' Then '123' 
              When ZC LIKE '%技%' Then '132'  else '3' END ) UserTypeCode,null OfficePhone,null HomePhone,
        null MobilePhone,null UserEmail,null [Address],(Case When zc LIKE '%医%' Then '1' Else '2' End) UserClass,CASE WHEN isty=1 THEN 0 ELSE 1 end isQy,15 PageSize,1 MenuType,
        'BA04AF5E-781C-4234-BD08-3C081F1684C7' GID,5 LoginCount,'2016-01-01 00:00:00.000' LoginTime
   From HBIData.dbo.WB_Doctor
  where not exists (Select * from TuserInfo where TuserInfo.LoginName=HBIData.dbo.WB_Doctor.gh) and gh is not null 
  
--update a
--set UserTypeCode='10'
--from TuserInfo a, HBIData.dbo.WB_Doctor b
--where  a.LoginName=b.gh AND   b.zc like '%主任医%'  

       
 --提取用户所在科室信息  select * from TuserInfo_szks    select distinct  *   from HBIDATA.dbo.WB_Doctor_ks
 Insert Into TuserInfo_szks(LoginName,szks)
 Select distinct  a.Userid,a.DeptID from HBIDATA.dbo.WB_Doctor_ks a 
  where not exists (Select 1 from TuserInfo_szks where LoginName=a.Userid and szks=a.DeptID) and
        a.Userid is not null 
        
 delete from TuserInfo_szks where LoginName in ('003070','003090') and szks<>'9026'
 
 ----删除HIS里人员调科室后之前所属科室的信息，
 --DELETE TuserInfo_szks
 --WHERE LoginName IN (SELECT DISTINCT USERID  FROM HBIDATA.dbo.WB_Doctor_ks) 
 --      AND NOT EXISTS (SELECT 1 FROM HBIDATA.dbo.WB_Doctor_ks b WHERE TuserInfo_szks.LoginName=b.UserID AND TuserInfo_szks.szks=b.DeptID)
 
 --提取科室信息  Select * from  TuseKs 

 Insert Into TuseKs(Xzqh,Jgdm,KsCode,KsXH,KsName,ShortName,WBCode,KsType,KsTag,SerialNumber,IsHJKS,HjType,
                    IsSSKS,KMZ,KZY,KsCws,pym,KYJ,KJZ,Isnk)
 Select '420606' Xzqh,'420424272' JGDM,Deptid,XH,DeptName,DeptName,null,1 KsType,
        (Case When IsTy=1 Then 1 Else 2 ENd) KsTag,null,null,null,
        isss IsSSKS,IsMz, Iszy,CWS,PYM,IsYJ,
        Isjz ,0 Isnk
   from HBIData.dbo.WB_Dept 
  where   not exists (Select * from TuseKs where TuseKs.KsCode=HBIData.dbo.WB_Dept.Deptid) 
  
  
  update TuseKs 
  set kzy=1
  from  (select distinct ryksdm ks from   hbidata..infoRYDJB 
         union   
         select distinct cyksdm ks from   hbidata..infoRYDJB ) a 
  where TuseKs.KsCode=a.ks  

--药品字典select * from TWB_YPZD
  TRUNCATE TABLE TWB_YPZD 
  INSERT INTO TWB_YPZD(ypid,ypmc,tymc,pym,pzwh,sccj,yfyl)
  SELECT ypid ,ypmc ,ypmc  tymc,dbo.fGetPy(ypmc),RIGHT(pzwh,9) pzwh,SCCJMC sccj,NULL yfyl FROM hbidata..wb_ypzd
  

----内科系统
--update TuseKs set Isnk= 1
-- where KsCode in (Select DeptID from HBIData.dbo.WB_Dept 
--                   where SJDeptID in(Select DeptID from HBIData.dbo.WB_Dept where SJDeptID='134'))
--update TuseKs set Isnk= 1 
--  where KsCode In(Select DeptID from HBIData.dbo.WB_Dept 
--                   where SJDeptID in(Select DeptID from HBIData.dbo.WB_Dept 
--                                      where SJDeptID in(Select DeptID from HBIData.dbo.WB_Dept where SJDeptID='134')))
----外科系统
--update TuseKs set Isnk= 2
-- where KsCode in (Select DeptID from HBIData.dbo.WB_Dept 
--                   where SJDeptID in(Select DeptID from HBIData.dbo.WB_Dept where SJDeptID='135'))
--update TuseKs set Isnk= 2
--  where KsCode In(Select DeptID from HBIData.dbo.WB_Dept 
--                   where SJDeptID in(Select DeptID from HBIData.dbo.WB_Dept 
--                                      where SJDeptID in(Select DeptID from HBIData.dbo.WB_Dept where SJDeptID='135')))

----住院科室
--update TuseKs set KZY=1 where KsName like '%护理组%'
End 

/*

Select isss,* from HBIData.dbo.WB_Dept  where isss=1
exec [p_ysks_Etl]
*/
