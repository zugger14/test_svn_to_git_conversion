IF OBJECT_ID(N'spa_calc_cholesky_decomposition', N'P') IS NOT NULL
	DROP PROC dbo.spa_calc_cholesky_decomposition
/************************************************************
 * Created Date: 04-Feb-2015
 * Owner : Shushil Bohara (sbohara@pioneersolutionsglobal.com)
 ************************************************************/
GO
CREATE PROC dbo.spa_calc_cholesky_decomposition
	 @as_of_date DATETIME
	 , @term_start DATETIME
	 , @term_end DATETIME
	 , @criteria_id INT = NULL
	 , @process_id VARCHAR(100)
	 , @purge CHAR(1) = 'n'
AS
/*
DECLARE @as_of_date DATETIME 
DECLARE @term_start DATETIME 
DECLARE @term_end DATETIME 
DECLARE @curve_ids VARCHAR(1000)
DECLARE @purge CHAR(1)
SET @as_of_date = '2014-07-17'
SET @term_start = '2014-08-01'
SET @curve_ids = ''
SET @term_end = '2014-12-01'
SET @purge = 'n'
--*/
IF OBJECT_ID('tempdb..#tmp_risk_ids') IS NOT NULL
	DROP TABLE #tmp_risk_ids

IF OBJECT_ID('tempdb..#tmp_param_data') IS NOT NULL
	DROP TABLE #tmp_param_data

IF OBJECT_ID('tempdb..#tmp_param_data_detail') IS NOT NULL
	DROP TABLE #tmp_param_data_detail

IF OBJECT_ID('tempdb..#tmp_curve_correlation') IS NOT NULL
	DROP TABLE #tmp_curve_correlation

IF OBJECT_ID('tempdb..#tmp_data') IS NOT NULL
	DROP TABLE #tmp_data

IF OBJECT_ID('tempdb..#tmp_x_ids') IS NOT NULL
	DROP TABLE #tmp_x_ids

IF OBJECT_ID('tempdb..#tmp_decom_result') IS NOT NULL
	DROP TABLE #tmp_decom_result


DECLARE @module VARCHAR(100), 
	@source VARCHAR(100), 
	@errorcode CHAR(1), 
	@desc VARCHAR(500), 
	@url VARCHAR(500),
	@url_desc VARCHAR(500),
	@user_id VARCHAR(100),
	@sql VARCHAR(5000),
	@date_available DATETIME,
	@curve_info VARCHAR(128)
	
SET @module = 'Cholesky Decomposition'
SET @source = 'Cholesky Decomposition'
SET @errorcode = 's'

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()

IF @user_id IS NULL	
	SET @user_id = dbo.FNADBUser()

SET @curve_info = dbo.FNAProcessTableName('Curve_Info', @user_id, @process_id)

--Message handling part, while executing from EOD
DECLARE @simulation_EOD VARCHAR(200)
SET @simulation_EOD = dbo.FNAProcessTableName('simulation_EOD', dbo.FNADBUser(), @process_id)

CREATE TABLE #tmp_risk_ids(risk_bucket_id INT, volatility_source INT)

SET @sql = 'INSERT INTO #tmp_risk_ids
	SELECT DISTINCT risk_bucket_id, 
		volatility_source
	FROM ' + @curve_info

exec spa_print @sql
EXEC(@sql)

--CREATE TABLE #tmp_param_data (curve_id INT, volatility_source INT)

--INSERT INTO #tmp_param_data
--SELECT DISTINCT risk_bucket_id, volatility_source FROM #tmp_risk_ids

