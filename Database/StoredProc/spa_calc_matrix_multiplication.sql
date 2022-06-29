IF OBJECT_ID(N'spa_calc_matrix_multiplication', N'P') IS NOT NULL
	DROP PROC dbo.spa_calc_matrix_multiplication
/************************************************************
 * Created Date: 04-Feb-2015
 * Owner : Shushil Bohara (sbohara@pioneersolutionsglobal.com)
 ************************************************************/
GO
CREATE PROC dbo.spa_calc_matrix_multiplication
	 @as_of_date DATETIME
    , @term_start DATETIME
	, @term_end  DATETIME
	, @no_simulation INT = NULL
	, @criteria_id INT = NULL
	, @process_id VARCHAR(100)
	, @purge CHAR(1) = 'n'
AS
/*
DECLARE @as_of_date DATETIME
	, @term_start DATETIME
	, @term_end DATETIME
	, @curve_ids VARCAHR(1000)
	, @no_simulation INT
	, @purge CHAR(1)
SET @as_of_date = '2014-07-17'
SET @term_start = '2014-08-01'
SET @term_end = '2014-12-01'
SET @curve_ids = ''
SET @no_of_simulation = 3000
SET @purge = 'n'
--*/
	DECLARE @module VARCHAR(100), 
	@source VARCHAR(100), 
	@errorcode CHAR(1), 
	@desc VARCHAR(500), 
	@url VARCHAR(500),
	@url_desc VARCHAR(500),
	@user_id VARCHAR(100),
	@sql VARCHAR(5000),
	@curve_info VARCHAR(128),
	@date_available DATETIME, --Eigen value parameters
	@as_of_date_one NVARCHAR(10) = CONVERT(NVARCHAR(10), @as_of_date, 120),
    @term_start_one NVARCHAR(10) = CONVERT(NVARCHAR(10), @term_start, 120),
	@term_end_one  NVARCHAR(10) = CONVERT(NVARCHAR(10), @term_end, 120),
	@process_id_one NVARCHAR(50) = @process_id,
	@purge_one NVARCHAR(2) = @purge,
	@calc_eigen CHAR(1) = 'n',
	@dvalue_end_range FLOAT = -2,
	@decomposition_type NCHAR(1) = 'b' --It runs singular value decomposition logic in case of eigen failure
									--'s'- Singular Value Decomposition only
									--'e'- Eigen Value Decomposition only
	
SET @module = 'Matrix Multiplication'
SET @source = 'Matrix Multiplication'
SET @errorcode = 's'

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()

IF @user_id IS NULL	
	SET @user_id = dbo.FNADBUser()	

SET @curve_info = dbo.FNAProcessTableName('Curve_Info', @user_id, @process_id)

--Message handling part, while executing from EOD
DECLARE @simulation_EOD VARCHAR(200)
SET @simulation_EOD = dbo.FNAProcessTableName('simulation_EOD', dbo.FNADBUser(), @process_id)

IF OBJECT_ID('tempdb..#tmp_final_value') IS NOT NULL
	DROP TABLE #tmp_final_value
IF OBJECT_ID('tempdb..#tmp_rnd_value') IS NOT NULL
	DROP TABLE #tmp_rnd_value
IF OBJECT_ID('tempdb..#tmp_risk_ids') IS NOT NULL
	DROP TABLE #tmp_risk_ids
IF OBJECT_ID('tempdb..#curve_detail') IS NOT NULL
	DROP TABLE #curve_detail
IF OBJECT_ID('tempdb..#as_of_date_point') IS NOT NULL
	DROP TABLE #as_of_date_point
	
DECLARE @user_id_one NVARCHAR(20) = @user_id	

