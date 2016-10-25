alter proc [dbo].[p_blsj_hzdl_rank]
@startDate varchar(10),
@endDate varchar(10)
AS
BEGIN 
SELECT lb,COUNT(*) num  INTO #rank FROM T_blsj_all 
WHERE CONVERT(VARCHAR(10),bidate,120) BETWEEN @startDate AND  @endDate 
GROUP BY lb

SELECT lb,RANK() OVER(ORDER BY num desc) pm FROM #rank

END 

--EXEC p_blsj_hzdl_rank '2016-10-01','2016-10-31'