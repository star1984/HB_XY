USE [HBIDATA]
GO
/****** Object:  StoredProcedure [dbo].[P_21_ETL_YG_treatment1]    Script Date: 08/18/2016 14:47:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<wgf>
-- Create date: <20160115>
-- Description:	<院感数据抽取>
-- =============================================
ALTER  PROCEDURE [dbo].[P_21_ETL_YG_treatment1]
    @StartDate DATETIME ,
    @EndDate DATETIME
AS 
    BEGIN
    
-- P_21_ETL_YG_treatment1 '2003-1-01','2016-12-31'
--select COUNT(*) from [GR_treatment1];

        --DELETE  [GR_treatment1]
        --WHERE   CONVERT(DATE, [ENDTIME]) BETWEEN @StartDate
        --                                 AND     @EndDate

TRUNCATE TABLE [GR_treatment1]

        INSERT  INTO [GR_treatment1]
                ( [TNO] ,
                  [CASEID] ,
                  [TTYPE] ,
                  [DEPT] ,
                  [TNAME] ,
                  [BEGINTIME] ,
                  [ENDTIME] ,
                  [LASTMODIFYTIME],
                  [DEPTNAME]
                )
                SELECT  [TNO] ,
                        [CASEID] ,
                        [TTYPE] ,
                        [DEPT] ,
                        [TNAME] ,
                        [BEGINTIME] ,
                        CASE WHEN [ENDTIME]='9999' THEN  NULL ELSE [ENDTIME] END,
                        [LASTMODIFYTIME],
                        [LABEL]
                FROM    OPENQUERY(NIS, ' select * from treatment1 a left join S_DEPARTMENTS b on a.dept=b.code')
                --WHERE   CONVERT(DATE, [ENDTIME]) BETWEEN @StartDate
                --                                 AND     @EndDate

                  

    END

