USE [hbi_hmi]
GO
/****** Object:  StoredProcedure [dbo].[P_GetYC]    Script Date: 08/15/2016 16:38:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter PROCEDURE [dbo].[P_zyhzmxb](@serverDay Varchar(10),@EndDate Varchar(10))
AS
Begin


--�õ�סԺ��������סԺ���� DROP TABLE #CYBR,#CYRS      select distinct nldw from  HBIData.dbo.infoRYDJB where isnull(nldw,'')=''
Select GID,hzxm,hzxb iSex,zyh ,zycs,cyksdm ideptid,hznl nl,nldw,
       Convert(Varchar(10),rysj,120) dindate, Convert(Varchar(10),cysj,120) doutdate, 
       (Case When Convert(Varchar(10),ISNULL(cysj,GETDATE()),120)=Convert(Varchar(10),rysj,120) Then 1 
        Else datediff(day,rysj,ISNULL(cysj,GETDATE())) End) ZYTS,0 isycgfx,0 isddgfx
  Into #CYBR
  from HBIData.dbo.infoRYDJB 
 WHERE ( Convert(Varchar(10),rysj,120) between @serverDay and @EndDate or (Convert(Varchar(10),cysj,120) between @serverDay and @EndDate or cysj is  NULL ) )
       AND bah NOT LIKE 'B%' --AND DATEDIFF(dd,rysj,cysj)>0
       
--�����Ƿ�ѹ���߷��ձ�־ SELECT * from mpehr..THL_YCPF aa   
  --1.С�ڵ���14���Ƕ�ͯ����ͯѹ�������߷��յķ�ֵ��Χ��16�֣�����ѹ�������߷��յķ�ֵ��Χ��12��
SELECT distinct aa.brbh,aa.pgsj,aa.Braden_FZ,bb.nl,bb.nldw,0 ischild  INTO #isgfxyc from mpehr..THL_YCPF aa INNER JOIN #CYBR bb ON aa.brbh=bb.gid
where aa.pgsj=(select MIN(pgsj) from mpehr..THL_YCPF bb where aa.brbh=bb.brbh) 
UNION          
SELECT distinct aa.brbh,aa.pgsj,aa.Braden_FZ,bb.nl,bb.nldw,1 ischild   from mpehr..THL_YCPF_ET aa INNER JOIN #CYBR bb ON aa.brbh=bb.gid
where aa.pgsj=(select MIN(pgsj) from mpehr..THL_YCPF_ET bb where aa.brbh=bb.brbh) 

          
UPDATE a 
SET isycgfx=CASE WHEN b.ischild=1  AND  b.Braden_FZ<=16  THEN 1 
                 WHEN b.ischild=0  AND  b.Braden_FZ<=12  THEN 1 ELSE 0 end
FROM #CYBR a,#isgfxyc b
WHERE a.gid=b.brbh 

--�����Ƿ����׹���߷��ձ�־ select *   from mpehr..THL_Ddzcpf order by pgsj desc
----1.С�ڵ���14���Ƕ�ͯ����ͯ׹�������߷��յķ�ֵ��Χ��8�֣����˵��������߷��յķ�ֵ��Χ��4��
SELECT distinct aa.brbh,aa.pgsj,aa.pgzf,bb.nl,bb.nldw,0 ischild INTO #isgfxddzc from mpehr..THL_Ddzcpf aa INNER JOIN #CYBR bb ON aa.brbh=bb.gid
where aa.pgsj=(select MIN(pgsj) from mpehr..THL_Ddzcpf bb where aa.brbh=bb.brbh) 
UNION 
SELECT distinct aa.brbh,aa.pgsj,aa.pgzf,bb.nl,bb.nldw,1 ischild  from mpehr..THL_Ddzcpf_ET aa INNER JOIN #CYBR bb ON aa.brbh=bb.gid
where aa.pgsj=(select MIN(pgsj) from mpehr..THL_Ddzcpf_ET bb where aa.brbh=bb.brbh) 


UPDATE a 
SET isddgfx=CASE WHEN b.ischild=1  AND b.pgzf<=8 THEN 1 
                 WHEN b.ischild=0  AND  b.pgzf>=4 THEN 1  ELSE 0 end
FROM #CYBR a,#isgfxddzc b
WHERE a.gid=b.brbh 

 DELETE FROM  T_zyhzmxb WHERE EXISTS (SELECT 1 FROM #CYBR WHERE T_zyhzmxb.gid=#CYBR.gid) 

 INSERT INTO [T_zyhzmxb]
(bimonth,[gid],[hzxm],[hzxb],[zyh],[zycs],[cyksdm],[nl],[nldw],[rysj],[cysj],[zyts],isycgfx,isddgfx)
SELECT DATEPART(mm,doutdate) bimonth,gid,hzxm,iSex,zyh,zycs,ideptid cyksdm,nl,nldw,dindate,doutdate,ZYTS,isycgfx,isddgfx FROM #CYBR


end