IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_derive_bom_prices]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_derive_bom_prices]
GO

-- ===============================================================================================================
-- Create date: 2011-08-10
-- Description:	Calculates BOM prices for some curves and export their values
-- Params:
--	@as_of_date DATETIME - As of Date
--	@batch_process_id VARCHAR(100) - Process id for batch processing
--	@run_mode TINYINT - Controls the operation as follows:
--						0: Calculation only.
--						1: Calculation and return data.
--						2: Return data without calculating.
-- Usage:
--	EXEC spa_derive_bom_prices '2011-04-25', '1232xxxx', 1
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_derive_bom_prices](
	@as_of_date DATETIME
	, @batch_process_id VARCHAR(100) = NULL
	, @run_mode TINYINT = 0
)
AS

/**********************************************TEST DATA START******************************************************/

--DECLARE @as_of_date VARCHAR(20)
--DECLARE @batch_process_id VARCHAR(100)
--DECLARE @run_mode TINYINT
--SET @as_of_date = '2011-07-07'
--SET @run_mode = 1


--IF OBJECT_ID('tempdb..#bom_curve') IS NOT NULL
--	DROP TABLE #bom_curve
--IF OBJECT_ID('tempdb..#t_curve') IS NOT NULL
--	DROP TABLE #t_curve
--IF OBJECT_ID('tempdb..#f_curve') IS NOT NULL
--	DROP TABLE #f_curve
	
/**********************************************TEST DATA END******************************************************/

--Start tracking time for Elapse time
DECLARE @begin_time DATETIME
SET @begin_time = GETDATE()

SET	@run_mode = ISNULL(@run_mode, 0)

CREATE TABLE #bom_curve(daily_curve_id INT, monthly_curve_id INT, bom_curve_id INT)
-- These curve ids are specific to Essent and is safe to hardcode as same prod db is restored in other environments as well.
INSERT INTO #bom_curve VALUES(97, 113, 131) -- ZBH
INSERT INTO #bom_curve VALUES(5, 112, 130) -- TTF
/*
INSERT INTO #bom_curve
SELECT 
	(SELECT spcd.source_curve_def_id FROM source_price_curve_def spcd WHERE spcd.curve_id = 'ESS#GSFW_ZBH - D') daily_curve_id
	, (SELECT spcd.source_curve_def_id FROM source_price_curve_def spcd WHERE spcd.curve_id = 'ESS#GSFW_ZBH - M') monthly_curve_id
	, (SELECT spcd.source_curve_def_id FROM source_price_curve_def spcd WHERE spcd.curve_id = 'Dutch Hourly Power Offpeak') bom_curve_id
UNION ALL
SELECT 
	(SELECT spcd.source_curve_def_id FROM source_price_curve_def spcd WHERE spcd.curve_id = 'ESS#GSFW_TT7 - D') daily_curve_id
	, (SELECT spcd.source_curve_def_id FROM source_price_curve_def spcd WHERE spcd.curve_id = 'ESS#GSFW_TT7 - M') monthly_curve_id
	, (SELECT spcd.source_curve_def_id FROM source_price_curve_def spcd WHERE spcd.curve_id = 'Dutch Hourly Power Onpeak') bom_curve_id
*/

IF @batch_process_id IS NULL
	SET @batch_process_id = dbo.FNAGetNewID()

