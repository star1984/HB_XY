USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[P_bigDatainfo04]    Script Date: 10/29/2015 16:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER procedure [dbo].[P_bigDatainfo04]            
 @startTime datetime,                
 @endTime   datetime            
As    
/*
[整理]WAJ 
[日期]2015-05-25
[功能描述]
	1.门急诊费用数据清洗:	TM_MZFY
	2.提取门诊挂号次数信息清洗:	T_BA_mzghcs
	3.门诊病人用药情况清洗:	Mzbryy_info

*/        
Begin       
--科室维表
truncate table w_his_Ks
insert into w_his_Ks(xh,kscode,ksmc,IsMz,IsJz,iszy)
select XH,DeptID,DeptName,IsMz,IsJZ,IsZy from hbidata..WB_Dept 

--人员维表
truncate table w_his_people
INSERT INTO w_his_people(xh,dm,mc)
Select ROW_NUMBER() over(order by LoginName) xh,LoginName,UserName From MPEHR.dbo.TuserInfo



                
-----------------------------提取门诊挂号次数T_BA_mzghcs------------------------------------------------------------------------truncate table    T_BA_mzghcs     
  Select convert(VARCHAR(10),ghsj,120) bidate, ghksdm deptid,A.IsJZ,A.IsFZ Into #infomzgh2         
    From HBIData..infomzgh A        
    Where convert(VARCHAR(10),ghsj,120) Between convert(VARCHAR(10),@startTime,120) And convert(VARCHAR(10),@endTime,120)     
           --and Exists(Select 1 From HBIData..infoMZSF B Where  A.brid=B.brid and b.sflbdm=6)    
    
  Select deptid,bidate,count(deptid) rc,COUNT(case when IsJZ=1 then deptid else null end) jzrc,    
         COUNT(case when IsFZ=1 then deptid else null end) fzrc,    
         COUNT(case when IsJZ<>1 then deptid else null end) mzrc    
  Into #temprc2     
  From #infomzgh2      
  Group By deptid,bidate        
  
  --如果SET DATEFIRST 1 那么第几个星期按datepart(weekday,convert(datetime,bidate)+ @@DateFirst)；
  Delete T_BA_mzghcs where convert(VARCHAR(10),bidate,120) Between convert(VARCHAR(10),@startTime,120) And convert(VARCHAR(10),@endTime,120)     
      
  Insert T_BA_mzghcs(biyear,biquarter,bimonth,biweek,bidate,xq,xss,rc,kscode,jzrc,fzrc,mzrc)         
  Select datepart(yy,bidate) yy,        
         datepart(qq,bidate) qq,        
         datepart(mm,bidate) mm,        
         datepart(ww,bidate) ww,        
         convert(varchar(10),bidate,120),        
         datepart(weekday,convert(datetime,bidate)+ @@DateFirst) wk,        
         datepart(hh,bidate) hh,        
         rc,deptid,jzrc,fzrc,mzrc        
  from #temprc2  
  
