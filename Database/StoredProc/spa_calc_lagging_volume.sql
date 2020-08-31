IF OBJECT_ID('dbo.spa_calc_lagging_volume') IS NOT NULL
DROP PROC dbo.spa_calc_lagging_volume

GO

CREATE PROC dbo.spa_calc_lagging_volume @strip_months int,@lagging_months int,@strip_item_months INT ,@Conv_Factor FLOAT,@process_table_name VARCHAR(100), @leg int
AS 
/*
Latter this SP will be called FOR each leg EXCEPT FOR leg 1
6	3	3	2.5	adiha_process.dbo.Lagging_farrms_admin_7DE85C9D_328C_458E_BC52_84DA036AF6F8
-input parameters for SP
DECLARE @strip_months int,@lagging_months int,@strip_item_months INT ,@Conv_Factor FLOAT,@process_table_name VARCHAR(100)
set @strip_months=6
SET @lagging_months=3
SET @strip_item_months=3
SET @Conv_Factor=2.5
set @process_table_name='adiha_process.dbo.Lagging_farrms_admin_B02E8AA3_9EC2_4D2B_959E_DAAA1A7AE7C5'
---------------------------------------------
IF OBJECT_ID('tempdb..#tot_vol') IS NOT null
	DROP TABLE  #tot_vol

IF OBJECT_ID('tempdb..#tmp_term') IS NOT null
	DROP TABLE  #tmp_term
IF OBJECT_ID('tempdb..#tmp') IS NOT null
	DROP TABLE #tmp
IF OBJECT_ID('tempdb..#final_output') IS NOT null
	DROP TABLE  #final_output

--This temporary table will be process table latter.
--Here will be volume of the Leg 1 for each term (data are taken from Uday's excell sheet)
--CREATE TABLE #tmp (term_start datetime,vol float) --@process_table_name
--INSERT INTO #tmp VALUES ('2009-09-01',100)
--INSERT INTO #tmp VALUES ('2009-10-01',200)
--INSERT INTO #tmp VALUES ('2009-11-01',300)
--INSERT INTO #tmp VALUES ('2009-12-01',400)
--INSERT INTO #tmp VALUES ('2010-01-01',200)
--INSERT INTO #tmp VALUES ('2010-02-01',350)
--INSERT INTO #tmp VALUES ('2010-03-01',200)
--INSERT INTO #tmp VALUES ('2010-04-01',300)
--INSERT INTO #tmp VALUES ('2010-05-01',150)
--INSERT INTO #tmp VALUES ('2010-06-01',450)
--INSERT INTO #tmp VALUES ('2010-07-01',400)
--INSERT INTO #tmp VALUES ('2010-08-01',200)
*/

DECLARE @term_start DATETIME,@term_end DATETIME,@no_months TINYINT,@st VARCHAR(max)
create table #tmp (term_start DATETIME,vol numeric(38,20))
SET @st ='insert into #tmp (term_start, vol) SELECT term_start, volume FROM ' + @process_table_name + ' WHERE leg = ' + CAST(@leg AS VARCHAR(10)) 
EXEC(@st)

SELECT @term_start=MIN(term_start),@term_end=MAX(term_start) FROM #tmp 
set  @no_months=DATEDIFF(mm,@term_start,@term_end)

 SELECT *  
INTO #tmp_term 
FROM #tmp tmp 
 CROSS APPLY  [dbo].[FNALaggingMonths] (@strip_months ,@lagging_months ,@strip_item_months,@term_start,DATEADD(mm,1,term_start))
  AS ST


   SELECT grp,SUM(Tot_Vol) Tot_Vol INTO #tot_vol FROM (
	SELECT grp,term_start,max(vol) Tot_Vol FROM #tmp_term GROUP BY grp,term_start
	) tt GROUP BY grp
	

 
 SELECT tmp.term term_start,tmp.term_start term_start_leg1,DATEADD(dd,-1,DATEADD(mm,1,tmp.term_start)) term_end_leg1,
  @strip_months strip_month_from,@lagging_months lag_months,@strip_item_months strip_month_to
  ,@Conv_Factor conv_factor,CAST(tmp.vol AS numeric(38,20))/nullif(tmp1.tot_vol,0) per_allocation
  ,(@Conv_Factor*tmp.vol)/nullif(@strip_months,0) volume_allocation 
  FROM #tmp_term tmp INNER JOIN #tot_vol tmp1
  ON tmp.grp=tmp1.grp
 