SELECT b.daily_curve_id, b.monthly_curve_id, b.bom_curve_id,MAX(spc.maturity_date) max_maturity
	, CONVERT(VARCHAR(7), MAX(spc.maturity_date), 120) + '-01' start_maturity
	, DATEADD(MONTH, 1, CAST(CONVERT(VARCHAR(8), MAX(spc.maturity_date), 120) + '01' AS DATETIME)) - 1 end_maturity
	, (DATEDIFF(DAY, CONVERT(VARCHAR(7), MAX(spc.maturity_date), 120) + '-01', DATEADD(MONTH, 1, CAST(CONVERT(VARCHAR(8), MAX(spc.maturity_date),120) + '01' AS DATETIME)) - 1) + 1) * 24 + MAX(1 * (CASE WHEN mv.id IS NOT NULL THEN -1 WHEN mv1.id IS NOT NULL THEN 1 ELSE 0 END)) [days]
	, (DATEDIFF(DAY, CONVERT(VARCHAR(7), MAX(spc.maturity_date), 120) + '-01', MAX(spc.maturity_date)) + 1) * 24 + MAX(1 * (CASE WHEN mv2.id IS NOT NULL THEN -1 WHEN mv3.id IS NOT NULL THEN 1 ELSE 0 END)) dp
	, (DATEDIFF(DAY, MAX(spc.maturity_date), DATEADD(MONTH, 1, CAST(CONVERT(VARCHAR(8), MAX(spc.maturity_date), 120) + '01' AS DATETIME))-1))* 24 + MAX(1 * (CASE WHEN mv4.id IS NOT NULL THEN -1 WHEN mv5.id IS NOT NULL THEN 1 ELSE 0 END)) ndp	   
INTO #t_curve
FROM source_price_curve spc INNER JOIN #bom_curve b ON spc.source_curve_def_id = b.daily_curve_id 
 LEFT JOIN mv90_DST mv ON mv.date BETWEEN CONVERT(VARCHAR(7), spc.maturity_date, 120) + '-01' 
	AND DATEADD(MONTH,1,CAST(CONVERT(VARCHAR(8),(spc.maturity_date),120)+'01' AS DATETIME)) - 1 
	AND mv.insert_delete = 'd'
 LEFT JOIN mv90_DST mv1 ON mv1.date BETWEEN CONVERT(VARCHAR(7), spc.maturity_date, 120) + '-01' 
	AND DATEADD(MONTH,1,CAST(CONVERT(VARCHAR(8),(spc.maturity_date),120)+'01' AS DATETIME)) - 1 
	AND mv1.insert_delete = 'i'
 LEFT JOIN mv90_DST mv2 ON mv2.date BETWEEN CONVERT(VARCHAR(7), spc.maturity_date, 120) + '-01' 
	AND spc.maturity_date 
	AND mv2.insert_delete = 'd'
 LEFT JOIN mv90_DST mv3 ON mv3.date BETWEEN CONVERT(VARCHAR(7), spc.maturity_date, 120) + '-01' 
	AND spc.maturity_date 
	AND mv3.insert_delete = 'i'
 LEFT JOIN mv90_DST mv4 ON mv4.date BETWEEN spc.maturity_date 
	AND DATEADD(MONTH,1,CAST(CONVERT(VARCHAR(8),(spc.maturity_date),120)+'01' AS DATETIME)) - 1 
	AND mv4.insert_delete = 'd'
 LEFT JOIN mv90_DST mv5 ON mv5.date BETWEEN spc.maturity_date 
	AND DATEADD(MONTH,1,CAST(CONVERT(VARCHAR(8),(spc.maturity_date),120)+'01' AS DATETIME)) - 1 
	AND mv5.insert_delete = 'i'
WHERE spc.as_of_date = @as_of_date
GROUP BY b.daily_curve_id, b.monthly_curve_id, b.bom_curve_id
HAVING MAX(spc.maturity_date) < DATEADD(MONTH,1,CAST(CONVERT(VARCHAR(8),MAX(spc.maturity_date),120)+'01' AS DATETIME))-1

--SELECT * FROM #t_curve

