USE [HBI_HMI]
GO
/****** Object:  StoredProcedure [dbo].[P_InsDBZ3Data]    Script Date: 06/15/2015 08:50:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[P_InsDBZ3Data]
AS
Begin
  --心力衰竭提取数据SELECT * from TBZ3_Xlsj
  Truncate Table TBZ3_Xlsj
  Insert Into TBZ3_Xlsj(biyear,biquarter,bimonth,biweek,bidate,brbh,zyh,hzxm,bgys,zgys,rysj,cysj,zyts,ssrq,zyzfy,yf,ssf,
                        ksdm,zsszmqnj,fdmssy,zssxfsLVEF,zssbl,ddyyhlnjjjz_sjzlsj,ddyyhACEIARB_sjzlsj,qgrjkj_sjzlsj,
                        NYHAxgnfj,cyhycqyz_ACEIARB,rypgnryjl,xjssyjl,zdssyjl,cyzdssyjl,zljg,lyfs,hzdfwtypj_ktxzzysj,
                        hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,hzdfwtypj_ssmyd,hzdfwtypj_btjq,hzdfwtypj_kfzs,
                        bgsj,xxxp,xgnpjsj,Killip,stzzjsjzlsj,cyhjzszhmaceiarb,cyhbstzzj,cyhqztjkj,jkjyrypgnr,
                        jkjyxjss,jkjyfywzlzd,jkjycyzdss)
  Select YEAR(bgsj),DATEPART(qq,bgsj),DATEPART(mm,bgsj),DATEPART(ww,bgsj),bgsj,
         a.brbh,zyh,hzxm,bgys,zgys_id,rydate,cydate,zyts,zssrq,zyzfy,yf,ssf,
         (Case When isnull(B.cyks_ID,'')='' Then '1314' Else b.cyks_id End) ksdm,
         zsszmqnj,fdmssy,zssxfs,zssbl,ddyyhlnjjjz_sjzlsj,ddyyhACEIARB_sjzlsj,qgrjkj_sjzlsj,
         NYHAxgnfj,cyhycqyz_ACEIARB,rypgnryjl,xjssyjl,zdssyjl,cyzdssyjl,zljg,lyfs,
         hzdfwtypj_ktxzzysj,hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,hzdfwtypj_ssmyd,hzdfwtypj_btjq,hzdfwtypj_kfzs,
         bgsj,fyxhfsz xxxp,csxdtjcsj xgnpjsj,Killipfj Killip,ddyyhsystzzj_sjzlsj stzzjsjzlsj,
         cyhycqyz_ACEIARB cyhjzszhmaceiarb,cyhycqyz_stzzj cyhbstzzj,cyhycqyz_qgtjkj cyhqztjkj,
         rypgnryjl jkjyrypgnr,xjssyjl jkjyxjss,zdssyjl jkjyfywzlzd,cyzdssyjl jkjycyzdss
    from MPEHR.dbo.TBZ3_Xlsj A
         left join MPEHR.DBO.THzxxb B on A.brbh=B.brbh
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
   Where c.shzt=1

  --社区获得性肺炎-成人提取数据
  truncate table T_TBZ_Sqhdxfy_CR
  Insert Into T_TBZ_Sqhdxfy_CR(biyear,biquarter,bimonth,biweek,bidate,brbh,zyh,hzxm,zgys,bgys,rysj,
                               cysj,zyts,zssrq,zyzfy,yf,ssf,ksdm,yzdpgCURBzfz,yzdzsPSIzfz,ssyhpgsj,dmxqfx,
                               ICUzyjtxpybzsj,rICUbz,hzjssjkjywzlsj,wtljdxjgrwxys,ytljdxjgrwxys,fylqj,lgsxgjktmlj,
                               jyxlmg,jyxlny,bcsEsblsj,cEsblsj,cAmpcmj,tljdbj_qdz,tljdbj,Bzlqj,yyj,dhxbzdxlstj,
                               sfjtj,brkgj,jcxm,bhxqjyxzdxccsyz,cszl72xshpj,cfbyxjccjyy,zskjywlc,kfkjywlc,whztgjyzxjkfd,
                               fhcybzjscy,lyfs,zljg,hzdfwtypj_ktxzzysj,hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,
                               hzdfwtypj_ssmyd,hzdfwtypj_btjq,hzdfwtypj_kfzs,
                               bgsj,zzfyzdbz,qznwjc,lnryjc,xrybbicu,kjywszssyts)
  Select YEAR(bgsj),DATEPART(qq,bgsj),DATEPART(mm,bgsj),DATEPART(ww,bgsj),bgsj,
         A.brbh,zyh,hzxm,zgys_id,bgys,ryDate rysj,cyDate cysj,zyts,zssrq,zyzfy,yf,ssf,
         (Case When isnull(B.cyks_ID,'')='' Then '1314' Else b.cyks_id End) ksdm,
         yzdpgCURBzfz,yzdzsPSIzfz,ssyhpgsj,dmxqfx,
         ICUzyjtxpybzsj,rICUbz,hzjssjkjywzlsj,wtljdxjgrwxys,ytljdxjgrwxys,fylqj,lgsxgjktmlj,
         jyxlmg,jyxlny,bcsEsblsj,cEsblsj,cAmpcmj,tljdbj_qdz,tljdbj,Bzlqj,yyj,dhxbzdxlstj,
         sfjtj,brkgj,jcxm,bhxqjyxzdxccsyz,cszl72xshpj,cfbyxjccjyy,zskjywlc,kfkjywlc,whztgjyzxjkfd,
         fhcybzjscy,lyfs,zljg,hzdfwtypj_ktxzzysj,hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,
         hzdfwtypj_ssmyd,hzdfwtypj_btjq,hzdfwtypj_kfzs,
         bgsj,zzfyzdbz,qznwjcjbhz qznwjc,lnryjcjbhz lnryjc,xryzldbbsrICU xrybbicu,zskjywlc kjywszssyts
    From MPEHR.dbo.TBZ3_Sqhdxfy_CR A
         left join MPEHR.DBO.THzxxb B on A.brbh=B.brbh
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
   Where c.shzt=1
  
  --缺血性卒中/脑梗死
  Truncate Table T_TBZ3_Ngs 
  Insert Into T_TBZ3_Ngs (biyear,biquarter,bimonth,biweek,bidate,brbh,zyh,hzxm,zgys,bgys,rysj,cysj,zyts,zssrq,
                          zyzfy,yf,ssf,ksdm,sjnkhjzkysjzsj,ddjzksj,jzNIHSSpgfz,ryNIHSSpgfz,jzhrysctlCTyzxdsj,
                          jzhrysctlCTyzbgsj,xyyzxdsj,xybgsj,lxyzxdsj,lxbgsj,shyzxdsj,shbgsj,ECGbgsj,fbsj,rspgjl,
                          ssrskssj,rsy,ryqklzlyw,zyqjklzlyw,cysdklyw,kxxbjjywsj,pgsj,xzsppgxm,pjxzjg,jzzlyzxdsj,
                          hymyzj,ysl,btl,pjffxz,ryhpqpd,yfDVTzlsj,kxxbjjzlyw,yfcklywxz,jzywzl,zzjkjy,jsjyjy,Essenfxpfxx,
                          wnjxkkyy,xggnpgsj,lyfs,zljg,jshj,zdhjs,yyssd,yyhjfbcd,yyhsmyd,shzlgs,klzljjz,hzyfc,kfzsmyd,
                          TLCTJC,ECGJC,lstdsj,rxkssj,rxjssj,kxxbjjywxz,tyknpjffxz,wjxtyknpjyy,jzzlywxz,xggnpjff,kfzlsyxpgjg,
                          kfss,kfpjysssj,cyssyaspllpgl,xyxjc,nxgnjc,shjy,dyzd,czjkjy_ylb,jsjyjyzl_ylb,KFSS_YLB,JYTYKNPJSJ,SSRXTJ)
  Select YEAR(bgsj),DATEPART(qq,bgsj),DATEPART(mm,bgsj),DATEPART(ww,bgsj),bgsj,
         A.brbh,zyh,hzxm,zgys_id,bgys,B.ryDate,B.cyDate,zyts,zssrq,zyzfy,yf,ssf,
         (Case When isnull(B.cyks_ID,'')='' Then '1314' Else B.cyks_id End)  ksdm,
         sjnkhjzkysjzsj,ddjzksj,jzNIHSSpgfz,ryNIHSSpgfz,jzhrysctlCTyzxdsj,
         jzhrysctlCTyzbgsj,xyyzxdsj,xybgsj,lxyzxdsj,lxbgsj,shyzxdsj,shbgsj,ECGbgsj,fbsj,rspgjl,
         ssrskssj,rsy,ryqklzlyw,zyqjklzlyw,cysdklyw,kxxbjjywsj,pgsj,xzsppgxm,pjxzjg,jzzlyzxdsj,
         hymyzj,ysl,btl,pjffxz,ryhpqpd,yfDVTzlsj,kxxbjjzlyw,yfcklywxz,jzywzl,zzjkjy,jsjyjy,Essenfxpfxx,
         wnjxkkyy,xggnpgsj,lyfs,zljg,jshj,zdhjs,yyssd,yyhjfbcd,yyhsmyd,shzlgs,klzljjz,hzyfc,kfzsmyd,
         TLCTJC=Convert(Varchar(10),datediff(n,jzhrysctlCTyzxdsj,jzhrysctlCTyzbgsj))+'分',         
         ECGJC=Convert(Varchar(10),datediff(n,sjnkhjzkysjzsj,ECGbgsj))+'分',         
         lstdsj=lstdsjpg,rxkssj=ssrskssj,rxjssj=ssrsjssj,kxxbjjywxz=kxxbjjywxz,tyknpjffxz=pjffxz,wjxtyknpjyy=wjxtypjyy,
         jzzlywxz=(Case When isnull(D.WBName,'')<>'' Then Convert(Varchar(10),D.WbName)+'、' Else '' End)+
                  (Case When isnull(E.WBName,'')<>'' Then Convert(Varchar(10),E.WbName)+'、' Else '' End)+
                  (Case When isnull(F.WBName,'')<>'' Then Convert(Varchar(10),F.WbName)+'、' Else '' End),
         xggnpjff=pjff,kfzlsyxpgjg=kfzlsyxpg,kfss=kfss,kfpjysssj=kfpjsssj,
         cyssyaspllpgl=(Case When isnull(G.WBName,'')<>'' Then Convert(Varchar(10),G.WbName)+'、' Else '' End)+
                       (Case When isnull(H.WBName,'')<>'' Then Convert(Varchar(10),H.WbName)+'、' Else '' End)+
                       (Case When isnull(I.WBName,'')<>'' Then Convert(Varchar(10),I.WbName)+'、' Else '' End),
         xyxjc=Convert(Varchar(10),datediff(n,xyyzxdsj,xybgsj))+'分',
         nxgnjc=Convert(Varchar(10),datediff(n,lxyzxdsj,lxbgsj))+'分',
         shjy=Convert(Varchar(10),datediff(n,shyzxdsj,shbgsj))+'分',
         Icd10dm,
         czjkjy_ylb=(Case When isnull(J_1.WBName,'')<>'' Then J_1.WBName+'、' Else '' End)+
                    (Case When isnull(J_2.WBName,'')<>'' Then J_2.WBName+'、' Else '' End)+
                    (Case When isnull(J_3.WBName,'')<>'' Then J_3.WBName+'、' Else '' End),
         jsjyjyzl_ylb=(Case When isnull(K_1.WBName,'')<>'' Then K_1.WBName+'、' Else '' End)+
                      (Case When isnull(K_2.WBName,'')<>'' Then K_2.WBName+'、' Else '' End)+
                      (Case When isnull(K_3.WBName,'')<>'' Then K_3.WBName+'、' Else '' End)+
                      (Case When isnull(K_4.WBName,'')<>'' Then K_4.WBName+'、' Else '' End),
         KFSS_YLB=(Case When isnull(L_1.WBName,'')<>'' Then L_1.WBName+'、' Else '' End)+
                  (Case When isnull(L_2.WBName,'')<>'' Then L_2.WBName+'、' Else '' End)+
                  (Case When isnull(L_3.WBName,'')<>'' Then L_3.WBName+'、' Else '' End)+
                  (Case When isnull(L_4.WBName,'')<>'' Then L_4.WBName+'、' Else '' End)+
                  (Case When isnull(L_5.WBName,'')<>'' Then L_5.WBName+'、' Else '' End)+
                  (Case When isnull(L_6.WBName,'')<>'' Then L_6.WBName+'、' Else '' End),
         JYTYKNPJSJ=tyknpjss,SSRXTJ=ssrstj
    from MPEHR.DBO.TBZ3_Ngs A
         left join MPEHR.DBO.THzxxb B on A.brbh=B.brbh
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
         left join MPEHR.dbo.TWordBook D on A.hymyzj=D.WbCode and D.WBTypeCode='25113'
         left join MPEHR.dbo.TWordBook E on A.ysl=E.WbCode and E.WBTypeCode='25114'
         left join MPEHR.dbo.TWordBook F on A.btl=F.WbCode and F.WBTypeCode='25115'
         left join MPEHR.dbo.TWordBook G on A.kxxbjjzlyw=G.WbCode and G.WBTypeCode='25125'
         left join MPEHR.dbo.TWordBook H on A.yfcklywxz=H.WbCode and H.WBTypeCode='25126'
         left join MPEHR.dbo.TWordBook I on A.jzywzl=I.WbCode and I.WBTypeCode='25127'
         Left Join MPEHR.DBO.TWordBook J_1 On J_1.WBTypeCode='25133' And J_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.zzjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook J_2 On J_2.WBTypeCode='25133' And J_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.zzjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook J_3 On J_3.WBTypeCode='25133' And J_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.zzjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook K_1 On K_1.WBTypeCode='25134' And K_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.jsjyjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook K_2 On K_2.WBTypeCode='25134' And K_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.jsjyjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook K_3 On K_3.WBTypeCode='25134' And K_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.jsjyjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook K_4 On K_4.WBTypeCode='25134' And K_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.jsjyjy,'|') Where RowIndex=4)
         Left Join MPEHR.DBO.TWordBook L_1 On L_1.WBTypeCode='25145' And L_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.kfss,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook L_2 On L_2.WBTypeCode='25145' And L_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.kfss,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook L_3 On L_3.WBTypeCode='25145' And L_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.kfss,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook L_4 On L_4.WBTypeCode='25145' And L_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.kfss,'|') Where RowIndex=4)
         Left Join MPEHR.DBO.TWordBook L_5 On L_5.WBTypeCode='25145' And L_5.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.kfss,'|') Where RowIndex=5)
         Left Join MPEHR.DBO.TWordBook L_6 On L_6.WBTypeCode='25145' And L_6.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.kfss,'|') Where RowIndex=6)
   Where c.shzt=1

  --髋关节置换术
  truncate table T_TBZ3_Kgjzhs
  Insert Into T_TBZ3_Kgjzhs(biyear,biquarter,bimonth,biweek,bidate,brbh,zyh,hzxm,zgys,bgys,ryrq,cyrq,zyts,
                            ssrq,zyzfy,yf,ssf,gjjtf,ksdm,zkzfz,ykzfz,yfxkjywxz,sqsysjkjywsj,ssqssj,szsj,szzjyy,
                            shjssysj,sh3tzsjxsyyy,ywyfDTVzlyzdsj,yfxdgyywzl,dc_szsxl,sc_szsxl,scjskfsj,sshkffs,
                            bsnkjb,sshbfz,ryxj,sqyrjkjy,sh6hnjkjy,sh6d12hjkjy,shyznjkjy,shyzhjkjy,cyqjkjy,qkhdj,
                            lyfs,zljg,hzdfwtypj_ktxzzysj,hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,hzdfwtypj_ssmyd,
                            hzdfwtypj_btjq,hzdfwtypj_kfzs,
                            bgsj,ssfs,sxlx,kgjyxcd,ryxj_YLB,sqyrjkjy_YLB,sh6hnjkjy_YLB,sh6d12hjkjy_YLB,shyznjkjy_YLB,
                            shyzhjkjy_YLB,cyqjkjy_YLB)
  Select YEAR(bgsj),DATEPART(qq,bgsj),DATEPART(mm,bgsj),DATEPART(ww,bgsj),bgsj,
         A.brbh,zyh,hzxm,zgys_id,bgys,rydate,cydate,zyts,zssrq,A.zyzfy,A.yf,ssf,gjjtfy,
         (Case When isnull(B.cyks_ID,'')='' Then '1314' Else B.cyks_id End) ksdm,
         zkzfz,ykzfz,yfxkjywxz,sqsysjkjywsj,ssqssj,szsj,szzjyy,shjssysj,sh3tzsjxsyyy,ywyfDTVzlyzdsj,
         yfxdgyywzl,dc_szsxl,sc_szsxl,scjskfsj,sshkffs,bsnkjb,sshbfz,ryxj,sqyrjkjy,sh6hnjkjy,sh6d12hjkjy,
         shyznjkjy,shyzhjkjy,cyqjkjy,qkhdj,lyfs,zljg,hzdfwtypj_ktxzzysj,hzdfwtypj_zlfa,hzdfwtypj_cdqj,
         hzdfwtypj_shhj,hzdfwtypj_ssmyd,hzdfwtypj_btjq,hzdfwtypj_kfzs,
         bgsj,ssbw ssfs,lb sxlx,sshbfz_yxcd kgjyxcd,
         ryxj_YLB=(Case WHen Isnull(D_1.WBName,'')<>'' THen D_1.WBName+'、' ELse '' End)+
                  (Case WHen Isnull(D_2.WBName,'')<>'' THen D_2.WBName+'、' ELse '' End)+
                  (Case WHen Isnull(D_3.WBName,'')<>'' THen D_3.WBName+'、' ELse '' End)+
                  (Case WHen Isnull(D_4.WBName,'')<>'' THen D_4.WBName+'、' ELse '' End),
         sqyrjkjy_YLB=(Case WHen Isnull(E_1.WBName,'')<>'' THen E_1.WBName+'、' ELse '' End)+
                      (Case WHen Isnull(E_2.WBName,'')<>'' THen E_2.WBName+'、' ELse '' End)+
                      (Case WHen Isnull(E_3.WBName,'')<>'' THen E_3.WBName+'、' ELse '' End)+
                      (Case WHen Isnull(E_4.WBName,'')<>'' THen E_4.WBName+'、' ELse '' End),
         sh6hnjkjy_YLB=(Case WHen Isnull(F_1.WBName,'')<>'' THen F_1.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(F_2.WBName,'')<>'' THen F_2.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(F_3.WBName,'')<>'' THen F_3.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(F_4.WBName,'')<>'' THen F_4.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(F_5.WBName,'')<>'' THen F_5.WBName+'、' ELse '' End),
         sh6d12hjkjy_YLB=(Case WHen Isnull(G_1.WBName,'')<>'' THen G_1.WBName+'、' ELse '' End)+
                         (Case WHen Isnull(G_2.WBName,'')<>'' THen G_2.WBName+'、' ELse '' End)+
                         (Case WHen Isnull(G_3.WBName,'')<>'' THen G_3.WBName+'、' ELse '' End)+
                         (Case WHen Isnull(G_4.WBName,'')<>'' THen G_4.WBName+'、' ELse '' End)+
                         (Case WHen Isnull(G_5.WBName,'')<>'' THen G_5.WBName+'、' ELse '' End)+
                         (Case WHen Isnull(G_6.WBName,'')<>'' THen G_6.WBName+'、' ELse '' End),
         shyznjkjy_YLB=(Case WHen Isnull(H_1.WBName,'')<>'' THen H_1.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(H_2.WBName,'')<>'' THen H_2.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(H_3.WBName,'')<>'' THen H_3.WBName+'、' ELse '' End),
         shyzhjkjy_YLB=(Case WHen Isnull(I_1.WBName,'')<>'' THen I_1.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(I_2.WBName,'')<>'' THen I_2.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(I_3.WBName,'')<>'' THen I_3.WBName+'、' ELse '' End),
         cyqjkjy_YLB=(Case WHen Isnull(J_1.WBName,'')<>'' THen J_1.WBName+'、' ELse '' End)+
                     (Case WHen Isnull(J_2.WBName,'')<>'' THen J_2.WBName+'、' ELse '' End)+
                     (Case WHen Isnull(J_3.WBName,'')<>'' THen J_3.WBName+'、' ELse '' End)+
                     (Case WHen Isnull(J_4.WBName,'')<>'' THen J_4.WBName+'、' ELse '' End)
    from MPEHR.dbo.TBZ3_Kgjzhs A
         left join MPEHR.DBO.THzxxb B on A.brbh=B.brbh
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
         Left Join MPEHR.DBO.TWordBook D_1 On D_1.WBTypeCode='23027' And D_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.ryxj,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook D_2 On D_2.WBTypeCode='23027' And D_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.ryxj,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook D_3 On D_3.WBTypeCode='23027' And D_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.ryxj,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook D_4 On D_4.WBTypeCode='23027' And D_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.ryxj,'|') Where RowIndex=4)
         Left Join MPEHR.DBO.TWordBook E_1 On E_1.WBTypeCode='23028' And E_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sqyrjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook E_2 On E_2.WBTypeCode='23028' And E_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sqyrjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook E_3 On E_3.WBTypeCode='23028' And E_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sqyrjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook E_4 On E_4.WBTypeCode='23028' And E_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sqyrjkjy,'|') Where RowIndex=4)
         Left Join MPEHR.DBO.TWordBook F_1 On F_1.WBTypeCode='23029' And F_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6hnjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook F_2 On F_2.WBTypeCode='23029' And F_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6hnjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook F_3 On F_3.WBTypeCode='23029' And F_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6hnjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook F_4 On F_4.WBTypeCode='23029' And F_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6hnjkjy,'|') Where RowIndex=4)
         Left Join MPEHR.DBO.TWordBook F_5 On F_5.WBTypeCode='23029' And F_5.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6hnjkjy,'|') Where RowIndex=5)
         Left Join MPEHR.DBO.TWordBook G_1 On G_1.WBTypeCode='23030' And G_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12hjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook G_2 On G_2.WBTypeCode='23030' And G_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12hjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook G_3 On G_3.WBTypeCode='23030' And G_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12hjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook G_4 On G_4.WBTypeCode='23030' And G_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12hjkjy,'|') Where RowIndex=4)
         Left Join MPEHR.DBO.TWordBook G_5 On G_5.WBTypeCode='23030' And G_5.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12hjkjy,'|') Where RowIndex=5)
         Left Join MPEHR.DBO.TWordBook G_6 On G_6.WBTypeCode='23030' And G_6.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12hjkjy,'|') Where RowIndex=6)
         Left Join MPEHR.DBO.TWordBook H_1 On H_1.WBTypeCode='23031' And H_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyznjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook H_2 On H_2.WBTypeCode='23031' And H_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyznjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook H_3 On H_3.WBTypeCode='23031' And H_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyznjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook I_1 On I_1.WBTypeCode='23032' And I_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyzhjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook I_2 On I_2.WBTypeCode='23032' And I_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyzhjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook I_3 On I_3.WBTypeCode='23032' And I_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyzhjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook J_1 On J_1.WBTypeCode='23033' And J_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.cyqjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook J_2 On J_2.WBTypeCode='23033' And J_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.cyqjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook J_3 On J_3.WBTypeCode='23033' And J_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.cyqjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook J_4 On J_4.WBTypeCode='23033' And J_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.cyqjkjy,'|') Where RowIndex=4)        
   Where c.shzt=1

  --膝关节置换术
  truncate table T_TBZ3_Xgjzhs
  Insert Into T_TBZ3_Xgjzhs(biyear,biquarter,bimonth,biweek,bidate,brbh,zyh,hzxm,zgys,bgys,ryrq,cyrq,zyts,ssrq,zyzfy,yf,
                            ssf,gjjtfy,ksdm,zxzfz,yxzfz,yfxkjywxz,sqsysjkjywsj,ssqssj,szsj,szzjyy,shjssysj,sh3thjxsyyy,
                            ywydDVTzlyzxssj,yfxdjjywzl,dc_szsxl,sc_szsxl,scjskfsj,sshkffs,bsnkjb,sshbfz,ryxj,sqyrjkjy,
                            sh6hnjkjy,sh6d12jkjy,shyznjkjy,shyzhjkjy,cyqjkjy,qkyhdj,lyfs,zljg,hzdfwtypj_ktxzzysj,
                            hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,hzdfwtypj_ssmyd,hzdfwtypj_btjq,hzdfwtypj_kfzs,
                            bgsj,ssfs,sxlb,yxcd,ryxj_YLB,sqyrjkjy_YLB,sh6hnjkjy_YLB,sh6d12hjkjy_YLB,shyznjkjy_YLB,
                            shyzhjkjy_YLB,cyqjkjy_YLB)
  Select YEAR(bgsj),DATEPART(qq,bgsj),DATEPART(mm,bgsj),DATEPART(ww,bgsj),bgsj,
         A.brbh,zyh,hzxm,zgys_id,bgys,rydate,cydate,zyts,zssrq,A.zyzfy,A.yf,ssf,gjjtfy,
         (Case When isnull(B.cyks_ID,'')='' Then '1314' Else B.cyks_id End) ksdm,
         zxzfz,yxzfz,yfxkjywxz,sqsysjkjywsj,ssqssj,szsj,szzjyy,shjssysj,sh3thjxsyyy,
         ywydDVTzlyzxssj,yfxdjjywzl,dc_szsxl,sc_szsxl,scjskfsj,sshkffs,bsnkjb,sshbfz,ryxj,sqyrjkjy,
         sh6hnjkjy,sh6d12jkjy,shyznjkjy,shyzhjkjy,cyqjkjy,qkyhdj,lyfs,zljg,hzdfwtypj_ktxzzysj,
         hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,hzdfwtypj_ssmyd,hzdfwtypj_btjq,hzdfwtypj_kfzs,
         bgsj,ssbw ssfs,sxlb sxlb,sshbfz_yxcd yxcd,
         ryxj_YLB=(Case WHen Isnull(D_1.WBName,'')<>'' THen D_1.WBName+'、' ELse '' End)+
                  (Case WHen Isnull(D_2.WBName,'')<>'' THen D_2.WBName+'、' ELse '' End)+
                  (Case WHen Isnull(D_3.WBName,'')<>'' THen D_3.WBName+'、' ELse '' End)+
                  (Case WHen Isnull(D_4.WBName,'')<>'' THen D_4.WBName+'、' ELse '' End),
         sqyrjkjy_YLB=(Case WHen Isnull(E_1.WBName,'')<>'' THen E_1.WBName+'、' ELse '' End)+
                      (Case WHen Isnull(E_2.WBName,'')<>'' THen E_2.WBName+'、' ELse '' End)+
                      (Case WHen Isnull(E_3.WBName,'')<>'' THen E_3.WBName+'、' ELse '' End)+
                      (Case WHen Isnull(E_4.WBName,'')<>'' THen E_4.WBName+'、' ELse '' End),
         sh6hnjkjy_YLB=(Case WHen Isnull(F_1.WBName,'')<>'' THen F_1.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(F_2.WBName,'')<>'' THen F_2.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(F_3.WBName,'')<>'' THen F_3.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(F_4.WBName,'')<>'' THen F_4.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(F_5.WBName,'')<>'' THen F_5.WBName+'、' ELse '' End),
         sh6d12hjkjy_YLB=(Case WHen Isnull(G_1.WBName,'')<>'' THen G_1.WBName+'、' ELse '' End)+
                         (Case WHen Isnull(G_2.WBName,'')<>'' THen G_2.WBName+'、' ELse '' End)+
                         (Case WHen Isnull(G_3.WBName,'')<>'' THen G_3.WBName+'、' ELse '' End)+
                         (Case WHen Isnull(G_4.WBName,'')<>'' THen G_4.WBName+'、' ELse '' End)+
                         (Case WHen Isnull(G_5.WBName,'')<>'' THen G_5.WBName+'、' ELse '' End)+
                         (Case WHen Isnull(G_6.WBName,'')<>'' THen G_6.WBName+'、' ELse '' End),
         shyznjkjy_YLB=(Case WHen Isnull(H_1.WBName,'')<>'' THen H_1.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(H_2.WBName,'')<>'' THen H_2.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(H_3.WBName,'')<>'' THen H_3.WBName+'、' ELse '' End),
         shyzhjkjy_YLB=(Case WHen Isnull(I_1.WBName,'')<>'' THen I_1.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(I_2.WBName,'')<>'' THen I_2.WBName+'、' ELse '' End)+
                       (Case WHen Isnull(I_3.WBName,'')<>'' THen I_3.WBName+'、' ELse '' End),
         cyqjkjy_YLB=(Case WHen Isnull(J_1.WBName,'')<>'' THen J_1.WBName+'、' ELse '' End)+
                     (Case WHen Isnull(J_2.WBName,'')<>'' THen J_2.WBName+'、' ELse '' End)+
                     (Case WHen Isnull(J_3.WBName,'')<>'' THen J_3.WBName+'、' ELse '' End)+
                     (Case WHen Isnull(J_4.WBName,'')<>'' THen J_4.WBName+'、' ELse '' End)
    from MPEHR.dbo.TBZ3_Xgjzhs A
         left join MPEHR.DBO.THzxxb B on A.brbh=B.brbh
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
         Left Join MPEHR.DBO.TWordBook D_1 On D_1.WBTypeCode='24027' And D_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.ryxj,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook D_2 On D_2.WBTypeCode='24027' And D_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.ryxj,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook D_3 On D_3.WBTypeCode='24027' And D_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.ryxj,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook D_4 On D_4.WBTypeCode='24027' And D_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.ryxj,'|') Where RowIndex=4)
         Left Join MPEHR.DBO.TWordBook E_1 On E_1.WBTypeCode='24028' And E_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sqyrjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook E_2 On E_2.WBTypeCode='24028' And E_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sqyrjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook E_3 On E_3.WBTypeCode='24028' And E_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sqyrjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook E_4 On E_4.WBTypeCode='24028' And E_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sqyrjkjy,'|') Where RowIndex=4)
         Left Join MPEHR.DBO.TWordBook F_1 On F_1.WBTypeCode='24029' And F_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6hnjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook F_2 On F_2.WBTypeCode='24029' And F_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6hnjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook F_3 On F_3.WBTypeCode='24029' And F_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6hnjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook F_4 On F_4.WBTypeCode='24029' And F_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6hnjkjy,'|') Where RowIndex=4)
         Left Join MPEHR.DBO.TWordBook F_5 On F_5.WBTypeCode='24029' And F_5.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6hnjkjy,'|') Where RowIndex=5)
         Left Join MPEHR.DBO.TWordBook G_1 On G_1.WBTypeCode='24030' And G_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12jkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook G_2 On G_2.WBTypeCode='24030' And G_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12jkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook G_3 On G_3.WBTypeCode='24030' And G_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12jkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook G_4 On G_4.WBTypeCode='24030' And G_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12jkjy,'|') Where RowIndex=4)
         Left Join MPEHR.DBO.TWordBook G_5 On G_5.WBTypeCode='24030' And G_5.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12jkjy,'|') Where RowIndex=5)
         Left Join MPEHR.DBO.TWordBook G_6 On G_6.WBTypeCode='24030' And G_6.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.sh6d12jkjy,'|') Where RowIndex=6)
         Left Join MPEHR.DBO.TWordBook H_1 On H_1.WBTypeCode='24031' And H_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyznjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook H_2 On H_2.WBTypeCode='24031' And H_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyznjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook H_3 On H_3.WBTypeCode='24031' And H_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyznjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook I_1 On I_1.WBTypeCode='24032' And I_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyzhjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook I_2 On I_2.WBTypeCode='24032' And I_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyzhjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook I_3 On I_3.WBTypeCode='24032' And I_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.shyzhjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook J_1 On J_1.WBTypeCode='24033' And J_1.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.cyqjkjy,'|') Where RowIndex=1)
         Left Join MPEHR.DBO.TWordBook J_2 On J_2.WBTypeCode='24033' And J_2.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.cyqjkjy,'|') Where RowIndex=2)
         Left Join MPEHR.DBO.TWordBook J_3 On J_3.WBTypeCode='24033' And J_3.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.cyqjkjy,'|') Where RowIndex=3)
         Left Join MPEHR.DBO.TWordBook J_4 On J_4.WBTypeCode='24033' And J_4.WBCode=(Select col From MPEHR.dbo.f_splitSTR(A.cyqjkjy,'|') Where RowIndex=4)        
   Where c.shzt=1

  --冠状动脉旁路移植术
  truncate table T_TBZ3_Gzdmplyzs
  Insert Into T_TBZ3_Gzdmplyzs(biyear,biquarter,bimonth,biweek,bidate,brbh,zyh,hzxm,zgys_id,bgys,ryrq,cyrq,zyts,ssrq,
                               zyzfy,yf,ssf,ksdm,ssssqdwxpgzfz,sqzbyy,jzsszz,CABGsssyz,xgqcl1,xgqcl2,xgqcl3,xgqcl4,xgqcl5,
                               xgqcl6,xgqcl7,xgqcl8,xgqcl9,yfxkjywxz,ssqpsj,szfpjssj,sqsysjkjywsj,szjyywyy,shjssysj,
                               sh3tzhjxsyyy,zsszz,sshbfz,ssqdjkjy,sshdjkjy,ssqkyhqk,sfzy21tcy,lyfs,zljg,hzdfwtypj_ktxzzysj,
                               hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,hzdfwtypj_ssmyd,hzdfwtypj_btjq,hzdfwtypj_kfzs,
                               bgsj,sjyytj)
  Select YEAR(bgsj),DATEPART(qq,bgsj),DATEPART(mm,bgsj),DATEPART(ww,bgsj),bgsj,
         a.brbh,zyh,hzxm,zgys_id,bgys,rydate,cydate,zyts,zssrq,B.zyzfy,b.yf,b.ssf,
         (Case When isnull(B.cyks_ID,'')='' Then '1314' Else B.cyks_id End) ksdm,
         ssssqdwxpgzfz,sqzbyy,jzsszz,CABGsssyz,xgqcl1,xgqcl2,xgqcl3,xgqcl4,xgqcl5,
         xgqcl6,xgqcl7,xgqcl8,xgqcl9,yfxkjywxz,ssqpsj,szfpjssj,sqsysjkjywsj,szjyywyy,shjssysj,
         sh3tzhjxsyyy,zsszz,sshbfz,ssqdjkjy,sshdjkjy,ssqkyhqk,sfzy21tcy,lyfs,zljg,hzdfwtypj_ktxzzysj,
         hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,hzdfwtypj_ssmyd,hzdfwtypj_btjq,hzdfwtypj_kfzs,
         bgsj,sysjkjywzltj sjyytj
    from MPEHR.dbo.TBZ3_Gzdmplyz A
         left join MPEHR.DBO.THzxxb B on A.brbh=B.brbh
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
   Where c.shzt=1

  --慢性阻塞性肺疾病
  Truncate Table T_TBZ3_mxzsxf
  Insert Into T_TBZ3_mxzsxf(biyear,biquarter,biweek,bimonth,bidate,brbh,zyh,hzxm,zgys,bgys,ryDate,cyDate,
                                zyts,zyfy,yf,zlfy,ksdm,COPDyzcd,ry24yhpg,sicufkzz,ylffyy,sxylhsffcdmxq,qzcopdjxjz,
                                wtljdbjwxys,ytljdbjwxys,zqgszj,tpzjs,xgnbq,wczytqyyzz,ycjxtqyyzz,
                                wczytqsysj,ycjxtqsysj,jkzd,lyfs,zljg,jshj,zdhjs,yyssd,yyhjfbcd,yyhsmyd,shzlgs,kfzsmyd)
  Select YEAR(a.bgsj)biyear,DATEPART(q,a.bgsj)biquarter,DATEPART(ww,a.bgsj)biweek,MONTH(a.bgsj)bimonth,a.bgsj,
         a.brbh,b.zyh,b.hzxm,b.zgys_ID,a.bgys,b.ryDate,b.cyDate,b.zyts,b.zyzfy,b.yf,a.zlfy,b.cyks_ID,COPDyzcd,
         ry24yhpg,sicufkzz,ylffyy,sxylhsffcdmxq,qzcopdjxjz,wtljdbjwxys,ytljdbjwxys,zqgszj,tpzjs,xgnbq,
         wczytqyyzz,ycjxtqyyzz,wczytqsysj,ycjxtqsysj,jkzd,lyfs,zljg,jshj,yjfy,qjmyd,hjfbd,hsmyd,gscd,kfzsmyd
    From MPEHR.dbo.TBZ3_mxzsxf a 
         left JOIN MPEHR.dbo.THzxxb b ON a.brbh=b.brbh 
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
   Where c.shzt=1
 
  --刨宫产
  Truncate Table T_TBZ3_Pgc
  Insert Into T_TBZ3_Pgc(biyear,biquarter,biweek,bimonth,bidate,brbh,zyh,hzxm,zgys,bgys,ryDate,cyDate,zyts,ssDate, 
	                     zyfy,yf,ssf,ksdm,pgcsspxpg,fhyxzz,yfjsyq,yyxkjyw,szzysssj,szzyzjyy,shjssysj,cs1fzpf,cs5fzpf,
	                     cs10fzpf,sh24xscxl,zcss,wxgbfz,tgchkfjkjy,shqkyhqk,lyfs,zljg,tftgfxpg,yfkglkbyw,csjscbcs,   
	                     shzdcs,bygrjbmcbm,jshj,zdhjs,yyssd,yyhjfbcd,yyhsmyd,shzlgs,kfzsmyd)
  Select YEAR(a.bgsj) biyear,DATEPART(q,a.bgsj) biquarter,DATEPART(ww,a.bgsj) biweek,MONTH(a.bgsj) bimonth,a.bgsj,
         a.brbh,b.zyh,b.hzxm,b.zgys_ID,a.bgys,b.ryDate,b.cyDate,b.zyts,a.ssrq,b.zyzfy,b.yf,b.ssf,b.cyks_ID,a.pgcsspxpg,
         a.fhyxzz,a.yfjsyq,yyxkjyw,szzysssj,szzyzjyy,shjssysj,cs1fzpf,cs5fzpf,cs10fzpf,sh24xscxl,zcss,wxgbfz,tgchkfjkjy,
         shqkyhqk,lyfs,zljg,tftgfxpg,yfkglkbyw,csjscbcs,shzdcs,bygrjbmcbm,jshj,zdhjs,yyssd,yyhjfbcd,yyhsmyd,shzlgs,kfzsmyd
    From MPEHR.dbo.TBZ3_Pgc a 
         Left JOIN MPEHR.dbo.THzxxb b ON a.brbh=b.brbh 
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
   Where c.shzt=1
 
  --围手术期预防感染
  Truncate Table T_TBZ3_Wssqyfgr
  Insert Into T_TBZ3_Wssqyfgr(biyear,biquarter,bimonth,biweek,bidate,zyh,hzxm,zgys,ryDate,cyDate,zyts,ssDate,zyfy,
                              yf,ssf,ksdm,brbh,sqyfxkjyw,sqkjywrtsj,ssyppzbfs,ssqkyhqk,sssj,szcxl,szzjyy,shjssysj,
                              bgys,ssqssj,sszzsj,ssmc,sh72xsjxsyyy,ylqksfyfxsykjyw,sfsxsyyedtbjs,yfxkjywssqyxsnsy,
                              sssjsfcg3xs,sssjcg3xsywzjyj,szcxlsfcg1500ml,szcxlcg1500mlywzjj,sfsbgr)	
  SELECT YEAR(a.bgsj) biyear,DATEPART(q,a.bgsj) biquarter,DATEPART(ww,a.bgsj) biweek,MONTH(a.bgsj) bimonth,a.bgsj,
	     b.zyh,b.hzxm,b.zgys_ID,b.ryDate,b.cyDate,b.zyts,b.zssrq,b.zyzfy,b.yf,b.ssf,b.cyKs_id,a.brbh,a.sqyfxkjyw,
	     a.sqkjywrtsj,a.ssyppzbfs,a.ssqkyhqk,a.sssj,a.szcxl,a.szzjyy,a.shjssysj,a.bgys,ssqssj,ssjssj,icd9bm,sh72xsjxsyyy,
         ylqksfyfxsykjyw=(Case When ssqkyhqk in ('A','B','C') and isnull(sqyfxkjyw,'')<>'' Then '是' Else '否' End),
         sfsxsyyedtbjs=(Case When sqyfxkjyw='D' Then '是' Else '否' End),
         yfxkjywssqyxsnsy=(Case When sqkjywrtsj in ('A','B') Then '是' Else '否' End),
         sssjsfcg3xs=(Case When datediff(n,ssqssj,ssjssj)>3 or sssj='B' Then '是' Else '否' End),
         sssjcg3xsywzjyj=(Case When (datediff(n,ssqssj,ssjssj)>3 or sssj='B') and szzjyy='B' Then '是' Else '否' End),
         szcxlsfcg1500ml=(Case When szcxl='B' Then '是' Else '否' End),
         szcxlcg1500mlywzjj=(Case When szcxl='B' and szzjyy='B' Then '是' Else '否' End),
         sfsbgr=(Case When ssqkyhqk='G' Then '是' Else '否' End)
    FROM MPEHR.dbo.TBZ3_Wssqyfgr a 
         Left JOIN MPEHR.dbo.THzxxb b ON a.brbh=b.brbh 
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
   Where c.shzt=1


  --围手术期预防深静脉血栓栓塞
  Truncate Table T_TBZ3_Wssqyfsjmxs
  Insert Into T_TBZ3_Wssqyfsjmxs(biyear,biquarter,bimonth,biweek,bidate,zyh,hzxm,zgys,ryDate,cyDate,gxbs,Bzlywxz,
                                 shrz6dxt,shr1tz6dxt,shr2tz6dxt,tnbs,jsmspf,fssdfxpg,jxyfyzsj,ywyfcsyzsj,shbfz,
                                 sh48xslgyy,lgdzmngr,ssqkqk,zyts,yf,ssf,ksdm,brbh,zyfy,lyfs,zljg,jshj,zdhjs,yyssd,
                                 yyhjfbcd,yyhsmyd,shzlgs,kfzsmyd,sjmslcknx,fxslcknx,jbyfcs,bgys)
  Select YEAR(a.bgsj) biyear,DATEPART(q,a.bgsj) biquarter,MONTH(a.bgsj) bimonth, DATEPART(ww,a.bgsj) biweek,a.bgsj, 
         b.zyh,b.hzxm,b.zgys_ID,b.ryDate,b.cyDate,a.gxbs,a.Bzlywxz,a.shrz6dxt,a.shr1tz6dxt,a.shr2tz6dxt,a.tnbs,a.welszpf,
         a.pewelszpf,a.DVTyyzxdsj,ywDVTyzxdsj,a.shbfz,a.sh48xslgyy,a.lgdzmngr,a.ssqkqk,b.zyts,b.yf,b.ssf,b.cyks_ID,
         a.brbh,b.zyzfy,a.lyfs,a.jshj,a.zdhjs,a.yyssd,a.yyhjfbcd,a.yyhsmyd,a.shzlgs,a.shzlgs,a.kfzsmyd,a.jmxslcknx,
         a.fxslcknx,a.jbyfcs,a.bgys
    From MPEHR.dbo.TBZ3_Wssqyfsjmxs a 
         Left JOIN MPEHR.dbo.THzxxb b ON a.brbh=b.brbh 
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
   Where c.shzt=1   

  --急性心肌梗死 Select * From T_TBZ3_Jxxjgs
  truncate table T_TBZ3_Jxxjgs
  Insert Into T_TBZ3_Jxxjgs(biyear,biquarter,bimonth,biweek,bidate,brbh,zyh,hzxm,zgys,rysj,cysj,zyts,ssrq,zyzfy,yf,ssf,
                            ksdm,ddjzksj,scxdtsj,scxzbzwjcsj,STEMILBBBsj,sjasplsj,sysjlcglsj,aspljjz,zssxfs,GRACEwxpffz,
                            TIMIwxpffz,dy90fz_zjPCIkssj,zyqjyyqk_asplcqyz,zyzzysj,ddyys_kssystzzjsj,dy30fz_zshszrxykssj,
                            zyqjyyqk_lcglcqyz,zyqjyyqk_stzzjcqyz,zyqjyyqk_xgjzszhcqyz,zyqjyyqk_tdlywcqyz,cysjxsy_aspl,
                            cysjxsy_stzzj,cysjxsy_lcgl,cysjxsy_ACEIARB,cysjxsy_tdlyw,jkjy_ssjyydlys,kjy_gxytnbgxz,
                            hzdfwtypj_ktxzzysj,hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,hzdfwtypj_ssmyd,hzdfwtypj_btjq,
                            hzdfwtypj_kfzs,bgys,jkjy_gxbejfy,zljg,lyfs,
                            bgsj,zyzd,xxpsj,cdfapjsj,zsszmqnj,zssbl,sflyyzrssj30,pcizlwcsj,sflyyzpcisj90,PCIyyyy,xysspcihzyy,
                            ejyfafa,ejyfbfa,ejyfcfa,ejyfdfa,ejyfefa)
  Select YEAR(bgsj),DATEPART(qq,bgsj),DATEPART(mm,bgsj),DATEPART(ww,bgsj),bgsj,
         a.brbh,zyh,hzxm,zgys_id,rydate,cydate,b.zyts,zssrq,b.zyzfy,b.yf,ssf,
         (Case When isnull(B.cyks_ID,'')='' Then '1314' Else b.cyks_id End) ksdm,
         ddjzksj,scxdtsj,scxzbzwjcsj,STEMILBBBsj,sjasplsj,sysjlcglsj,aspljjz,zssxfs,GRACEwxpffz,
         TIMIwxpffz,dy90fz_zjPCIkssj,zyqjyyqk_asplcqyz,zyzzysj,ddyys_kssystzzjsj,dy30fz_zshszrxykssj,
         zyqjyyqk_lcglcqyz,zyqjyyqk_stzzjcqyz,zyqjyyqk_xgjzszhcqyz,zyqjyyqk_tdlywcqyz,cysjxsy_aspl,
         cysjxsy_stzzj,cysjxsy_lcgl,cysjxsy_ACEIARB,cysjxsy_tdlyw,jkjy_ssjyydlys,jkjy_gxytnbgxz,
         hzdfwtypj_ktxzzysj,hzdfwtypj_zlfa,hzdfwtypj_cdqj,hzdfwtypj_shhj,hzdfwtypj_ssmyd,hzdfwtypj_btjq,
         hzdfwtypj_kfzs,bgys,jkjy_gxbejfy,zljg,lyfs,
         bgsj,zyzdICD10bmmc zyzd,Xxpjcsj xxpsj,csxdtjcsj cdfapjsj,zsszmqnj zsszmqnj,zssbl,
         (case when dy30fz_jmzrxywzssj>30 then '是' else '否' end) sflyyzrssj30,dy90fz_zjPCIjssj pcizlwcsj,
         (case when DATEDIFF(N,ddjzksj,dy90fz_zjPCIkssj)>90 then '是' else '否' end) sflyyzpcisj90,
         yyzsyy PCIyyyy,hzzsyy xysspcihzyy, 
         ejyfafa=(Case When jkjy_gxbejfy like '%A%' Then D_1.WBName Else '' ENd )+'、'+
                 (Case When jkjy_gxbejfy like '%B%' Then D_2.WBName Else '' ENd )+'、',
         ejyfbfa=(Case When jkjy_gxbejfy like '%C%' Then D_3.WBName Else '' ENd )+'、'+
                 (Case When jkjy_gxbejfy like '%D%' Then D_4.WBName Else '' ENd )+'、',
         ejyfcfa=(Case When jkjy_gxbejfy like '%E%' Then D_5.WBName Else '' ENd )+'、'+
                 (Case When jkjy_gxbejfy like '%F%' Then D_6.WBName Else '' ENd )+'、',
         ejyfdfa=(Case When jkjy_gxbejfy like '%G%' Then D_7.WBName Else '' ENd )+'、'+
                 (Case When jkjy_gxbejfy like '%H%' Then D_8.WBName Else '' ENd )+'、',
         ejyfefa=(Case When jkjy_gxbejfy like '%I%' Then D_9.WBName Else '' ENd )+'、'+
                 (Case When jkjy_gxbejfy like '%J%' Then D_10.WBName Else '' ENd )+'、'
    from MPEHR.dbo.TBZ3_Jxxjgs A
         left join MPEHR.DBO.THzxxb B on A.brbh=B.brbh
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
         Left Join MPEHR.DBO.TWordBook D_1 On D_1.WBTypeCode='20048' And D_1.WBCode='A'
         Left Join MPEHR.DBO.TWordBook D_2 On D_2.WBTypeCode='20048' And D_2.WBCode='B'
         Left Join MPEHR.DBO.TWordBook D_3 On D_3.WBTypeCode='20048' And D_3.WBCode='C'
         Left Join MPEHR.DBO.TWordBook D_4 On D_4.WBTypeCode='20048' And D_4.WBCode='D'
         Left Join MPEHR.DBO.TWordBook D_5 On D_5.WBTypeCode='20048' And D_5.WBCode='E'
         Left Join MPEHR.DBO.TWordBook D_6 On D_6.WBTypeCode='20048' And D_6.WBCode='F'
         Left Join MPEHR.DBO.TWordBook D_7 On D_7.WBTypeCode='20048' And D_7.WBCode='G'
         Left Join MPEHR.DBO.TWordBook D_8 On D_8.WBTypeCode='20048' And D_8.WBCode='H'
         Left Join MPEHR.DBO.TWordBook D_9 On D_9.WBTypeCode='20048' And D_9.WBCode='I'
         Left Join MPEHR.DBO.TWordBook D_10 On D_10.WBTypeCode='20048' And D_10.WBCode='J'
   Where c.shzt=1
--Select * from MPEHR.dbo.TWordBookType where WBGroupName like '%单病种质量控制3.0_急性心肌梗死%'
--  Select * from MPEHR.dbo.TWordBook where WBTypeCode='20048'
  --儿童住院社区获得性肺炎提取数据
  truncate table T_TBZ3_Etzysqhdxfy
  Insert Into T_TBZ3_Etzysqhdxfy(biyear,biquarter,bimonth,biweek,bidate,brbh,zyh,hzxm,zgys,bgys,rysj,
                                 cysj,zyts,zssrq,zyzfy,yf,ssf,ksdm,fkrytj,rICUbz,jzhscdmxqfxsj,jzhrscjcsj,
                                 xpybb,hrsjkjywsj,ddjzsj,ICUkjywxz,qskjywxz,kwswqms,kwswtbjs,kwswdhnz,
                                 kwswqt,cfbyxjcxm,pgjl,hjtjbbd,mpkt,zskjywlc,kfkjywlc,fkcybz,lyfs,zljg,hryzcdpg,
                                 bgsj,sykjyzltj,kjywlcts)
  Select YEAR(bgsj),DATEPART(qq,bgsj),DATEPART(mm,bgsj),DATEPART(ww,bgsj),bgsj,
         A.brbh,zyh,hzxm,zgys_id,bgys,ryDate rysj,cyDate cysj,zyts,zssrq,zyzfy,yf,ssf,
         (Case When isnull(B.cyks_ID,'')='' Then '1314' Else b.cyks_id End) ksdm,fkrytj,rICUbz,jzhscdmxqfxsj,
         jzhrscjcsj,xpybb,hrsjkjywsj,ddjzsj,ICUkjywxz,qskjywxz,kwswqms,kwswtbjs,kwswdhnz,kwswqt,
         cfbyxjcxm,pgjl,hjtjbbd,mpkt,zskjywlc,kfkjywlc,fkcybz,lyfs,zljg,hryzcdpg,bgsj,sjkjywzltj,
         kjywlcts=(Case When datediff(dd,hrsjkjywsj,tykjywsj)>0 THen datediff(dd,hrsjkjywsj,tykjywsj) Else zskjywlc ENd)
    From MPEHR.dbo.TBZ3_Sqhdxfy_ET A
         left join MPEHR.DBO.THzxxb B on A.brbh=B.brbh
         Left Join MPEHR.dbo.T_Shyj C on A.GID=C.GID
   Where c.shzt=1


  --单病种维表数据抽取
  ---------------------------围手术其预防感染
  --手术名称 
  Truncate Table W_WSS_SSMC
  Insert Into W_WSS_SSMC(dm,mc)
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25005'
  --术后结束使用时间
  Truncate Table W_SHJSSYSJ
  Insert Into W_SHJSSYSJ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25015'
  --术后72小时之后继续使用原因
  Truncate Table W_SHJXSYYY
  Insert Into W_SHJXSYYY
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25016'
  --手术野皮肤准备方式
  Truncate Table W_SSBPFS
  Insert Into W_SSBPFS
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25017'
  --手术切口愈合情况
  Truncate Table W_SSQKYHQK
  Insert Into W_SSQKYHQK
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25018'
  -------------------------脑梗死
  --第一诊断
  Truncate Table W_NGS_DYZD
  Insert Into W_NGS_DYZD
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25088'
  --绿色通道
  Truncate Table W_NGS_LSTD
  Insert Into W_NGS_LSTD
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25091'
  --溶栓药选择
  Truncate Table W_NGS_RXYWXZ
  Insert Into W_NGS_RXYWXZ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25096'
  --溶栓途径
  Truncate Table W_NGS_RXTJ
  Insert Into W_NGS_RXTJ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25097'
  --将血小板凝聚治疗药物选择
  Truncate Table W_NGS_KXXBJJZLYWXZ
  Insert Into W_NGS_KXXBJJZLYWXZ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25108'
  --给予抗血小板聚集药物治疗时间
  Truncate Table W_NGS_JYKXXBZLSJ
  Insert Into W_NGS_JYKXXBZLSJ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25107'
  --给予吞咽困难评价时机
  Truncate Table W_NGS_JYTYKN
  Insert Into W_NGS_JYTYKN
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25117'
  --康复评价与实施时间
  Truncate Table W_NGS_KFPJYSSSJ
  Insert Into W_NGS_KFPJYSSSJ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25146'
  --未能进行吞咽困难评价原因
  Truncate Table W_NGS_WJXTYKNYY
  Insert Into W_NGS_WJXTYKNYY
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25119'
  --未能进行康复原因
  Truncate Table W_NGS_WNJXKFYY
  Insert Into W_NGS_WNJXKFYY
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25147'
  --入院前在用抗凝药物选择
  Truncate Table W_NGS_RYQKNYWXZ
  Insert Into W_NGS_RYQKNYWXZ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25122'
  --住院期间用抗凝药物选择
  Truncate Table W_NGS_ZYQJKNYWXZ
  Insert Into W_NGS_ZYQJKNYWXZ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25122'
  --出院后在用抗凝药物选择
  Truncate Table W_NGS_CYSKNYWXZ
  Insert Into W_NGS_CYSKNYWXZ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25122'
  --是否选项
  Truncate Table W_NGS_ISSF
  Insert Into W_NGS_ISSF
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25102'
  --血脂评估时间
  Truncate Table W_NGS_XZPGSJ
  Insert Into W_NGS_XZPGSJ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25109'
  --评价血脂结果
  Truncate Table W_NGS_PJXZJG
  Insert Into W_NGS_PJXZJG
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25111'
  --血管功能评价时间
  Truncate Table W_NGS_XGGNPJSJ
  Insert Into W_NGS_XGGNPJSJ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25135'
  --血管功能评价方法
  Truncate Table W_NGS_XGGNPJFF
  Insert Into W_NGS_XGGNPJFF
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25136'
  --预防DVT治疗时间
  Truncate Table W_NGS_YFDVTZLSJ
  Insert Into W_NGS_YFDVTZLSJ
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25121'
  --康复治疗适宜性评估结果
  Truncate Table W_NGS_KFZLSYXPJJG
  Insert Into W_NGS_KFZLSYXPJJG
  Select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25144'
--------------------------------心力衰竭
  --killip分级
  truncate table W_killip
  insert into W_killip(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='21010'
  --ACEI/ARB
  truncate table W_ACEIARB
  insert into W_ACEIARB(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='21013'
  --β受体阻滞剂首剂治疗时间
  truncate table W_pstzzjsjzlsj
  insert into W_pstzzjsjzlsj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='21014'
  --醛固酮拮抗剂(重度心衰)首剂治疗时间
  truncate table W_qgtjkj
  insert into W_qgtjkj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='21021'
  --为患者提供心力衰竭(HF)健康教育入院评估内容
  truncate table W_jkjyrypg
  insert into W_jkjyrypg(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='21025'

  --健康教育住院期间控制危险因素及诱发因素的宣教实施有记录
  truncate table W_jkjyxjss
  insert into W_jkjyxjss(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='21026'
  --健康教育住院期间非药物治疗前后指导实施
  truncate table W_jkjyfywzlzd
  insert into W_jkjyfywzlzd(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='21027'
  --健康教育出院指导实施
  truncate table W_jkjycyzdss
  insert into W_jkjycyzdss(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='21028'
  
----------------------------------------急性心肌梗死

  --急性心肌梗死诊断
  truncate table W_jxsjgszd
  insert into W_jxsjgszd(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='20011'
  --需要实施PCI无条件实施时医院原因
  truncate table W_PCIYY
  insert into W_PCIYY(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='20038'
  --需要实施PCI无条件实施时患者原因
  truncate table W_PCIhz
  insert into W_PCIhz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='20039'
-----------------------------------------冠状动脉旁路移植术
  --CABG手术适应证
  truncate table W_CABGsssyz
  insert into W_CABGsssyz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='32011'
  --急症手术指征
  truncate table W_jzsszz
  insert into W_jzsszz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='32012'
  
  --抗菌药物选择
  truncate table W_kjywxz
  insert into W_kjywxz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='32024'
  
  --首剂用药途径
  truncate table W_sjkjyytj
  insert into W_sjkjyytj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='32025' 
  --术中加用药物原因
  truncate table W_szjyywyy
  insert into W_szjyywyy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='32026' 
  
  --术后停止使用时间
  truncate table W_shtzsysjyy
  insert into W_shtzsysjyy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='32027'  
  
  --术后3D之后继续使用的原因
  truncate table W_sh3djxsy
  insert into W_sh3djxsy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='32028'  
  
  --手术前的健康教育
  truncate table W_ssqjkjy
  insert into W_ssqjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='32037'  
  --手术后的健康教育
  truncate table W_sshjkjy
  insert into W_sshjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='32038'  
  --冠状动脉移植术_手术切口愈合情况
  truncate table W_gzyzs_ssqkyh
  insert into W_gzyzs_ssqkyh(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='32039'  
  
-----------------------------------------髋关节置换术
  --髋关节置换术_预防性抗菌药物选择
  truncate table W_kgjyfkjywxz
  insert into W_kgjyfkjywxz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23013'  
  --髋关节置换术_术中加用药
  truncate table W_kgjszjyy
  insert into W_kgjszjyy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23015'  
  --髋关节置换术_术后结束使用时间
  truncate table W_kgjshjssysj
  insert into W_kgjshjssysj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23016'  
  --髋关节置换术_术后三天继续使用原因
  truncate table W_kgjshstjxsyyy
  insert into W_kgjshstjxsyyy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23017'  
  --髋关节_输血类别
  truncate table W_kgjsxlb
  insert into W_kgjsxlb(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23021'  
  
  --髋关节_手术后康复方式
  truncate table W_kgjsshkffs
  insert into W_kgjsshkffs(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23023'  
  --髋关节_手术后并发症
  truncate table W_kgjsshbfz
  insert into W_kgjsshbfz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23026'  
  --髋关节_影响程度
  truncate table W_kgjyxcd
  insert into W_kgjyxcd(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23025'  
  --髋关节_入院宣教
  truncate table W_kgjryxj
  insert into W_kgjryxj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23027'  
  --髋关节_术前一日健康教育
  truncate table W_kgjsqyrjkjy
  insert into W_kgjsqyrjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23028'  
  --髋关节_术后6h内健康教育
  truncate table W_kgjsh6hjkjy
  insert into W_kgjsh6hjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23029'  
  --髋关节_术后6～12h健康教育
  truncate table W_kgjsh6z12jkjy
  insert into W_kgjsh6z12jkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23030'  
  --髋关节_术后一周内健康教育
  truncate table W_kgjshyzjkjy
  insert into W_kgjshyzjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23031'  
  --髋关节_术后一周后健康教育
  truncate table W_kgjshyzjkjy
  insert into W_kgjshyzjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23032'  
  --髋关节_出院前健康教育
  truncate table W_kgjcyqjkjy
  insert into W_kgjcyqjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23033'  
  --髋关节_切口愈合等级
  truncate table W_kgjqkyhdj
  insert into W_kgjqkyhdj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23034'  
  --髋膝关节_手术方式
  truncate table W_KXGJ_SSFS
  insert into W_KXGJ_SSFS(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='23010'  

 
-----------------------------------------膝关节置换术
  --膝关节置换术_预防性抗菌药物选择
  truncate table W_xgjyfkjywxz
  insert into W_xgjyfkjywxz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24013'  
  --膝关节置换术_术中加用药
  truncate table W_xgjszjyy
  insert into W_xgjszjyy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24015'  
  --膝关节置换术_术后结束使用时间
  truncate table W_xgjshjssj
  insert into W_xgjshjssj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24016'  
  --膝关节置换术_术后三天继续使用原因
  truncate table W_xgjzhsshstjxsy
  insert into W_xgjzhsshstjxsy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24017'  
  --膝关节_输血类别
  truncate table W_xgjsxlb
  insert into W_xgjsxlb(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24021'  
  --膝关节置换术_术后康复方式
  truncate table W_xgjshkffs
  insert into W_xgjshkffs(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24023'  
  --膝关节置换术_术后并发症
  truncate table W_xgjshbfz
  insert into W_xgjshbfz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24025'  
  --膝关节置换术_影响程度
  truncate table W_xgjyxcd
  insert into W_xgjyxcd(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24026'  
  --膝关节置换术_入院宣教
  truncate table W_xgjryxj
  insert into W_xgjryxj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24027'  
  --膝关节置换术_术前一日的健康教育
  truncate table W_xgjsqyrjkjy
  insert into W_xgjsqyrjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24028'  
  --膝关节置换术_术后6h的健康教育
  truncate table W_xgjsh6hjkjy
  insert into W_xgjsh6hjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24029'  
  --膝关节置换术_术后6到12h的健康教育
  truncate table W_xgjsh6z12jkjy
  insert into W_xgjsh6z12jkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24030'  
  --膝关节置换术_术后一周内的健康教育
  truncate table W_xgjshyznjkjy
  insert into W_xgjshyznjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24031'  
  --膝关节置换术_术后一周后的健康教育
  truncate table W_xgjshyzhjkjy
  insert into W_xgjshyzhjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24032'  
  --膝关节置换术_出院前的健康教育
  truncate table W_xgjcyqjkjy
  insert into W_xgjcyqjkjy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24033'  
  --膝关节置换术_切口愈合情况
  truncate table W_xgjqkyhqk
  insert into W_xgjqkyhqk(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='24034'  
------------------------------------------社区获得性肺炎
  --社区获得性肺炎_重症肺炎诊断标准
  truncate table W_sqhdxfyzzfyzdbz
  insert into W_sqhdxfyzzfyzdbz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22005'  
  --社区获得性肺炎_入ICU标准
  truncate table W_sxhdxfyricubz
  insert into W_sxhdxfyricubz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22006'  
  --社区获得性肺炎_无铜绿假单胞菌感染危险因素
  truncate table W_sqhdxfywtljdbjgrwxys
  insert into W_sqhdxfywtljdbjgrwxys(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22014'  
  --社区获得性肺炎_有铜绿假单胞菌感染危险因素
  truncate table W_sqhdxfyytljdbjgr
  insert into W_sqhdxfyytljdbjgr(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22015'  
  --社区获得性肺炎_青壮年或无基础疾病患者
  truncate table W_sxhdxfyqznwjc
  insert into W_sxhdxfyqznwjc(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22016'  
  --社区获得性肺炎_老年人或有基础疾病患者
  truncate table W_sxhdxfylnryjc
  insert into W_sxhdxfylnryjc(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22017'  
  --社区获得性肺炎_需入院治疗但不必收住ICU的患者
  truncate table W_sqhdxfyxrybbicu
  insert into W_sqhdxfyxrybbicu(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22018'  
  --社区获得性肺炎_肺炎链球菌
  truncate table W_sqhdxfyfylqj
  insert into W_sqhdxfyfylqj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22019'  
  --社区获得性肺炎_流感嗜血杆菌卡他莫拉菌
  truncate table W_sqhdxfylgsxgj
  insert into W_sqhdxfylgsxgj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22020'  
  --社区获得性肺炎_甲氧西林敏感金黄色葡萄球菌
  truncate table W_sqhdxfyjyxlptqj
  insert into W_sqhdxfyjyxlptqj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22021'  
  --社区获得性肺炎_甲氧西林耐药金黄色葡萄球菌
  truncate table W_sxhdxfyjyxlny
  insert into W_sxhdxfyjyxlny(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22022'  
  --社区获得性肺炎_肠杆菌科细菌不产生ESBLs菌
  truncate table W_sqhdxfycgjkbcs
  insert into W_sqhdxfycgjkbcs(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22023'  
  --社区获得性肺炎_肠杆菌科细菌产ESBLs菌
  truncate table W_sqhdxfycgkxjcs
  insert into W_sqhdxfycgkxjcs(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22024'  
  --社区获得性肺炎_肠杆菌科细菌产AmpC酶菌
  truncate table W_sqhdxfycgkxjcmj
  insert into W_sqhdxfycgkxjcmj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22025'  
  --社区获得性肺炎_铜绿假单胞菌轻度者
  truncate table W_sqhdxfytljdbjqdz
  insert into W_sqhdxfytljdbjqdz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22026'  
  --社区获得性肺炎_铜绿假单胞菌
  truncate table W_sqhdxfytljdbj
  insert into W_sqhdxfytljdbj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22027'  
  --社区获得性肺炎_B族链球菌
  truncate table W_sqhdxfybzlqj
  insert into W_sqhdxfybzlqj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22028'  
  --社区获得性肺炎_厌氧菌
  truncate table W_sqhdxfyyyj
  insert into W_sqhdxfyyyj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22029'  
  --社区获得性肺炎_单核细胞增多性李斯特菌
  truncate table W_sqhdxfydhxblstj
  insert into W_sqhdxfydhxblstj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22030'  
  --社区获得性肺炎_嗜肺军团菌
  truncate table W_sqhdxfysfjtj
  insert into W_sqhdxfysfjtj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22031' 
  --社区获得性肺炎_百日咳杆菌/肺炎支原体/衣原体
  truncate table W_sqhdxfybrkgjfybyt
  insert into W_sqhdxfybrkgjfybyt(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='22032' 
-----------------------------------------小儿肺炎
  --小儿肺炎_符合入院条件
  truncate table W_xrfyfhrytj
  insert into W_xrfyfhrytj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25062' 
  --小儿肺炎_入ICU标准
  truncate table W_xrfyricubz
  insert into W_xrfyricubz(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25063' 
  --小儿肺炎_首剂抗菌药物治疗前采集痰血培养
  truncate table W_sefysjkjywzlcjxpy
  insert into W_sefysjkjywzlcjxpy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25064' 
  --小儿肺炎_使用首剂抗菌药物治疗途径
  truncate table W_srfysykjyzltj
  insert into W_srfysykjyzltj(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25068' 
  --小儿肺炎_重症/ICU患儿起始抗菌药物选择
  truncate table W_srfyzzhzkjyw
  insert into W_srfyzzhzkjyw(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25069' 
  --小儿肺炎_非重症患儿起始抗菌药物选择
  truncate table W_srfyfzzkjyw
  insert into W_srfyfzzkjyw(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25070' 
  --小儿肺炎_评估结论
  truncate table W_srfypgjl
  insert into W_srfypgjl(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25076' 
  --小儿肺炎_重复病原学检查
  truncate table W_srfycfbyxjc
  insert into W_srfycfbyxjc(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25077' 
  --小儿肺炎_符合出院标准及时出院
  truncate table W_sefyfhcybzjscy
  insert into W_sefyfhcybzjscy(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25079' 
  --小儿肺炎_诊疗结果
  truncate table W_xefyzljg
  insert into W_xefyzljg(dm,mc)
  select WBCode,WBName from MPEHR.dbo.TWordBook where WBTypeCode='25081' 
End
 

/*
exec P_InsDBZ3Data


*/
