
IF OBJECT_ID('dbo.spa_calc_percentile_value','p') IS NOT NULL
DROP PROC dbo.spa_calc_percentile_value
GO

CREATE PROC [dbo].[spa_calc_percentile_value]
	@as_of_date DATETIME
	, @term_start DATETIME = null
	, @term_end DATETIME = NULL
	, @no_simulation INT = NULL
	, @model_id INT = NULL
	, @risk_ids VARCHAR(1000) = NULL
	, @all_risk VARCHAR(1) = NULL
	, @purge VARCHAR(1) = 'n'
	, @process_id VARCHAR(100) = NULL
	, @param VARCHAR(MAX) = NULL
AS
/*
--EXEC spa_calc_percentile_value '2010-11-02', NULL, NULL, NULL, NULL, '18', null, 'n'
DECLARE @as_of_date DATETIME
	, @term_start DATETIME = null
	, @term_end DATETIME = NULL
	, @no_simulation INT = NULL
	, @model_id INT = NULL
	, @risk_ids VARCHAR(1000)
	, @all_risk VARCHAR(1) = NULL
	, @purge VARCHAR(1)
	,@process_id VARCHAR(100)
	
SET @as_of_date = '2010-11-02'
SET @term_start = NULL
SET @term_end = NULL
SET @no_simulation = NULL
SET @model_id = NULL
SET @risk_ids = '18'
SET @all_risk = NULL
SET @purge = 'n'	
--*/
DECLARE @simulation_days INT, 
	@tmp_val1 FLOAT, 
	@tmp_val2 FLOAT, 
	@module VARCHAR(100), 
	@source VARCHAR(100), 
	@error_code CHAR(1),
	@desc VARCHAR(500), 
	@url VARCHAR(500),
	@url_desc VARCHAR(500),
	@user_id VARCHAR(100),
	@count_total INT,
	@count_fail INT,
	@curve_name VARCHAR(8000) = NULL,
	@conf_int FLOAT
	

DECLARE @value_id INT, @code FLOAT, @curve_id INT, @sql VARCHAR(5000)  
DECLARE @maturity_date DATE, @is_dst TINYINT
DECLARE @curve_value_sim FLOAT,	@curve_value_avg FLOAT, @curve_value_delta FLOAT, @curve_value_avg_delta FLOAT, @percentile_value VARCHAR(100)	
	
SET @module = 'Percentile Value Calculation'
SET @source = 'Percentile Value Calculation'
SET @error_code = 'e'
SET @count_total = 0
SET @count_fail = 0
SET @simulation_days = 0

IF @process_id IS NULL
	SET @process_id = REPLACE(NEWID(), '-', '_')
	
IF @user_id IS NULL	
	SET @user_id = dbo.fnadbuser()	

SET @percentile_value = dbo.FNAProcessTableName('percentile_value', dbo.FNADBUser(), @process_id)

IF OBJECT_ID(@percentile_value) IS NOT NULL EXEC ('DROP TABLE ' + @percentile_value)

SET @sql = '
CREATE TABLE ' + @percentile_value + ' (
	[source_price_percentile_id] [int] IDENTITY(1,1) NOT NULL,
	[run_date] [date] NOT NULL,
	[source_curve_def_id] [int] NOT NULL,
	[percentile] [int] NULL,
	[as_of_date] [date] NULL,
	[assessment_curve_type_value_id] [int] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[maturity_date] [datetime] NOT NULL,
	[is_dst] [tinyint] NOT NULL,
	[curve_value_main] [float] NULL,
	[curve_value_sim] [float] NULL)'

PRINT(@sql)
EXEC(@sql)	

IF OBJECT_ID('tempdb..#percentile_val') IS NOT NULL
	DROP TABLE #percentile_val
IF OBJECT_ID('tempdb..#curve_ids') IS NOT NULL
	DROP TABLE #curve_ids
IF OBJECT_ID('tempdb..#source_price_curve_simulation') IS NOT NULL
	DROP TABLE #source_price_curve_simulation				
