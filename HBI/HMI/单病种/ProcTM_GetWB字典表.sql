USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[ProcTM_GetWB]    Script Date: 08/13/2016 14:02:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Procedure [dbo].[ProcTM_GetWB]

As
Begin
--Ŀǰû�е��ã������Ҫ���ֹ����ã������������Ҫ�ֹ����� Select * from ͬúסԺ����
--  truncate table dbo.ͬú����ά��
  Insert Into dbo.ͬú����ά��(����,����,���)
    Select kscode,rtrim(ksname),ksxh
     From MPEHR.dbo.TuseKs
     Where  Not Exists(Select 1 From dbo.ͬú����ά�� Where ����=Convert(VarChar,kscode)) 

   Update ͬú����ά�� set ����= '�����һ����' where ���� like '%�����һ����%'

 --truncate table dbo.ͬúסԺ����
 --Insert Into dbo.ͬúסԺ����(dm,mc)
 --   Select kscode,ksname
 --    From MPEHR.dbo.TuseKs
 --    Where KsTag=1 and Not Exists(Select 1 From dbo.ͬúסԺ���� Where dm=Convert(VarChar,kscode))

 --truncate table ����ҽ��
  Insert Into ����ҽ��(ҽ������,ҽ������)
  Select UserName,LoginName From MPEHR.dbo.TuserInfo
   where not exists (Select 1 From ����ҽ�� Where ҽ������=LoginName)
 ----�����ά��
 -- truncate table [ͬú�����]
 -- Insert Into [ͬú�����]
 -- Select DeptID,DeptName From HBIData.dbo.WB_Dept where DeptID in ('134','135')
 ----�����������˿���ά��_�ٷ�
 -- truncate table W_HLZLKHKS
 -- Insert Into W_HLZLKHKS(xh,dm,mc,ksfl,kslx)
 -- Select KsCode,KsCode,KsName,Isnk,kslx=(Case When KZY=1 Then 1 When KMZ=1 Then 2 Else 0 ENd) from MPEHR.dbo.TuseKs 

  --����ά��
--  Select Max(BBQ) BBQ,kscode,kstype Into #Ks_Temp From TM_YS A Group By kscode,kstype
--  Select Distinct A.kscode No_Dept,A.ksname DeptName,A.kstype 
--    Into #KS
--    From TM_YS A 
--         Inner Join #Ks_Temp B On A.BBQ=B.BBQ And A.KsCode=B.KsCode And A.KsType=B.KsType
--  Update TM_KS Set KsName=#KS.DeptName From #KS Where TM_KS.KsCode=#KS.No_Dept
--  Insert Into TM_KS(KsCode,KsName,IsMZ,IsZY,IsJZ)
--    Select No_Dept,DeptName,
--           IsMz=Max(Case When kstype='011' Then 1 Else 0 End),
--           IsZy=Max(Case When kstype='02' Then 1 Else 0 End),
--           IsJz=Max(Case When kstype='012' Then 1 Else 0 End)
--      From #KS
--     Where No_Dept Not In (Select KsCode From TM_KS)
--   Group By No_Dept,DeptName
  --ҽ��ά��
--  Truncate Table TM_YS_WB
--  Insert Into TM_YS_WB(YsCode,YsName,YsDeptCode,YsDeptName,IsYS)
--  Select A.LoginName,UserName,KsCode,KsName,(Case When UserClass=1 THen 1 Else 0 ENd) isYS
--    from MPEHR.dbo.TuserInfo a 
--         Left join MPEHR.dbo.TuserInfo_szks B on A.LoginName=B.LoginName
--         Left join MPEHR.dbo.TuseKs C on B.szks=C.KsCode
 
