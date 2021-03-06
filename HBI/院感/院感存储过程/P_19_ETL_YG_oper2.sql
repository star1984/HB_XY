USE [HBIDATA]
GO
/****** Object:  StoredProcedure [dbo].[P_19_ETL_YG_oper2]    Script Date: 08/18/2016 14:46:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<wgf>
-- Create date: <20160115>
-- Description:	<院感数据抽取>
-- =============================================
ALTER  PROCEDURE [dbo].[P_19_ETL_YG_oper2]
    @StartDate DATETIME ,
    @EndDate DATETIME
AS 
    BEGIN
    
-- P_19_ETL_YG_oper2 '2003-1-01','2016-12-31'

        --DELETE  [GR_oper2]
        --WHERE   CONVERT(DATE, [ENDTIME]) BETWEEN @StartDate
        --                                 AND     @EndDate

TRUNCATE TABLE [GR_oper2]

        INSERT  INTO [GR_oper2]
                ( [CASEID] ,
                  [OPERID] ,
                  [OPER_NAME] ,
                  [OPER_CATE] ,
                  [OPER_CODE] ,
                  [OPER_DIAGNOSIS] ,
                  [SURGEON] ,
                  [FIRSTAS] ,
                  [ASA_DOCTOR] ,
                  [ASA_METHOD] ,
                  [BEGINTIME] ,
                  [ENDTIME] ,
                  [HOURS] ,
                  [ASA] ,
                  [WOUND_GRADE] ,
                  [HEAL] ,
                  [LOCATION] ,
                  [NNIS] ,
                  [OPER_TYPE] ,
                  [CONSECUTIVE] ,
                  [EMBED] ,
                  [ENDOSCOPIC] ,
                  [BLOOD_OUT] ,
                  [BLOOD_IN] ,
                  [ANTI_B] ,
                  [ANTI_B_HOURS] ,
                  [ANTI_B2] ,
                  [ANTI_I] ,
                  [ANTI_A] ,
                  [ANTI_A24] ,
                  [ANTI_A48] ,
                  [INFGROUPID] ,
                  [OPER_ROOM] ,
                  [DEPT] ,
                  [RESERVE1] ,
                  [EDITOR] ,
                  [EDITTIME] ,
                  [SYNTIME] ,
                  [LASTMODIFYTIME] ,
                  [OPER_INDEX] ,
                  [PREDISPOSING_FACTOR]
                )
                SELECT  [CASEID] ,
                        [OPERID] ,
                        [OPER_NAME] ,
                        [OPER_CATE] ,
                        [OPER_CODE] ,
                        [OPER_DIAGNOSIS] ,
                        [SURGEON] ,
                        [FIRSTAS] ,
                        [ASA_DOCTOR] ,
                        [ASA_METHOD] ,
                        [BEGINTIME] ,
                        [ENDTIME] ,
                        [HOURS] ,
                        [ASA] ,
                        [WOUND_GRADE] ,
                        [HEAL] ,
                        [LOCATION] ,
                        [NNIS] ,
                        [OPER_TYPE] ,
                        [CONSECUTIVE] ,
                        [EMBED] ,
                        [ENDOSCOPIC] ,
                        [BLOOD_OUT] ,
                        [BLOOD_IN] ,
                        [ANTI_B] ,
                        [ANTI_B_HOURS] ,
                        [ANTI_B2] ,
                        [ANTI_I] ,
                        [ANTI_A] ,
                        [ANTI_A24] ,
                        [ANTI_A48] ,
                        [INFGROUPID] ,
                        [OPER_ROOM] ,
                        [DEPT] ,
                        [RESERVE1] ,
                        [EDITOR] ,
                        [EDITTIME] ,
                        [SYNTIME] ,
                        [LASTMODIFYTIME] ,
                        [OPER_INDEX] ,
                        [PREDISPOSING_FACTOR]
                FROM    OPENQUERY(NIS, ' SELECT * from oper2')
                --WHERE   CONVERT(DATE, [ENDTIME]) BETWEEN @StartDate
                --                                 AND     @EndDate
                  

    END

