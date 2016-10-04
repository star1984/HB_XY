USE [HBI_GR]
GO
/****** Object:  StoredProcedure [dbo].[xn_K_ETL_usezlTSkss_rs]    Script Date: 03/20/2015 09:30:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM K_Ypxx WHERE bidate BETWEEN '2015-01-01' AND '2015-01-31'
--一个人没有使用过感冒药，何来统计这个人用了什么感冒药的牌子呢，直接排除这个人就可以了。同理，科室没有限制治疗抗菌药物的病人，何来统计这个科室使用限制治疗抗菌药物送检人数？
alter ProceDure [dbo].[xn_K_ETL_usezlTSkss_rs]   
 @StartDate varchar(10),
 @EndDate varchar(10)
as
Begin 
--select top 1000  * from K_Hzjbxx

select cyks_code,count(distinct case when iszlsytskss=1 and isbyxsj=1 then blh else null end ),count(distinct case when iszlsytskss=1 then blh else null end ) from K_Hzjbxx 
where kstype like '02%' and convert(varchar(10),bidate,120) between @StartDate and @EndDate 
group by cyks_code 
having count(distinct case when iszlsytskss=1 then blh else null end )<>0



       



end