--  --ȡ����ҽʦ��
--  Select NO_staff,CName 
--    Into #MzYS
--    From sxdt_dtmkzyy_lc.Tmkyymz.dbo.pubdictstaff 
--   Where Bdoctor =1 And 
--         CName in ('��ά��','��  ��','������','��  ��','���','��־�','������','������','������','������','����','������','�ź�һ','���Ĺ�','�޹�','������')
--  Delete TM_MZYS_WB From #MzYS Where TM_MZYS_WB.MZYSCode=#MzYS.NO_staff
--  Insert Into TM_MZYS_WB Select * From #MzYS
--  --ȡҩƷ����Ϣ
--  Select e.idrugdetailid,E.idgid,e.CdrugName,e.cSpname zm,e.Dw,e.Gg,e.Dj,e.Jx,e.cdgType,e.gx,e.CposionCode,E.JJ,--jldw ����Ǽ�����λӦ�ò�Ҫ
--         F.DDDUnit,F.DDDValue,f.basicdrug BNormalDrug,h.glName,E.iGermTypeID,J.CGermTypeName,E.Gltwo,K.cPosionName,L.cManufacturer cd
--    into #Lv_opddrug
--    From sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.Lv_opddrug e --ҩƷ��ͼ
--         Inner Join sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.DictDrug f --ҩƷ�����
--               On e.idgid = f.No_DictDrug  
--         Inner Join sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.DictDrugact L On E.idrugdetailid=L.NO_DrugAct
--         Left Join sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.dictgltwo h --ҩƷ�������
--               On e.Gltwo = h.glid
--         Left Join sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.DictGermType J On E.iGermTypeID=J.IGermTypeID
--         Left Join sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.DictposionClass K on E.cPosionCode=K.cPosionCode
--   Where lower(e.gg)<>'ddel'
--  Update TM_YP_WB Set Cd=#Lv_opddrug.CD From #Lv_opddrug Where TM_YP_WB.YPCode=#Lv_opddrug.idrugdetailid   --��������������Ϣ
--  Delete TM_YP_WB From #Lv_opddrug Where YPCode=idrugdetailid And TM_YP_WB.JX=IsNull(#Lv_opddrug.JX,'')
--  Insert Into TM_YP_WB(YPCode,YPName,ZMCode,ZMName,DW,GG,DJ,JX,YPFL,GX,PosionCode,JJ,DDDUnit,DDDValue,IsJBYP,TwoCode,TwoName,KJTypeCode,KJTypeName,PosionName,CD)
--    Select idrugdetailid,CdrugName,idgid,zm,Dw,Gg,
--           DJ,IsNull(JX,''),
--           (Case Lower(CdgType) When 'x' Then '��ҩ' When 'z' Then '�г�ҩ' When 'c' Then '�в�ҩ' End),
--           GX,CposionCode,JJ,DDDUnit,DDDValue,
--           (Case When IsNull(BNormalDrug,0)=1 Then 1 Else 0 End),Gltwo,glName,iGermTypeID,CGermTypeName,cPosionName,CD
--      From #Lv_opddrug
--  Update TM_YP_WB Set IsUse=(Case When IsNull(TM_YP.yp02,'')='' Then TM_YP_WB.IsUse Else 1 End)
--    From TM_YP Where TM_YP_WB.YPCode=TM_YP.yp02



End
/*

Alter Table TM_YP_WB Add CD VarChar(500)

Exec ProcTM_GetWB

Select * From TM_KS

Alter Table TM_YP_WB Add posionName VarChar(200)

Select Top 100 * From TM_YS Where BBQ>='2011-10-01' And BBQ<='2011-10-31' And KsType='011'

Select L.cManufacturer cd,* from sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.Lv_opddrug E
 Inner Join sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.DictDrugact L On E.idrugdetailid=L.NO_DrugAct
Select * from sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.DictDrugact



Select No_DictDrug from sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.DictDrugact Group By No_DictDrug Having Count(No_DictDrug)>1
Select No_DrugAct from sxdt_dtmkzyy_his.TMKYYHIS2000.dbo.DictDrugact Group By No_DrugAct Having Count(No_DictDrug)>1

*/