IF OBJECT_ID('tempdb..#as_of_date') IS NOT NULL
	DROP TABLE #as_of_date		

CREATE TABLE #as_of_date(as_of_date DATETIME)
--BEGIN TRY
	CREATE TABLE #curve_ids(
		curve_id INT
	)       
    
    IF @model_id IS NOT NULL--Collecting curves using @model_id
    BEGIN
    	INSERT INTO #curve_ids(curve_id)
		SELECT DISTINCT spcd.source_curve_def_id
		FROM source_price_curve_def spcd 
		WHERE spcd.monte_carlo_model_parameter_id = @model_id	
    END
    
    IF @risk_ids IS NOT NULL --@risk_ids=curve_ids
    BEGIN
    	INSERT INTO #curve_ids(curve_id)
    	SELECT item FROM dbo.SplitCommaSeperatedValues(@risk_ids)
    END

	IF @risk_ids IS NULL AND @model_id IS NULL
	BEGIN
		INSERT INTO #curve_ids(curve_id)
		SELECT DISTINCT source_curve_def_id FROM source_price_curve_simulation WHERE run_date = @as_of_date
	END
    --Collecting all @as_of_date values, so that we can further process from it

	SET @no_simulation = ISNULL(@no_simulation, 0)

	SET @sql = 'INSERT INTO #as_of_date
	SELECT 
		DISTINCT ' + CASE WHEN CAST(@no_simulation AS VARCHAR) > 0 THEN + ' TOP ' + CAST(@no_simulation AS VARCHAR) ELSE ' as_of_date ' END + ' as_of_date
	FROM source_price_curve_simulation spcs
	INNER JOIN #curve_ids ci ON spcs.source_curve_def_id = ci.curve_id
	WHERE run_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
	ORDER BY spcs.as_of_date'

	PRINT(@sql)
	EXEC(@sql)

    SELECT run_date,
		source_curve_def_id,
		spsd.as_of_date,
		Assessment_curve_type_value_id,
		curve_source_value_id,
		maturity_date,
		curve_value,
		is_dst
	INTO #source_price_curve_simulation FROM source_price_curve_simulation spsd WITH(NOLOCK)
	INNER JOIN #as_of_date a ON spsd.as_of_date = a.as_of_date
    INNER JOIN #curve_ids ci ON spsd.source_curve_def_id = ci.curve_id
    WHERE spsd.run_date = @as_of_date
		AND spsd.maturity_date >= CASE WHEN @term_start IS NOT NULL THEN @term_start ELSE maturity_date END
		AND spsd.maturity_date <= CASE WHEN @term_end IS NOT NULL THEN @term_end ELSE maturity_date END

    CREATE NONCLUSTERED INDEX indx_curve_id_term_start ON #source_price_curve_simulation ([source_curve_def_id], [maturity_date]) INCLUDE ([is_dst])
    
    --Percentile values which should calculate below
    SELECT value_id, REPLACE(code, '%', '') code INTO #percentile_val FROM static_data_value WHERE type_id = 29000
	
	--SET @risk_ids = '5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95'

	--SELECT item value_id, item code INTO #percentile_val FROM dbo.SplitCommaSeperatedValues(@risk_ids)

	IF NOT EXISTS(SELECT TOP 1 1 FROM #percentile_val)
	BEGIN 
		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
		SELECT  @process_id, 'Error', @module, @source, 'Percentile Value Calculation', ' Percentile value not found', 'Please check data.'
		RAISERROR ('CatchError', 16, 1)
	END
	
	--Cursor for each percentile value and curve_ids
	DECLARE cur_curve_percentile_val CURSOR FOR
	SELECT value_id, code, curve_id FROM #percentile_val
	CROSS APPLY (SELECT curve_id FROM #curve_ids) t
	
	OPEN cur_curve_percentile_val
	FETCH NEXT FROM cur_curve_percentile_val INTO @value_id, @code, @curve_id

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Cursor for each maturity_date, is_dst 
		DECLARE cur_maturity CURSOR FOR	
		SELECT DISTINCT maturity_date, is_dst FROM #source_price_curve_simulation WITH(NOLOCK) WHERE source_curve_def_id = @curve_id	
		
		OPEN cur_maturity
		FETCH NEXT FROM cur_maturity INTO @maturity_date, @is_dst
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--Selecting total simulation days of each curve_id, maturity, is_dst
			SELECT @simulation_days = COUNT(as_of_date) 
			FROM #source_price_curve_simulation WITH(NOLOCK)
			WHERE source_curve_def_id = @curve_id 
				AND maturity_date = @maturity_date 
				AND is_dst = @is_dst

			IF OBJECT_ID('tempdb..#ranked_simulation') IS NOT NULL
			DROP TABLE #ranked_simulation
    
			--Ranking each curve_id, maturity, is_dst simulation values
			SELECT 
				run_date,
				source_curve_def_id,
				@code percentile,
				as_of_date,
				Assessment_curve_type_value_id,
				curve_source_value_id,
				maturity_date,
				is_dst,
				ROW_NUMBER() OVER (PARTITION BY run_date, maturity_date, source_curve_def_id, is_dst ORDER BY curve_value ASC) sim_rank,
				curve_value
				INTO #ranked_simulation
			FROM #source_price_curve_simulation WITH(NOLOCK)
			WHERE source_curve_def_id = @curve_id
				AND maturity_date = @maturity_date
				AND is_dst = @is_dst
			
			--Calculating confidence interval
			SET @conf_int = @code/100*CAST(@simulation_days AS FLOAT)
			--curve_value_sim	
			SELECT @tmp_val1 = MAX(CASE WHEN sim_rank = FLOOR(@conf_int) THEN curve_value ELSE NULL END),
				@tmp_val2 = MAX(CASE WHEN sim_rank = CEILING(@conf_int) THEN curve_value ELSE NULL END)
			FROM #ranked_simulation
			
			IF @tmp_val1 = @tmp_val2
				SET @curve_value_sim = @tmp_val1
			ELSE
			BEGIN
				SET @curve_value_sim =(@tmp_val2 * (@conf_int - FLOOR(@conf_int))) + (@tmp_val1 * (CEILING(@conf_int) - @conf_int))
			END	
			
			--Deleting existing records
			IF @purge = 'y'
				DELETE FROM source_price_percentile_delta WHERE run_date <= @as_of_date
			ELSE 
				DELETE sppd FROM source_price_percentile_delta sppd
				INNER JOIN #ranked_simulation rs ON sppd.run_date = rs.run_date
					AND sppd.source_curve_def_id = rs.source_curve_def_id
					AND sppd.maturity_date = rs.maturity_date
					AND sppd.is_dst = rs.is_dst
					AND sppd.percentile = rs.percentile
			
			SET @purge = 'n'
			--Inserting final calculated value
			INSERT INTO source_price_percentile_delta(
				run_date,
				source_curve_def_id,
				percentile,
				assessment_curve_type_value_id,
				curve_source_value_id,
				maturity_date,
				is_dst,
				curve_value_main,
				curve_value_sim
			)	
			SELECT DISTINCT rs.run_date, 
				rs.source_curve_def_id,
				rs.percentile,
				rs.assessment_curve_type_value_id, 
				rs.curve_source_value_id,
				@maturity_date,
				@is_dst, 
				null,
				@curve_value_sim
			FROM #ranked_simulation rs

			SET @sql = '
			INSERT INTO ' + @percentile_value + ' (
				run_date,
				source_curve_def_id,
				percentile,
				assessment_curve_type_value_id,
				curve_source_value_id,
				maturity_date,
				is_dst,
				curve_value_main,
				curve_value_sim)
			SELECT DISTINCT
				rs.run_date, 
				rs.source_curve_def_id,
				rs.percentile,
				rs.assessment_curve_type_value_id, 
				rs.curve_source_value_id,
				''' + CAST(@maturity_date AS VARCHAR) + ''',
				''' + CAST(@is_dst AS VARCHAR) + ''', 
				null,
				''' + CAST(@curve_value_sim AS VARCHAR) + '''
			FROM #ranked_simulation rs'

			--PRINT(@sql)
			EXEC(@sql)
			
		FETCH NEXT FROM cur_maturity INTO @maturity_date, @is_dst
		END

		CLOSE cur_maturity
		DEALLOCATE cur_maturity	
		
	FETCH NEXT FROM cur_curve_percentile_val INTO @value_id, @code, @curve_id
	END

	CLOSE cur_curve_percentile_val
	DEALLOCATE cur_curve_percentile_val

	--EXEC('SELECT * FROM ' + @percentile_value)	

--	---Count total curve_ids processed
--	SELECT @count_total = COUNT(DISTINCT curve_id) FROM #curve_ids
--	---Count total curve_ids failed
--	SELECT @count_fail = COUNT(DISTINCT ci.curve_id) FROM #curve_ids ci
--	WHERE NOT EXISTS(SELECT DISTINCT source_curve_def_id FROM #source_price_curve_simulation spsd WHERE ci.curve_id = spsd.source_curve_def_id) 
	
--	SELECT @curve_name = COALESCE(@curve_name + ', ', '') + spcd.curve_name 
--	FROM #curve_ids ci
--	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = ci.curve_id
--	WHERE NOT EXISTS(SELECT DISTINCT source_curve_def_id FROM #source_price_curve_simulation spsd WHERE ci.curve_id = spsd.source_curve_def_id)
	
--	IF (@count_fail > 0)
--	BEGIN
--		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
--		SELECT DISTINCT @process_id, 'Warning', @module, @source, 'Percentile Value Calculation', ' Price curve simulation not found for as of date: ' 
--		+ dbo.FNADateFormat(@as_of_date) + '; Curve(s): ' + @curve_name, 'Please check data.'
--		--RAISERROR ('CatchError', 16, 1)
--	END
	
--	IF EXISTS(SELECT TOP 1 1 FROM #source_price_curve_simulation)
--	BEGIN
--		SET @error_code = 's'
--		SET @desc = 'Percentile Value Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + '.'	
--		INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
--		SELECT  @process_id, 'Success', @module, @source, 'Percentile Value Calculation', ' Percentile Value Calculation completed for as of date: ' 
--		+ dbo.FNADateFormat(@as_of_date) + '  <b> Total Curve Processed Count</b>: (' + CAST(@count_total AS VARCHAR) + ') <b>Error Count</b>: (' +
--			CAST(@count_fail AS VARCHAR) + ').', 'Please check data.'
--	END
	
--	IF (@count_fail > 0)
--		RAISERROR ('CatchError', 16, 1)
	
--END TRY

--BEGIN CATCH
--	PRINT 'Catch Error' 
	
--	IF @@TRANCOUNT > 0
--		ROLLBACK
--	--PRINT @process_id
--	SET @error_code = 'e'
--	PRINT ERROR_LINE()
--	SET @desc = 'Percentile Value Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + ' (ERRORS found).'
--	--PRINT @desc
--	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
--		''Percentile Value Calculation'''
--END CATCH


--IF @error_code = 'e'
--BEGIN
--	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'

--	SET @url_desc = '<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''+@process_id+'''">Click here...</a>'
--	SELECT 'Error' ErrorCode, 'Calculate Percentile Value' MODULE, 
--			'spa_calc_VaR' Area, 'DB Error' Status, 'Percentile Value Calculation process is completed with error, Please view this report. ' + @url_desc MESSAGE, '' Recommendation
--END
--ELSE
--BEGIN
--	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
--		''Percentile Value Calculation'''
	
--	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'
--	EXEC spa_ErrorHandler 0, 'Percentile Value Calculation', 'Percentile Value Calculation', 'Success', @desc, ''
--END



--EXEC spa_message_board 
--	'i', 
--	@user_id,
--	NULL, 
--	'Percentile Value Calculation',
--	@desc, 
--	'', 
--	'', 
--	@error_code, 
--	'Percentile Value Calculation',
--	NULL,
--	@process_id