BEGIN TRY
	EXEC spa_calc_cholesky_decomposition @as_of_date, @term_start, @term_end, @criteria_id, @process_id, @purge
	
	IF EXISTS(SELECT TOP 1 1 FROM fas_eff_ass_test_run_log WHERE process_id = @process_id AND code ='Error' AND source <> 'Monte Carlo Simulation' AND DESCRIPTION = 'Matrix is not positive definite')
	BEGIN
		SET @calc_eigen = 'y'
		EXEC spa_calculate_eigen_values @as_of_date_one, @term_start_one, @term_end_one, @purge_one, @dvalue_end_range, @user_id_one, @process_id_one, @criteria_id, @decomposition_type
	END
		
	IF EXISTS(SELECT TOP 1 1  FROM fas_eff_ass_test_run_log WHERE process_id = @process_id AND code ='Error' AND source <> 'Monte Carlo Simulation' AND module = 'Eigen Values')
		RETURN
		
	CREATE TABLE #tmp_eigen_cho_val	(
		as_of_date DATETIME,
		x_curve_id INT,
		y_curve_id INT,
		x_term_start DATETIME,
		y_term_start DATETIME,
		curve_source INT,
		d_value FLOAT
		)	

	IF @calc_eigen ='y'
	BEGIN
		IF @criteria_id > 0
			SELECT @date_available = ISNULL(MAX(as_of_date), @as_of_date) FROM eigen_value_decomposition_whatif WHERE as_of_date <= @as_of_date and criteria_id = @criteria_id
		ELSE
			SELECT @date_available = ISNULL(MAX(as_of_date), @as_of_date) FROM eigen_value_decomposition WHERE as_of_date <= @as_of_date
		
		SET @sql = '
			INSERT INTO #tmp_eigen_cho_val	
			SELECT DISTINCT as_of_date, 
				curve_id_from x_curve_id,
				curve_id_to y_curve_id, 
				term1 x_term_start,
				term2 y_term_start,
				curve_source_value_id curve_source,
				eigen_factors d_value
			FROM eigen_value_decomposition' + CASE WHEN @criteria_id > 0 THEN '_whatif' ELSE '' END + '
			WHERE as_of_date = ''' + CAST(@date_available AS VARCHAR) + '''
			AND term1 >= ''' + CAST(@term_start AS VARCHAR) + '''
			AND term2 <= ''' + CAST(@term_end AS VARCHAR) + ''''
			+ CASE WHEN @criteria_id > 0 THEN ' AND criteria_id = ' + CAST(@criteria_id AS VARCHAR) + '' ELSE '' END
			
		EXEC(@sql)
	END	
	ELSE
	BEGIN
		IF @criteria_id > 0
			SELECT @date_available = ISNULL(MAX(as_of_date), @as_of_date) FROM cholesky_decomposition_value_whatif WHERE as_of_date <= @as_of_date and criteria_id = @criteria_id
		ELSE
			SELECT @date_available = ISNULL(MAX(as_of_date), @as_of_date) FROM cholesky_decomposition_value WHERE as_of_date <= @as_of_date
		
		SET @sql = '
			INSERT INTO #tmp_eigen_cho_val
			SELECT DISTINCT as_of_date, 
				x_curve_id,
				y_curve_id, 
				x_term_start,
				y_term_start,
				curve_source,
				d_value
			FROM cholesky_decomposition_value' + CASE WHEN @criteria_id > 0 THEN '_whatif' ELSE '' END + '
			WHERE as_of_date = ''' + CAST(@date_available AS VARCHAR) + '''
			AND x_term_start >= ''' + CAST(@term_start AS VARCHAR) + '''
			AND y_term_start <= ''' + CAST(@term_end AS VARCHAR) + ''''
			+ CASE WHEN @criteria_id > 0 THEN ' AND criteria_id = ' + CAST(@criteria_id AS VARCHAR) + '' ELSE '' END
			
		EXEC(@sql)
	END		
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_eigen_cho_val WHERE as_of_date = @date_available)
	BEGIN
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
		SELECT  @process_id, 'Error', @module, @source, 'Matrix_Multiplication', 'Correlation decomposition value not found for 
		As of Date: ' + CONVERT(VARCHAR(10), @as_of_date, 120), 'Please check data.'

		RAISERROR ('CatchError', 16, 1)
	END

	CREATE TABLE #as_of_date_point(row_id INT IDENTITY(1, 1), as_of_date DATETIME);
	WITH user_rec(as_of_date, cnt) AS
	(
		SELECT CAST('1900-01-01' AS DATE) , 0 AS cnt
		UNION ALL 
		SELECT DATEADD(day,(cnt+1),CAST('1900-01-01' AS DATE)), cnt+1 FROM user_rec r 
		WHERE cnt +1 < ISNULL(@no_simulation, 30)
	)
	INSERT INTO #as_of_date_point(as_of_date)	
	SELECT as_of_date FROM user_rec
	OPTION (MAXRECURSION 0)

	CREATE TABLE #tmp_risk_ids(risk_bucket_id INT, volatility_source INT)

	SET @sql = 'INSERT INTO #tmp_risk_ids
		SELECT DISTINCT risk_bucket_id, 
			volatility_source
		FROM ' + @curve_info

	exec spa_print @sql
	EXEC(@sql)

	SELECT tri.risk_bucket_id curve_id_from
		, y.risk_bucket_id curve_id_to
		, tri.volatility_source
	INTO #curve_detail	 
	FROM #tmp_risk_ids tri
	CROSS APPLY(SELECT DISTINCT risk_bucket_id FROM #tmp_risk_ids) y

	CREATE TABLE #tmp_rnd_value(
		curve_id INT, 
		risk_id INT, 
		as_of_date DATETIME, 
		term_start DATETIME, 
		rnd_value FLOAT,
		norm_rnd_value FLOAT,
		curve_source INT
	)

	--INSERT INTO #tmp_rnd_value(curve_id, risk_id, as_of_date, term_start, rnd_value, curve_source)
	--SELECT t.x_curve_id curve_id, 
	--	t.x_curve_id risk_id, 
	--	a.as_of_date, 
	--	t.x_term_start term_start, 
	--	dbo.FNARandNumber() rnd_value,
	--	t.volatility_source
	--FROM #as_of_date_point a
	--CROSS JOIN (SELECT DISTINCT cdv.x_curve_id, 
	--				cdv.as_of_date, 
	--				cdv.x_term_start,
	--				tri.volatility_source 
	--			FROM #curve_detail tri
	--			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tri.curve_id_from
	--			INNER JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = tri.curve_id_to
	--			INNER JOIN cholesky_decomposition_value cdv ON cdv.x_curve_id = ISNULL(spcd.risk_bucket_id, spcd.source_curve_def_id)
	--				AND cdv.y_curve_id = ISNULL(spcd2.risk_bucket_id, spcd2.source_curve_def_id)
	--				AND tri.volatility_source = cdv.curve_source
	--				AND cdv.x_term_start BETWEEN @term_start AND @term_end 
	--			WHERE cdv.as_of_date = @date_available) t
					

	INSERT INTO #tmp_rnd_value(curve_id, risk_id, as_of_date, term_start, rnd_value, curve_source)
	SELECT t.x_curve_id curve_id, 
		t.x_curve_id risk_id, 
		a.as_of_date, 
		t.x_term_start term_start, 
		dbo.FNARandNumber() rnd_value,
		t.volatility_source
	FROM #as_of_date_point a
	CROSS JOIN (SELECT DISTINCT cdv.x_curve_id, 
					cdv.as_of_date, 
					cdv.x_term_start,
					cd.volatility_source 
				FROM #tmp_eigen_cho_val cdv
				INNER JOIN #curve_detail cd ON cd.curve_id_from = cdv.x_curve_id
					AND cdv.y_curve_id = cd.curve_id_to
					AND cd.volatility_source = cdv.curve_source
				WHERE cdv.as_of_date = @date_available
				AND cdv.x_term_start >= @term_start
				AND cdv.y_term_start <= @term_end) t
	
	IF EXISTS(SELECT risk_bucket_id FROM #tmp_risk_ids WHERE NOT EXISTS(SELECT DISTINCT curve_id FROM #tmp_rnd_value WHERE curve_id = risk_bucket_id))
	BEGIN
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
		SELECT DISTINCT  @process_id, 'Error', @module, @source, 'Matrix_Multiplication', 'Correlation Decomposition value not found for 
			As of Date: ' + CONVERT(VARCHAR(10), @as_of_date, 120) + '; Risk Bucket ID: ' + spcd.curve_name + '.', 'Please check data.'
		FROM #tmp_risk_ids tri
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tri.risk_bucket_id
		WHERE NOT EXISTS(SELECT DISTINCT curve_id FROM #tmp_rnd_value WHERE curve_id = tri.risk_bucket_id)

		RAISERROR ('CatchError', 16, 1)
	END

	UPDATE trv SET norm_rnd_value = dbo.FNANormSInv(rnd_value) FROM #tmp_rnd_value trv

	SELECT tdr.x_curve_id curve_id, tdr.x_curve_id risk_id, trv.as_of_date,  tdr.x_term_start term_start, SUM(tdr.d_value*trv.norm_rnd_value) AS cor_rnd_value 
	INTO #tmp_final_value
	FROM #tmp_eigen_cho_val tdr
	INNER JOIN #tmp_rnd_value trv ON tdr.y_curve_id = trv.curve_id
		AND tdr.y_term_start = trv.term_start
		AND tdr.curve_source = trv.curve_source
	WHERE tdr.as_of_date =	@date_available
	GROUP BY tdr.x_curve_id, tdr.x_term_start, trv.as_of_date

	IF @purge = 'y'
	BEGIN
		IF @criteria_id > 0
		BEGIN
			DELETE mmvw FROM matrix_multiplication_value_whatif mmvw WHERE mmvw.run_date < @as_of_date
			DELETE mmvw FROM matrix_multiplication_value_whatif mmvw WHERE mmvw.run_date = @as_of_date AND mmvw.criteria_id = @criteria_id
		END
		ELSE
			DELETE mmv FROM matrix_multiplication_value mmv WHERE run_date <= @as_of_date
	END
	ELSE
	BEGIN
		IF @criteria_id > 0
			DELETE 
				mmvw 
			FROM matrix_multiplication_value_whatif mmvw
			WHERE mmvw.run_date = @as_of_date AND mmvw.criteria_id = @criteria_id
		ELSE
			DELETE 
				mmv 
			FROM matrix_multiplication_value mmv
			INNER JOIN #tmp_rnd_value trv ON mmv.as_of_date = trv.as_of_date
				AND mmv.curve_id = trv.curve_id
				AND trv.curve_source = mmv.curve_source
			WHERE mmv.run_date = @as_of_date
	END
		
	IF @criteria_id > 0
		INSERT INTO matrix_multiplication_value_whatif(
			criteria_id,
			run_date,
			as_of_date,
			curve_id,
			risk_id,
			term_start,
			rnd_value,
			norm_rnd_value,
			cor_rnd_value,
			curve_source
			)
		SELECT @criteria_id, 
			@as_of_date,
			tfv.as_of_date,
			tfv.curve_id,
			tfv.risk_id,
			tfv.term_start,
			trv.rnd_value,
			trv.norm_rnd_value,
			tfv.cor_rnd_value, 
			trv.curve_source 
		FROM #tmp_final_value  tfv
		INNER JOIN #tmp_rnd_value trv ON tfv.as_of_date = trv.as_of_date
			AND tfv.term_start = trv.term_start
			AND tfv.curve_id = trv.curve_id
	ELSE
		INSERT INTO matrix_multiplication_value(
			run_date,
			as_of_date,
			curve_id,
			risk_id,
			term_start,
			rnd_value,
			norm_rnd_value,
			cor_rnd_value,
			curve_source
			)
		SELECT @as_of_date,
			tfv.as_of_date,
			tfv.curve_id,
			tfv.risk_id,
			tfv.term_start,
			trv.rnd_value,
			trv.norm_rnd_value,
			tfv.cor_rnd_value, 
			trv.curve_source 
		FROM #tmp_final_value  tfv
		INNER JOIN #tmp_rnd_value trv ON tfv.as_of_date = trv.as_of_date
			AND tfv.term_start = trv.term_start
			AND tfv.curve_id = trv.curve_id

	EXEC spa_print 'Matrix Multiplication'
		SET @desc = 'Matrix Multiplication process is completed for As of Date: ' + dbo.FNAUserDateFormat(@as_of_date, @user_id)

	SET @errorcode = 's'

END TRY

BEGIN CATCH
	EXEC spa_print 'Catch Error'
	IF @@TRANCOUNT > 0
		ROLLBACK
	SET @errorcode = 'e'
	SET @desc = 'Matrix Multiplication process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + ' (ERRORS found).'
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
		''Matrix Multiplication'''
END CATCH


IF @errorcode = 'e'
BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'

	SET @url_desc = '<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''+@process_id+'''">Click here...</a>'

	IF OBJECT_ID(@simulation_EOD) IS NULL
	SELECT 'Error' ErrorCode, 'Cholesky Decomposition' MODULE, 
			'spa_calc_matrix_multiplication' Area, 'DB Error' Status, 'Matrix Multiplication process is completed with error, Please view this report. ' + @url_desc MESSAGE, '' Recommendation
END
ELSE
BEGIN
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
		''Matrix Multiplication'''
	
	--SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'
	IF OBJECT_ID(@simulation_EOD) IS NULL
	EXEC spa_ErrorHandler 0, 'Matrix Multiplication Process', 	'Matrix Multiplication', 'Success', @desc, ''
END

IF @errorcode = 's'
EXEC  spa_message_board 
		'i', 
		@user_id,
		NULL, 
		'Matrix Multiplication',
		@desc, 
		'', 
		'', 
		@errorcode, 
		'Matrix Multiplication',
		NULL,
		@process_id