-----------------------------门急诊挂号及费用数据-------------------------------------------------------------------- truncate table    TM_MZFY           
  Delete TM_MZFY where  convert(VARCHAR(10),bbq,120) Between convert(VARCHAR(10),@startTime,120) And convert(VARCHAR(10),@endTime,120)   
            
  Create Table #TM_MZFY (biyear Int,biquarter Int,bimonth Int,biweek Int,bbq Datetime,kscode Nvarchar(20),            
                         yscode Nvarchar(20) null,mz01 Int,mz02 decimal,mz08 decimal, mz12 decimal,mz13 decimal,mz14 decimal,mz15 decimal,              
                         KsType nvarchar(3),cfzs Int,cfkjyw Int,cfzcj Int)   
                                  
           
  Insert #TM_MZFY(biyear,biquarter,bimonth,biweek,bbq,kscode,mz01,mz02,mz08,mz12,mz13,mz14,mz15,KsType,cfzs,cfkjyw,cfzcj)            
  Select datepart(yy,a.jfsj) yy,datepart(qq,a.jfsj) qq,datepart(mm,a.jfsj) mm,datepart(ww,a.jfsj) ww,a.jfsj bbq,            
           a.kdksdm,0 mz01,Sum(je) zje,            
           Sum(Case When sjfmdm='002' or sjfmdm='003' or sjfmdm='004' Then je Else 0 End) mz08, 
           SUM(case when b.IsKSS=1 then je else 0 end ) mz12, 
           Sum(Case When sjfmdm='003' Then je Else 0 End) mz13, 
           Sum(Case When sjfmdm='004' Then je Else 0 End) mz14, 
           Sum(Case When sjfmdm='002' and b.IsKSS=0 Then je Else 0 End) mz15,        
           '' ksType,0,0,0            
   From HBIData..infoMZSF  a left join HBIData..WB_YPZD b on a.sfxmdm=b.YPID
   where  convert(VARCHAR(10),a.jfsj,120) Between convert(VARCHAR(10),@startTime,120) And convert(VARCHAR(10),@endTime,120)           
   Group By a.jfsj,a.kdksdm   
   
 --更新诊疗人次数                 
  Update b            
  Set mz01=a.rc            
  From #TM_MZFY b Inner Join #temprc2 a On a.deptid =b.kscode And convert(varchar(10),a.bidate,120)= convert(varchar(10),b.bbq,120)    
 

 
 insert into TM_MZFY(biyear,biquarter,bimonth,biweek,bbq,kscode,yscode,mz01,mz02,mz08,mz12,mz13,mz14,mz15,KsType,cfzs,cfkjyw,cfzcj) 
 select * from  #TM_MZFY
 
  

  /*          
--门诊处方总数量            
Select convert(varchar(10),b.jfsj,120) as cfdate,c.YPID,b.kdksdm,b.cfdjh,b.kdksdm,b.kdksmc,b.kdysdm,b.kdysxm,            
       b.sl,b.je,c.GG,b.zxksdm,b.zxksmc,c.IsKSS            
  Into #infoMZCF            
  from HBIData..infoMZSF b  --门诊收费记录表            
       left join HBIData..WB_YPZD c on b.sfxmdm=c.YPID            
  Where b.jfsj Between @startTime And @endTime  and b.sfxmdm in ('1','2','3') 
  

 

 
      
--HIS住院处方药品(使用人次)            
Select convert(varchar(10),b.jfsj,120) as cfdate,b.BRID blh,c.YPID,b.kdksdm,b.kdysdm,b.kdksmc,b.kdysxm,            
        b.sl,b.je,c.GG,b.zxksdm,b.zxksmc             
  Into #infozyCF             
  from HBIData..infoZYSF b  --住院收费记录表            
       left join HBIData..WB_YPZD c on  b.sfxmdm=c.YPID   --药品字典            
Where b.jfsj Between @startTime And @endTime            
             
Select Count(Distinct blh) as zs,cfdate,kdksdm,kdysdm Into #tmp4 From #infozyCF             
 Group By kdksdm,cfdate,kdysdm            
--注射剂处方数            
select Count(Distinct cfdjh) sl,cfdate,kdksdm Into #tmp2 from #infoMZCF  cf            
 inner join  HBIData..WB_YPZD yp on cf.YPID=yp.ypid and yp.iszj=1        
 Group By kdksdm,cfdate            
--抗菌药物处方数            
select Count(Distinct cfdjh) sl,cfdate,kdksdm Into #tmp3 from #infoMZCF cf             
 inner join  HBIData..WB_YPZD yp on cf.YPID=yp.ypid and yp.iskss=1            
 Group By kdksdm,cfdate            
 --更新诊疗人次数                 
Update #TM_MZFY            
   Set mz01=a.rc            
  From #TM_MZFY b            
 Inner Join #temprc2 a On a.deptid =b.kscode And a.bidate= b.bbq            
--更新门诊处方数              
Update #TM_MZFY            
   Set cfzs=c.zs            
  From #TM_MZFY b             
 Inner Join #tmp1 c On c.kdksdm=kscode And bbq=c.cfdate             
--更新注射剂处方数                
Update #TM_MZFY            
   Set cfzcj=c.sl            
  From #TM_MZFY b             
 Inner Join #tmp2 c On c.kdksdm=kscode And bbq=c.cfdate            
--更新抗菌药物处方数                
Update #TM_MZFY            
   Set cfkjyw=c.sl            
  From #TM_MZFY b             
 Inner Join #tmp3 c On c.kdksdm=kscode And bbq=c.cfdate            
--把更新后的结果添加到TM_MZFY表(yscode为null，kstype为null)            
Insert Into TM_MZFY(biyear,biquarter,bimonth,biweek,kscode,yscode,mz01,mz02,mz08,KsType,bbq,cfzs,cfkjyw,cfzcj)             
Select * From #TM_MZFY    
      
-------------------------------------门诊病人用药情况表-------------------------------------------------------------------            
Delete Mzbryy_info  Where bidate  Between @startTime And @endTime             
Create Table #Mzbryy_info ([biyear] int ,[biquarter] int ,[bimonth] int ,            
                        [biweek] int ,[bidate] datetime ,[nl] int ,[cfid] nvarchar(50) ,            
                        [hzxm] nvarchar(50) ,[xb] nvarchar(2) null,[mzh] nvarchar(50) null,            
                        [yppzs] int null,[jbyppzs] int null,[iszsj] int null,[ypdm] nvarchar(50) null,            
                        [xpmc] nvarchar(50) null,[tymc] nvarchar(50) null,[kscode] nvarchar(50) null,            
                        [yscode] nvarchar(50)   null,[gg] nvarchar(50) null,[sl] int null,[je] decimal null,            
                        [ypfl] nvarchar(50) null,[zd] nvarchar(100) null,[iskjyw] int null,[yfyl] nvarchar(50) null,            
                        [yytj] nvarchar(50) null,[cfje] decimal null,[isjbyw] int)            
 Insert #Mzbryy_info             
 Select datepart(yy,fysj) yy,datepart(qq,fysj) qq,datepart(mm,fysj) mm,datepart(ww,fysj) ww,            
         convert(varchar(10),fysj,120) as bicdate,datediff(yy,d.csrq,getdate()) as nl,a.cfdjh,            
         d.hzxm,hzxb,a.cfdjh,            
         0,0,c.iszj,c.ypid,            
         YPMC1,YPMC,b.kdksdm,            
         b.kdysdm,c.GG,b.sl,a.ypje,            
         c.YPFLMC,mzzd_mc zd,c.iskss,convert(varchar(10),e.zxplcs)+'/'+convert(varchar(10),zxpljg)+zxpljgdw,            
         e.gyfsmc,b.je,c.IsJBYW            
   from HBIData..infoMZYFFYJL a --门诊发药表            
   inner join HBIData..infoMZSF b on a.Sfjlid=b.Gid --门诊收费记录表            
   inner join HBIData..WB_YPZD c on a.YPID=c.YPID            
   inner join HBIData..infoMZGH d on a.MZID=d.Gid            
   inner join HBIData..infoMZCF e on b.yzid=e.CFID            
  Where a.fysj Between @startTime And @endTime            
--药品品种数,基本药物品种数,处方金额            
 Update #Mzbryy_info Set yppzs=mzbr.sl,jbyppzs=mzbr.jb,cfje=mzbr.je            
   From (            
         Select mzh,Count(distinct ypdm) sl,Sum(Case When isjbyw=1 Then isjbyw Else 0 End) jb,Sum(je) je              
           From #Mzbryy_info Group by mzh) As mzbr            
  Where #Mzbryy_info.mzh=mzbr.mzh               
                  
 Insert Mzbryy_info             
 Select * from #Mzbryy_info   
 
 */         
End            
/*            
 exec P_bigDatainfo04 '2015-01-01','2015-10-29'    
 select * from hbidata..infoMZSF where istj=1                  
*/          
               
                
                
          
          
          
          
       
          
           
              