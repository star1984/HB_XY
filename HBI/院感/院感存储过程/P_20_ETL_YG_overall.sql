USE [HBIDATA]
GO
/****** Object:  StoredProcedure [dbo].[P_20_ETL_YG_overall]    Script Date: 08/18/2016 14:47:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<wgf>
-- Create date: <20160115>
-- Description:	<院感数据抽取>
-- =============================================
ALTER  PROCEDURE [dbo].[P_20_ETL_YG_overall]
    @StartDate DATETIME ,
    @EndDate DATETIME
AS 
    BEGIN
    
-- P_20_ETL_YG_overall '2003-1-01','2016-12-31'

        --DELETE  [GR_overall]
        --WHERE   CONVERT(DATE, [OUT_TIME]) BETWEEN @StartDate
        --                                     AND     @EndDate

TRUNCATE TABLE [GR_overall]

        INSERT  INTO [GR_overall]
                ( [CASEID] ,
                  [PATIENTID] ,
                  [PNAME] ,
                  [PSEX] ,
                  [PBIRTHDATE] ,
                  [PMARRIAGE] ,
                  [IN_TIME] ,
                  [IN_DEPT] ,
                  [OUT_TIME] ,
                  [OUT_DEPT] ,
                  [OUT_WAY] ,
                  [NOW_DEPT] ,
                  [NOW_TIME] ,
                  [ROOMNO] ,
                  [BEDNO] ,
                  [IN_OR_OUT] ,
                  [WEIGHT] ,
                  [TOTAL_COST] ,
                  [DRUG_COST] ,
                  [ANTIBIOTIC_COST] ,
                  [ADMISSION_DIAGNOSIS] ,
                  [INSTATE] ,
                  [CARE_LEVEL] ,
                  [DISCHARGED_DIAGNOSIS] ,
                  [SELF_REPORT] ,
                  [ATTENTION_STATE] ,
                  [INTERVENTION_STATE] ,
                  [INFECTED_STATE] ,
                  [INFECTED_TIME] ,
                  [INFECTED_PART] ,
                  [INFECT_UNIT] ,
                  [OUTCOM] ,
                  [CONSULTING_DOCTOR] ,
                  [DOCTOR_IN_CHARGE] ,
                  [ATTENDING_DOCTOR] ,
                  [DIRECTOR] ,
                  [OPEATOR] ,
                  [IDENTITY] ,
                  [ARMED_SERVICES] ,
                  [CHARGE_TYPE] ,
                  [INSURANCE_NO] ,
                  [MAILING_ADDRESS] ,
                  [NEXT_OF_KIN] ,
                  [NEXT_OF_KIN_ADDR] ,
                  [NEXT_OF_KIN_PHONE] ,
                  [NOTE] ,
                  [LASTMODIFYTIME] ,
                  [CFILE] ,
                  [DDD] ,
                  [INPNO] ,
                  [ID2] ,
                  [ID3] ,
                  [VISITID] ,
                  [VOCATION] ,
                  [RESDIAGNOSIS]
                )
                SELECT  [CASEID] ,
                        [PATIENTID] ,
                        [PNAME] ,
                        [PSEX] ,
                        [PBIRTHDATE] ,
                        [PMARRIAGE] ,
                        [IN_TIME] ,
                        [IN_DEPT] ,
                        [OUT_TIME] ,
                        [OUT_DEPT] ,
                        [OUT_WAY] ,
                        [NOW_DEPT] ,
                        [NOW_TIME] ,
                        [ROOMNO] ,
                        [BEDNO] ,
                        [IN_OR_OUT] ,
                        [WEIGHT] ,
                        [TOTAL_COST] ,
                        [DRUG_COST] ,
                        [ANTIBIOTIC_COST] ,
                        [ADMISSION_DIAGNOSIS] ,
                        [INSTATE] ,
                        [CARE_LEVEL] ,
                        [DISCHARGED_DIAGNOSIS] ,
                        [SELF_REPORT] ,
                        [ATTENTION_STATE] ,
                        [INTERVENTION_STATE] ,
                        [INFECTED_STATE] ,
                        [INFECTED_TIME] ,
                        [INFECTED_PART] ,
                        [INFECT_UNIT] ,
                        [OUTCOM] ,
                        [CONSULTING_DOCTOR] ,
                        [DOCTOR_IN_CHARGE] ,
                        [ATTENDING_DOCTOR] ,
                        [DIRECTOR] ,
                        [OPEATOR] ,
                        [IDENTITY] ,
                        [ARMED_SERVICES] ,
                        [CHARGE_TYPE] ,
                        [INSURANCE_NO] ,
                        [MAILING_ADDRESS] ,
                        [NEXT_OF_KIN] ,
                        [NEXT_OF_KIN_ADDR] ,
                        [NEXT_OF_KIN_PHONE] ,
                        [NOTE] ,
                        [LASTMODIFYTIME] ,
                        [CFILE] ,
                        [DDD] ,
                        [INPNO] ,
                        [ID2] ,
                        [ID3] ,
                        [VISITID] ,
                        [VOCATION] ,
                        [RESDIAGNOSIS]
                FROM    OPENQUERY(NIS, ' SELECT * from overall')
                --WHERE   CONVERT(DATE, [OUT_TIME]) BETWEEN @StartDate
                --                                     AND     @EndDate

                  

    END