BEGIN TRY

	SELECT 
		tpd.risk_bucket_id curve_id_from, 
		t.risk_bucket_id curve_id_to, 
		--tpd.tenor_from term_start, 
		--tpd.tenor_to term_end,
		tpd.volatility_source
	INTO #tmp_param_data_detail
	FROM #tmp_risk_ids tpd
	CROSS APPLY (SELECT DISTINCT risk_bucket_id FROM #tmp_risk_ids) t

	SELECT @date_available = ISNULL(MAX(as_of_date), @as_of_date) FROM curve_correlation WHERE as_of_date <= @as_of_date

	CREATE TABLE #tmp_curve_correlation(as_of_date DATETIME, x_curve_id INT, y_curve_id INT, x_term_start DATETIME, y_term_start DATETIME, cor_value FLOAT, curve_source INT)

	--INSERT INTO #tmp_curve_correlation
	--SELECT DISTINCT @as_of_date 
	--	, cc.curve_id_from x_curve_id
	--	, cc.curve_id_to y_curve_id
	--	, cc.term1
	--	, cc.term2
	--	, cc.value
	--	, cc.curve_source_value_id 
	--FROM #tmp_param_data_detail tpdd
	--INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tpdd.curve_id_from
	--INNER JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = tpdd.curve_id_to
	--INNER JOIN curve_correlation cc ON cc.curve_id_from = ISNULL(spcd.risk_bucket_id, spcd.source_curve_def_id)
	--	AND cc.curve_id_to = ISNULL(spcd2.risk_bucket_id, spcd2.source_curve_def_id)
	--	AND cc.term1 >= @term_start
	--	AND cc.term2 <= @term_end
	--	AND cc.curve_source_value_id = tpdd.volatility_source
	--WHERE cc.as_of_date = @date_available

--select * from #tmp_curve_correlation order by x_curve_id, y_curve_id, x_term_start, y_term_start return
	INSERT INTO #tmp_curve_correlation
	SELECT @as_of_date 
		, cc.curve_id_from
		, cc.curve_id_to
		, cc.term1
		, cc.term2
		, cc.value
		, cc.curve_source_value_id 
	FROM curve_correlation cc
	INNER JOIN #tmp_param_data_detail tpdd ON cc.curve_id_from = tpdd.curve_id_from
		AND cc.curve_id_to = tpdd.curve_id_to
		AND cc.term1 BETWEEN @term_start AND @term_end
		AND cc.term2 BETWEEN @term_start AND @term_end
		AND cc.curve_source_value_id = tpdd.volatility_source
	WHERE cc.as_of_date = @date_available
	 
	IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_curve_correlation)
	BEGIN
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
		SELECT DISTINCT  @process_id, 'Error', @module, @source, 'Cholesky_Correlation', 'Correlation value not found for 
			As of Date: ' + CONVERT(VARCHAR(10), @as_of_date, 120), 'Please check data.'
		
		RAISERROR ('CatchError', 16, 1)
	END
 
	IF EXISTS(SELECT risk_bucket_id FROM #tmp_risk_ids WHERE NOT EXISTS(SELECT DISTINCT x_curve_id FROM #tmp_curve_correlation WHERE x_curve_id = risk_bucket_id))
	BEGIN
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
		SELECT DISTINCT  @process_id, 'Error', @module, @source, 'Cholesky_Correlation', 'Correlation value not found for 
			As of Date: ' + CONVERT(VARCHAR(10), @as_of_date, 120) + '; Risk Bucket ID: ' + spcd.curve_name + '.', 'Please check data.'
		FROM #tmp_risk_ids tri
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tri.risk_bucket_id
		WHERE NOT EXISTS(SELECT DISTINCT x_curve_id FROM #tmp_curve_correlation WHERE x_curve_id = tri.risk_bucket_id)

		--RAISERROR ('CatchError', 16, 1)
	END


	IF(SELECT CASE WHEN COUNT(DISTINCT x_term_start) = COUNT(DISTINCT y_term_start) THEN 1 ELSE 0 END FROM #tmp_curve_correlation) = 0
	BEGIN
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
		SELECT  @process_id, 'Error', @module, @source, 'Cholesky_Matrix', 'Matrix is not square', 'Please check data.'

		RAISERROR ('CatchError', 16, 1)
	END

	SELECT
		as_of_date 
		, (ROW_NUMBER() OVER (PARTITION BY y_curve_id, y_term_start ORDER BY  x_curve_id, x_term_start)) y_id
		, (ROW_NUMBER() OVER (PARTITION BY x_curve_id, x_term_start ORDER BY y_curve_id, y_term_start)) x_id 
		, x_curve_id
		, y_curve_id
		, x_term_start
		, y_term_start
		, cor_value
		, curve_source
	INTO #tmp_data
	FROM #tmp_curve_correlation

	SELECT DISTINCT x_id, x_curve_id, x_term_start INTO #tmp_x_ids FROM #tmp_data

	UPDATE #tmp_data SET 
		cor_value = 0 
	FROM #tmp_x_ids x 
	CROSS APPLY (SELECT y_id FROM #tmp_data WHERE x_id = x.X_id AND y_id < x.x_id) a
	INNER JOIN #tmp_data b ON x.x_id = b.X_id AND b.y_id = a.y_id

	SELECT as_of_date 
		, x_id
		, y_id
		, x_curve_id
		, y_curve_id
		, x_term_start
		, y_term_start
		, CASE WHEN X_id = 1 THEN cor_value ELSE NULL END d_value
		, curve_source 
	INTO #tmp_decom_result 
	FROM #tmp_data 
	WHERE cor_value IS NOT NULL

	DECLARE @x_id INT = 2, @no_loop INT
	SELECT @no_loop = MAX(x_id) FROM #tmp_x_ids
	--set @no_loop=2
	WHILE @x_id <= @no_loop
	BEGIN
	
		IF OBJECT_ID('tempdb..#d_one') IS NOT NULL
		DROP TABLE #d_one

		SELECT v.val value INTO #d_one FROM #tmp_decom_result s 
		CROSS APPLY (SELECT (1 - SUM(POWER(d_value, 2))) val FROM #tmp_decom_result WHERE Y_id = @x_id AND X_id < @x_id) v
		WHERE s.Y_id = @x_id AND s.X_id = @x_id

		IF EXISTS(SELECT 1 FROM #d_one WHERE value < 0)
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
			SELECT  @process_id, 'Error', @module, @source, 'Cholesky_Positive_Value', 'Matrix is not positive definite', 'Please check data.'

			--RAISERROR ('CatchError', 16, 1)
		END

		IF NOT EXISTS(SELECT 1 FROM #d_one WHERE value < 0)
		BEGIN
			UPDATE #tmp_decom_result SET d_value = v.val FROM #tmp_decom_result s 
			CROSS APPLY (SELECT SQRT(1 - SUM(POWER(d_value, 2))) val FROM #tmp_decom_result WHERE Y_id = @x_id AND X_id < @x_id) v
			WHERE s.Y_id = @x_id AND s.X_id = @x_id

			IF OBJECT_ID('tempdb..#first_value') IS NOT NULL
			DROP TABLE #first_value

			SELECT * INTO #first_value FROM #tmp_decom_result WHERE X_id < @x_id AND Y_id = @x_id

			UPDATE #tmp_decom_result SET d_value = (d.cor_value-sum_prod.val) / z.val
			FROM #tmp_decom_result s 
			INNER JOIN #tmp_data d ON s.X_id = d.X_id AND s.Y_id = d.Y_id
			CROSS APPLY(SELECT SUM(a.d_value * b.d_value) val FROM #tmp_decom_result a 
			INNER JOIN #first_value b ON a.X_id = b.X_id AND a.Y_id = s.Y_id) sum_prod
			CROSS APPLY(SELECT a.d_value val FROM #tmp_decom_result a WHERE a.X_id = @x_id AND a.Y_id = @x_id) z
			WHERE  s.X_id = @x_id AND s.y_id > @x_id AND s.d_value IS NULL
		END
		SET @x_id = @x_id + 1
	
	END

	IF @purge = 'y'
	BEGIN
		IF @criteria_id > 0
		BEGIN
			DELETE cdvw FROM cholesky_decomposition_value_whatif cdvw WHERE cdvw.as_of_date < @as_of_date
			DELETE cdvw FROM cholesky_decomposition_value_whatif cdvw WHERE cdvw.as_of_date = @as_of_date AND cdvw.criteria_id = @criteria_id
		END
		ELSE
			DELETE cdv FROM cholesky_decomposition_value cdv WHERE as_of_date <= @as_of_date
	END
	ELSE
	BEGIN
		IF @criteria_id > 0
			DELETE 
				cdvw 
			FROM cholesky_decomposition_value_whatif cdvw
			WHERE cdvw.as_of_date = @as_of_date
				AND cdvw.criteria_id = @criteria_id
		ELSE
			DELETE 
				cdv 
			FROM cholesky_decomposition_value cdv
			INNER JOIN #tmp_decom_result tdr ON tdr.as_of_date = cdv.as_of_date
				AND tdr.x_curve_id = cdv.x_curve_id
				AND tdr.curve_source = cdv.curve_source
	END

	IF @criteria_id > 0
		INSERT INTO cholesky_decomposition_value_whatif(
			criteria_id,
			as_of_date,
			x_id,
			y_id,
			x_curve_id,
			y_curve_id,
			x_term_start,
			y_term_start,
			d_value,
			curve_source
		)
		SELECT @criteria_id
			, as_of_date 
			, x_id
			, y_id
			, x_curve_id
			, y_curve_id
			, x_term_start
			, y_term_start
			, d_value
			, curve_source
		FROM #tmp_decom_result
	ELSE
		INSERT INTO cholesky_decomposition_value(
			as_of_date,
			x_id,
			y_id,
			x_curve_id,
			y_curve_id,
			x_term_start,
			y_term_start,
			d_value,
			curve_source
		)
		SELECT as_of_date 
			, x_id
			, y_id
			, x_curve_id
			, y_curve_id
			, x_term_start
			, y_term_start
			, d_value
			, curve_source
		FROM #tmp_decom_result

	EXEC spa_print 'Cholesky Decomposition'
		SET @desc = 'Cholesky decomposition process is completed for As of Date: ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + '.'

	SET @errorcode = 's'

END TRY	

BEGIN CATCH
	EXEC spa_print 'Catch Error'
	IF @@TRANCOUNT > 0
		ROLLBACK
	SET @errorcode = 'e'
	SET @desc = 'Cholesky Decomposition process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + ' (ERRORS found).'
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
		''Cholesky Decomposition'''
END CATCH


IF @errorcode = 'e'
BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'

	SET @url_desc = '<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''+@process_id+'''">Click here...</a>'

	IF OBJECT_ID(@simulation_EOD) IS NULL
	SELECT 'Error' ErrorCode, 'Cholesky Decomposition' MODULE, 
			'spa_calc_cholesky_decomposition' Area, 'DB Error' Status, 'Cholesky Decomposition process is completed with error, Please view this report. ' + @url_desc MESSAGE, '' Recommendation
END
ELSE
BEGIN
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
		''Cholesky Decomposition'''
	
	--SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'
	IF OBJECT_ID(@simulation_EOD) IS NULL
	EXEC spa_ErrorHandler 0, 'Cholesky Decomposition Process', 	'Cholesky Decomposition', 'Success', @desc, ''
END


IF @errorcode = 's'
EXEC  spa_message_board 
		'i', 
		@user_id,
		NULL, 
		'Cholesky Decomposition',
		@desc, 
		'', 
		'', 
		@errorcode, 
		'Cholesky Decomposition',
		NULL,
		@process_id