IF @run_mode IN (0, 1)
BEGIN
	SELECT  t.daily_curve_id, t.monthly_curve_id, t.bom_curve_id, AVG(spc.curve_value) daily_avg, MAX(spc_m.curve_value) monthly_avg,
		(MAX(spc_m.curve_value) * MAX(t.[days]) - AVG(spc.curve_value) * MAX(t.dp))/MAX(t.ndp) new_price,
		MAX(t.start_maturity) start_maturity
	INTO #f_curve
	FROM #t_curve t 
	INNER JOIN source_price_curve spc ON spc.source_curve_def_id = t.daily_curve_id 
		AND	spc.as_of_date = @as_of_date 
		AND	spc.maturity_date BETWEEN t.start_maturity AND t.max_maturity 
	INNER JOIN source_price_curve spc_m ON spc_m.source_curve_def_id = t.monthly_curve_id 
		AND	spc_m.as_of_date = @as_of_date 
		AND	spc_m.maturity_date = t.start_maturity
	GROUP BY t.daily_curve_id, t.monthly_curve_id, t.bom_curve_id
	
	--SELECT * FROM #f_curve

	DELETE FROM source_price_curve 
	FROM source_price_curve spc 
	INNER JOIN #f_curve f ON spc.source_curve_def_id = f.bom_curve_id 
		AND spc.as_of_date = @as_of_date

	INSERT INTO source_price_curve (source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date ,curve_value
		, create_user, create_ts, update_user, update_ts, bid_value, ask_value, is_dst)
	SELECT	f.bom_curve_id, @as_of_date as_of_date, 77, 4500, f.start_maturity, f.new_price
		, dbo.FNADBUser(), GETDATE(), dbo.FNADBUser(), GETDATE(), f.new_price, f.new_price, 0
	FROM #f_curve f

	DECLARE @status_type VARCHAR(1)
	DECLARE @desc VARCHAR(5000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @error_count INT
	DECLARE @total_to_be_processed INT

	SET @user_login_id = dbo.FNADBUser()

	INSERT INTO source_system_data_import_status(Process_id, code, MODULE, source, [TYPE], [description], recommendation, create_user, create_ts, update_user, update_ts)
	SELECT @batch_process_id process_id, 'Error', 'BOM Curve', 'spa_derive_bom_prices', 'Data Error', 
			'Failed to derive BOM curve for ' + spcd.curve_name + ' (ID: ' + CAST(spcd.source_curve_def_id AS VARCHAR) + ') as of date ' + 
			ISNULL(dbo.FNADateFormat(@as_of_date), CONVERT(VARCHAR(10), @as_of_date, 120)),
			'Please check price curves',
			@user_login_id, GETDATE(), @user_login_id, GETDATE() 
	FROM #f_curve f INNER JOIN
	source_price_curve_def spcd ON spcd.source_curve_def_id = f.bom_curve_id 
	WHERE new_price IS NULL

	SET @error_count = @@ROWCOUNT
	IF @error_count > 0 
		SET @status_type = 'e'
	ELSE
		SET @status_type = 's'

	DECLARE @count INT
	SELECT @count  = COUNT(*) FROM #f_curve WHERE new_price IS NOT NULL
	SELECT @total_to_be_processed = COUNT(*) FROM #bom_curve

	--select @count  
	--select @total_to_be_processed 
	
--------------------------------------DERVICE CURVES HERE -------------------------

-- drop table #convert_curves_to_ect_m3 

	create table #convert_curves_to_ect_m3 (from_curve_id int, to_curve_id int)

	insert into #convert_curves_to_ect_m3 select 151, 138
	insert into #convert_curves_to_ect_m3 select 156, 136
	insert into #convert_curves_to_ect_m3 select 155, 10
	insert into #convert_curves_to_ect_m3 select 5, 152
	insert into #convert_curves_to_ect_m3 select 130, 153
	insert into #convert_curves_to_ect_m3 select 112, 154

	--MWH TO M3 conversion
	declare @cf float
	select @cf = conversion_factor from rec_volume_unit_conversion where from_source_uom_id=1 and to_source_uom_id=20

	insert into source_price_curve(source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, 
				curve_value, bid_value, ask_value, is_dst)
	select	c.to_curve_id source_curve_def_id, s.as_of_date, s.Assessment_curve_type_value_id, 
			s.curve_source_value_id, s.maturity_date, 
			s.curve_value*100/@cf curve_value, s.bid_value*100/@cf bid_value, s.ask_value*100/@cf ask_value, s.is_dst  
	from #convert_curves_to_ect_m3 c INNER JOIN
		source_price_curve s ON  s.source_curve_def_id = c.from_curve_id LEFT JOIN 
		source_price_curve spc ON spc.source_curve_def_id= c.to_curve_id and spc.as_of_date=s.as_of_date
								and spc.maturity_date=s.maturity_date and spc.is_dst=s.is_dst
	where s.as_of_date = @as_of_date AND 
      spc.source_curve_def_id is null

------------------------------------END OF DERVIE CURVES	
	
	
	
	--write status in message board only in calc only mode (called by EOD process)
	IF @run_mode = 0
	BEGIN
		DECLARE @e_time_s INT
		DECLARE @e_time_text_s VARCHAR(100)
		SET @e_time_s = DATEDIFF(ss,@begin_time,GETDATE())
		SET @e_time_text_s = CAST(CAST(@e_time_s/60 AS INT) AS VARCHAR) + ' Mins ' + CAST(@e_time_s - CAST(@e_time_s/60 AS INT) * 60 AS VARCHAR) + ' Secs'


		IF @status_type = 'e'
			SET @desc = '<a target="_blank" href="' +  './dev/spa_html.php?__user_name__=' + @user_login_id + 
				'&spa=exec spa_source_system_data_import_status ''s'', ''' + @batch_process_id + '''' + '">' + 
			'Errors Found while calculating BOM prices for as of date ' + ISNULL(dbo.FNADateFormat(@as_of_date), @as_of_date) + 
			' Total Procesed Count: ' + CAST(@total_to_be_processed AS VARCHAR) +
			' Calculated Count: ' + CAST(@count AS VARCHAR) + ' Error Count: ' +  CAST(@error_count AS VARCHAR) +
			' [Elapse time: ' + @e_time_text_s + ']' + 
			'.</a>'
		ELSE	
			SET @desc = 'BOM prices calc process completed for as of date ' + ISNULL(dbo.FNADateFormat(@as_of_date), CONVERT(VARCHAR(10), @as_of_date, 120)) +
				' Total Procesed Count: ' + CAST(@total_to_be_processed AS VARCHAR) +
				' Calculated Count: ' + CAST(@count AS VARCHAR) + ' Error Count: ' +  CAST(@error_count AS VARCHAR) + 
				' [Elapse time: ' + @e_time_text_s + ']' 
				
		DECLARE @job_name VARCHAR(250)
		SET @job_name = 'bom_' + @batch_process_id 
		EXEC  spa_message_board 'u', @user_login_id, NULL, 'Derive BOM', @desc, '', '', @status_type, @job_name, NULL, @batch_process_id, NULL, 'n', NULL, 'y'
	END
END

IF @run_mode IN (1, 2)
BEGIN
	SELECT spc.as_of_date AsofDate, spcd_daily.curve_name AS [DailyCurve], spcd_monthly.curve_name AS [MonthlyCurve], spcd_bom.curve_name AS [BOMCurve]
		, spc.curve_value AS [DailyCurveValue], spc.maturity_date AS [DailyCurveMaturityDate]
		, spc_m.curve_value AS [MonthlyCurveValue], spc_m.maturity_date [MonthlyCurveMaturityDate] 
	FROM #t_curve t
	INNER JOIN source_price_curve_def spcd_daily ON t.daily_curve_id = spcd_daily.source_curve_def_id
	INNER JOIN source_price_curve_def spcd_monthly ON t.monthly_curve_id = spcd_monthly.source_curve_def_id
	INNER JOIN source_price_curve_def spcd_bom ON t.bom_curve_id = spcd_bom.source_curve_def_id
	INNER JOIN source_price_curve spc ON spc.source_curve_def_id = t.daily_curve_id
		AND spc.as_of_date = @as_of_date 
		AND spc.maturity_date BETWEEN t.start_maturity AND t.max_maturity 
	INNER JOIN source_price_curve spc_m ON spc_m.source_curve_def_id = t.monthly_curve_id 
		AND spc_m.as_of_date = @as_of_date 
		AND spc_m.maturity_date = t.start_maturity
	--ORDER BY [DailyCurve], [DailyCurveMaturityDate], [MonthlyCurve], [MonthlyCurveValue]
END
GO
