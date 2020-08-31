IF OBJECT_ID(N'[dbo].[spa_interpolate_curve]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_interpolate_curve]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_interpolate_curve]
	  @calc_type CHAR(1)	--i-> Interpolate, a-> Interpolate & Discount Factor, b-> Discount Factor & Interpolate
	, @as_of_date_from DATETIME
	, @as_of_date_to DATETIME = NULL
	, @term_start DATETIME = NULL
	, @term_end DATETIME = NULL
	, @input_curve INT
	, @days_in_year INT = NULL
	, @multiplier FLOAT = 1
	, @process_id VARCHAR(100) = NULL
	, @param VARCHAR(MAX) = NULL
AS
/*
EXEC spa_interpolate_curve 'b', '2014-04-04', '2014-04-04', '2014-07-08', '2044-04-08', 2418, 365, 0.01

DECLARE @calc_type CHAR(1)
	, @as_of_date_from DATETIME
	, @as_of_date_to DATETIME
	, @term_start DATETIME
	, @term_end DATETIME
	, @input_curve INT
	, @days_in_year INT
	, @multiplier FLOAT

SET @calc_type = NULL	
SET @as_of_date_from = '2013-07-01'
SET @as_of_date_to = '2013-07-01'
SET @term_start = NULL
SET @term_end = NULL
SET @input_curve = NULL
SET @days_in_year = NULL
SET @multiplier = NULL
--*/
DECLARE @module VARCHAR(100), 
	@source VARCHAR(100), 
	@errorcode CHAR(1), 
	@desc VARCHAR(500), 
	@url VARCHAR(500),
	@url_desc VARCHAR(500),
	@user_id VARCHAR(100),
	@sql VARCHAR(5000)
	
SET @module = 'Interpolation Calculation'
SET @source = 'Interpolation Calculation'
SET @errorcode = 's'
--SET @simulation_days = @no_simulation

IF @process_id IS NULL
	SET @process_id = REPLACE(NEWID(), '-', '_')
	
IF @user_id IS NULL	
	SET @user_id = dbo.fnadbuser()	
	
--BEGIN TRY
	--TAKEN ORIGINAL VALUE FROM SOURCE TABLE
	CREATE TABLE #tmp_org_value_taken (
		id INT IDENTITY(1, 1),
		as_of_date DATETIME,
		maturity_date DATETIME,
		curve_value FLOAT,
		source_curve_def_id INT,
		granularity CHAR(1),
		curve_source_value_id INT
	)

	SET @sql = 'INSERT INTO #tmp_org_value_taken(as_of_date, maturity_date, curve_value, source_curve_def_id, granularity, curve_source_value_id)
		SELECT spc.as_of_date
			, spc.maturity_date
			, spc.curve_value * ' + CAST(@multiplier AS VARCHAR) + '
			, spc.source_curve_def_id
			, CASE spcd.Granularity 
				WHEN 993 THEN ''a''
				WHEN 981 THEN ''d''
				WHEN 982 THEN ''h''
				WHEN 980 THEN ''m''
				WHEN 991 THEN ''q''
				WHEN 992 THEN ''s''
				WHEN 990 THEN ''w''
			ELSE ''d''
			END granularity
			, spc.curve_source_value_id 
		FROM source_price_curve spc
		INNER JOIN source_price_curve_def spcd ON spc.source_curve_def_id = spcd.source_curve_def_id
		WHERE 1 = 1
			AND spc.source_curve_def_id = ' + CAST(@input_curve AS VARCHAR) + ''

	IF @as_of_date_from IS NOT NULL AND @as_of_date_to IS NOT NULL
		SET @sql = @sql + ' AND spc.as_of_date BETWEEN ''' + CAST(@as_of_date_from AS VARCHAR) + ''' AND ''' + CAST(@as_of_date_to AS VARCHAR) + ''''

	IF @as_of_date_from IS NOT NULL AND @as_of_date_to IS NULL
		SET @sql = @sql + ' AND spc.as_of_date = ''' + CAST(@as_of_date_from AS VARCHAR) + ''''
	
	IF @term_start IS NOT NULL 
		SET @sql = @sql + ' AND spc.maturity_date >= ''' + CAST(@term_start AS VARCHAR) + ''''

	IF @term_end IS NOT NULL 
		SET @sql = @sql + ' AND spc.maturity_date <= ''' + CAST(@term_end AS VARCHaR) + ''''

	PRINT(@sql)
	EXEC(@sql)

	IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_org_value_taken)
		SET @errorcode = 'e'
	
	--Added missing maturity for each as_of_date,curve with curve value 0
	IF @term_start IS NOT NULL
		INSERT INTO #tmp_org_value_taken(as_of_date, maturity_date, curve_value, source_curve_def_id, granularity, curve_source_value_id)
		SELECT DISTINCT 
			as_of_date 
			, CASE WHEN @term_start = as_of_date THEN @term_start ELSE as_of_date END maturity_date
			, 0 curve_value
			, source_curve_def_id
			, granularity
			, MAX(curve_source_value_id)
		FROM #tmp_org_value_taken
		GROUP BY as_of_date, source_curve_def_id, granularity 
		HAVING MIN(maturity_date) <> CASE WHEN @term_start = @as_of_date_from THEN @term_start ELSE @as_of_date_from END

	--Inserting value in another table with proper ordering 
	--This ordering helps in further calculation
	SELECT id = IDENTITY(INT, 1, 1) 
		, as_of_date 
		, maturity_date
		, curve_value
		, source_curve_def_id
		, granularity
		, curve_source_value_id
	INTO #tmp_org_value	 
	FROM #tmp_org_value_taken
	ORDER BY as_of_date, maturity_date, source_curve_def_id 

	--DISCOUNT FACTOR
	-- when interpolate value calculated from discount factor
	IF @calc_type = 'b' 
		UPDATE tiv
		SET curve_value = (1 + curve_value * DATEDIFF(DAY, tiv.as_of_date, maturity_date) / @days_in_year)
		FROM #tmp_org_value tiv

	--INTERPOLATION PARTIAL CALCULATION
	SELECT tov.id
		, tov.as_of_date
		, term.term_start
		, tov.source_curve_def_id
		, tov.curve_value
		, CASE WHEN term.term_start = tov.maturity_date THEN 
			tov.curve_value 
			ELSE
			((tov_one.curve_value - tov.curve_value) / DATEDIFF(DAY, tov.maturity_date, tov_one.maturity_date)) 
			END half_calc_val
		, tov.maturity_date
		, tov.curve_source_value_id
	INTO #tmp_calc_val
	FROM #tmp_org_value tov
	LEFT JOIN #tmp_org_value tov_one ON tov.id + 1 = tov_one.id
		AND tov.as_of_date = tov_one.as_of_date
		AND tov.source_curve_def_id = tov_one.source_curve_def_id
	CROSS APPLY(SELECT term_start FROM dbo.FNATermBreakdown(tov.granularity, tov.maturity_date, tov_one.maturity_date - 1)) term

	--INTERPOLATION
	SELECT id
		, as_of_date
		, term_start
		, source_curve_def_id
		, curve_value
		, curve_value + (half_calc_val * DATEDIFF(DAY, maturity_date, term_start)) interpolate_val
		, curve_value discount_factor
		, curve_source_value_id
	INTO #tmp_interpolate_value	 
	FROM #tmp_calc_val scv

	--DISCOUNT FACTOR
	-- when interpolate value calculated from curve_value not from discount factor
	IF @calc_type <> 'b'
		UPDATE tiv
		SET discount_factor = (1 + interpolate_val * DATEDIFF(DAY, tiv.as_of_date, term_start) / @days_in_year)
		FROM #tmp_interpolate_value tiv

	--Interpolation Only
	IF @calc_type IN('i', 'b') 
		SELECT
			source_curve_def_id 
			, as_of_date
			, 77 Assessment_curve_type_value_id
			, curve_source_value_id
			, term_start
			, CAST(interpolate_val AS NUMERIC(30, 9)) interpolate_val
			, 0 is_dst
		FROM #tmp_interpolate_value
		WHERE term_start >= CASE WHEN @term_start >= as_of_date THEN @term_start ELSE as_of_date END
		ORDER BY as_of_date, term_start, source_curve_def_id
	ELSE	--Discount Factor Only
		SELECT 
			source_curve_def_id
			, as_of_date
			, 77 Assessment_curve_type_value_id
			, curve_source_value_id
			, term_start
			, CAST(discount_factor AS NUMERIC(30, 9)) discount_factor
			, 0 is_dst
		FROM #tmp_interpolate_value
		WHERE term_start >= CASE WHEN @term_start >= as_of_date THEN @term_start ELSE as_of_date END
		ORDER BY as_of_date, term_start, source_curve_def_id

	SET @desc = CASE WHEN @calc_type = 'a' THEN 'Discount Factor ' ELSE 'Interpolation ' END + 'calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date_from, @user_id) + '.'	

	If @errorcode = 'e'
	BEGIN
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, module, source, [type], [description], nextsteps) 
		SELECT  @process_id, 'Error', @module, @source, 'Interpolation Calculation', ' Price not found for as of date: ' 
		+ dbo.FNADateFormat(@as_of_date_to), 'Please check data.'

		SET @desc = 'Interpolation Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date_from, @user_id) + ' (ERRORS found).'
		--PRINT @desc
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
			''Interpolation Calculation'''

		SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'

		SET @url_desc = '<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''+@process_id+'''">Click here...</a>'
	END
		
	EXEC spa_message_board 'i', @user_id, NULL, 'Interpolation Calculation', @desc, '',  '', @errorcode, 'Interpolation Calculation', NULL, @process_id


