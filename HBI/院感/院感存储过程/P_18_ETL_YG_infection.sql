USE [HBIDATA]
GO
/****** Object:  StoredProcedure [dbo].[P_18_ETL_YG_infection]    Script Date: 08/18/2016 14:46:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<wgf>
-- Create date: <20160115>
-- Description:	<院感数据抽取>
-- =============================================
ALTER  PROCEDURE [dbo].[P_18_ETL_YG_infection]
    @StartDate DATETIME ,
    @EndDate DATETIME
AS 
    BEGIN
    
-- P_18_ETL_YG_infection '2003-1-01','2016-12-31'

        --DELETE  [GR_infection]
        --WHERE   CONVERT(DATE, [CONFIRMED_TIME]) BETWEEN @StartDate
        --                                   AND     @EndDate

TRUNCATE TABLE [GR_infection]

        INSERT  INTO [GR_infection]
                ( [RID] ,
                  [CASEID] ,
                  [INFECTED_TIME] ,
                  [INFECTED_DEPT] ,
                  [INFECTED_PART] ,
                  [ISNOSOCOMIAL] ,
                  [DOCTOR] ,
                  [CONFIRMER] ,
                  [CONFIRMED_TIME] ,
                  [RELATIONSHIP] ,
                  [BACTERIA] ,
                  [OUTCOM] ,
                  [OUTCOM_TIME] ,
                  [OUTCOM_REPORTER] ,
                  [OUTCOM_REPORT_TIME] ,
                  [STATE] ,
                  [INTERVENTIONID] ,
                  [IS_SEND] ,
                  [GENERATETIME] ,
                  [STYPE] ,
                  [OUTSIDE] ,
                  [BEGINTIME] ,
                  [ENDTIME] ,
                  [DAYS] ,
                  [TIMES] ,
                  [DANGEROUS] ,
                  [DANGEROUS_BEFORE] ,
                  [DANGEROUS_AFTER] ,
                  [FEVER_DAYS] ,
                  [ROUTINE_SEND] ,
                  [ROUTINE_HIGH] ,
                  [SPECIMEN] ,
                  [DRUG_RESISTANT] ,
                  [REASON] ,
                  [NOTE] ,
                  [INFECTED_ICD] ,
                  [LASTMODIFYTIME] ,
                  [GROUPID] ,
                  [FOCUS] ,
                  [REPORT_DOCTOR] ,
                  [REPORT_TIME] ,
                  [REPORT_CONTENT]
                )
                SELECT  [RID] ,
                        [CASEID] ,
                        [INFECTED_TIME] ,
                        [INFECTED_DEPT] ,
                        [INFECTED_PART] ,
                        [ISNOSOCOMIAL] ,
                        [DOCTOR] ,
                        [CONFIRMER] ,
                        [CONFIRMED_TIME] ,
                        [RELATIONSHIP] ,
                        [BACTERIA] ,
                        [OUTCOM] ,
                        [OUTCOM_TIME] ,
                        [OUTCOM_REPORTER] ,
                        [OUTCOM_REPORT_TIME] ,
                        [STATE] ,
                        [INTERVENTIONID] ,
                        [IS_SEND] ,
                        [GENERATETIME] ,
                        [STYPE] ,
                        [OUTSIDE] ,
                        [BEGINTIME] ,
                        [ENDTIME] ,
                        [DAYS] ,
                        [TIMES] ,
                        [DANGEROUS] ,
                        [DANGEROUS_BEFORE] ,
                        [DANGEROUS_AFTER] ,
                        [FEVER_DAYS] ,
                        [ROUTINE_SEND] ,
                        [ROUTINE_HIGH] ,
                        [SPECIMEN] ,
                        [DRUG_RESISTANT] ,
                        [REASON] ,
                        [NOTE] ,
                        [INFECTED_ICD] ,
                        [LASTMODIFYTIME] ,
                        [GROUPID] ,
                        [FOCUS] ,
                        [REPORT_DOCTOR] ,
                        [REPORT_TIME] ,
                        [REPORT_CONTENT]
                FROM    OPENQUERY(NIS, ' SELECT * from infection')
                --WHERE   CONVERT(DATE, [CONFIRMED_TIME]) BETWEEN @StartDate
                                           --AND     @EndDate


                  

    END

--select COUNT(*) from [GR_infection]