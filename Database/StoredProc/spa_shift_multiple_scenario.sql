

/************************************************************
 * Date: 2016-Mar-16
 * Owner : Shushil Bohara (@sbohara@pioneersolutionsglobal.com)
 * Desc: It calculates shift value for multiple scenario 
 ***********************************************************
 EXEC dbo.spa_shift_multiple_scenario '2013-06-28', NULL, NULL, NULL, NULL, 6, NULL, NULL, 'n'
 */

IF OBJECT_ID('spa_shift_multiple_scenario') IS NOT NULL
DROP PROC dbo.spa_shift_multiple_scenario
GO
CREATE PROC dbo.spa_shift_multiple_scenario
	@as_of_date DATETIME
	, @criteria_id INT
	, @term_start DATETIME = null
	, @term_end DATETIME = NULL
	, @delta CHAR(1) = 'n'
	, @purge CHAR(1) = 'n'
	, @process_id VARCHAR(100) = NULL
	, @param VARCHAR(MAX) = NULL
AS
/*

DECLARE @as_of_date DATETIME = '2015-06-25'
	, @criteria_id INT = 124
	, @term_start DATETIME = NULL
	, @term_end DATETIME = NULL
	, @delta CHAR(1) = 'y'
	, @purge CHAR(1) = 'n'
	, @process_id VARCHAR(100) = 'DFDEF766_8273_49C9_8902_317BA7069775'
	, @param VARCHAR(MAX) = NULL
	
--*/
DECLARE 
	@simulation_days INT, 
	@tmp_val1 FLOAT, 
	@tmp_val2 FLOAT, 
	@module VARCHAR(100), 
	@source VARCHAR(100), 
	@errorcode VARCHAR(1), 
	@desc VARCHAR(500), 
	@url VARCHAR(500),
	@url_desc VARCHAR(500),
	@user_id VARCHAR(100),
	@book_parameter VARCHAR(5000),
	@sql VARCHAR(max),
	@commodity_shift_params_table VARCHAR(100),
	@final_calc_val VARCHAR(100),
	@source_deal_header_id VARCHAR(1000),
	@std_deal_table	VARCHAR(250)
	
SET @module = 'Shift Value Calculation'
SET @source = 'Shift Value Calculation'	
SET @errorcode = 's'

IF @process_id IS NULL
	SET @process_id = REPLACE(NEWID(), '-', '_')
IF @user_id IS NULL	
	SET @user_id = dbo.fnadbuser()

SET @std_deal_table = dbo.FNAProcessTableName('std_whatif_deals', @user_id, @process_id)
SELECT @commodity_shift_params_table = dbo.FNAProcessTableName('commodity_shift_params', @user_id, @process_id)
SELECT @final_calc_val = dbo.FNAProcessTableName('final_calc_val', @user_id, @process_id)

--IF OBJECT_ID(@std_deal_table) IS NOT NULL EXEC ('DROP TABLE ' + @std_deal_table)
IF OBJECT_ID(@commodity_shift_params_table) IS NOT NULL EXEC ('DROP TABLE ' + @commodity_shift_params_table)
IF OBJECT_ID(@final_calc_val) IS NOT NULL EXEC ('DROP TABLE ' + @final_calc_val)

DECLARE @st_sql varchar(5000), @str_and VARCHAR(250)
SET @str_and = ''

BEGIN TRY
	--############# START COLLECTING DEALS ##################--
	
IF OBJECT_ID('tempdb..#tmp_deals') IS NOT NULL
	DROP table #tmp_deals	

	CREATE TABLE #tmp_deals(
		id INT IDENTITY(1,1),
		source_deal_header_id INT,
		option_flag CHAR(1) COLLATE DATABASE_DEFAULT 
	)

	SET @st_sql='INSERT INTO #tmp_deals(source_deal_header_id, option_flag)
	SELECT p.source_deal_header_id, sdh.option_flag FROM ' + @std_deal_table + ' p
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = p.source_deal_header_id
		AND sdh.deal_date <= ''' + CAST(@as_of_date AS VARCHAR) + '''
		AND sdh.entire_term_end >= ''' + CAST(@as_of_date AS VARCHAR) + '''
	'

	EXEC(@st_sql)

	SET @source_deal_header_id = ''
	SELECT @source_deal_header_id = @source_deal_header_id + CAST(source_deal_header_id AS VARCHAR) + ',' FROM #tmp_deals WHERE option_flag = 'y'
	IF @source_deal_header_id = ''
		SET @source_deal_header_id = NULL
	ELSE
		SET  @source_deal_header_id = LEFT(@source_deal_header_id, LEN(@source_deal_header_id) - 1)

	--Start Fetching original MTM and grouping by commodity
	IF OBJECT_ID('tempdb..#tmp_mtm_value') IS NOT NULL
		DROP table #tmp_mtm_value
	
	CREATE TABLE #tmp_mtm_value(commodity_id INT, mtm FLOAT)
	
	INSERT INTO #tmp_mtm_value
	SELECT spcd.commodity_id, SUM(sdp.und_pnl) mtm
	FROM #tmp_deals d
	INNER JOIN (SELECT DISTINCT source_deal_header_id, curve_id FROM source_deal_detail) sdd ON sdd.source_deal_header_id = d.source_deal_header_id  
	INNER JOIN source_deal_pnl sdp ON sdp.source_deal_header_id = d.source_deal_header_id
		AND sdp.pnl_as_of_date = @as_of_date
		AND (@term_start IS NULL OR sdp.term_start >= @term_start)
		AND (@term_end IS NULL OR sdp.term_end <= @term_end)
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
	GROUP BY spcd.commodity_id
	--End Fetching original MTM and grouping by commodity
		
	DELETE FROM #tmp_deals WHERE option_flag = 'y'	
	
	--========================================

	--######## START COLLECTING SHIFT DETAILS #############--
	
	IF OBJECT_ID('tempdb..#tmp_scenario') IS NOT NULL
		DROP table #tmp_scenario

	CREATE TABLE #tmp_scenario(
		id INT IDENTITY(1, 1),
		shift_item INT,
		shift_value INT
		) 

	IF (SELECT scenario_group_id FROM maintain_whatif_criteria where criteria_id = @criteria_id) IS NULL
		INSERT INTO #tmp_scenario		
		SELECT shift_item, shift_value
		FROM (SELECT shift_item, shift1, shift2, shift3, shift4, shift5, shift6, shift7, shift8, shift9, shift10 FROM whatif_criteria_scenario WHERE  criteria_id = @criteria_id
			AND shift_group = 24003) p
		UNPIVOT
			(shift_value FOR shift_col IN (shift1, shift2, shift3, shift4, shift5, shift6, shift7, shift8, shift9, shift10)) AS unpvt
		ORDER BY shift_item	
	ELSE
		INSERT INTO #tmp_scenario		
		SELECT shift_item, shift_value
		FROM (SELECT shift_item, shift1, shift2, shift3, shift4, shift5, shift6, shift7, shift8, shift9, shift10 
				FROM maintain_whatif_criteria mwc
				INNER JOIN maintain_scenario ms ON ms.scenario_group_id = mwc.scenario_group_id 
				WHERE mwc.criteria_id = @criteria_id
			AND ms.shift_group = 24003) p
		UNPIVOT
			(shift_value FOR shift_col IN (shift1, shift2, shift3, shift4, shift5, shift6, shift7, shift8, shift9, shift10)) AS unpvt
		ORDER BY shift_item		
	
	--SELECT * FROM #tmp_scenario
	IF OBJECT_ID('tempdb..#tmp_scenario_ranking') IS NOT NULL
		DROP table #tmp_scenario_ranking
		
	SELECT id, shift_item, shift_value, RANK() OVER(PARTITION BY shift_item ORDER BY id) rnk INTO #tmp_scenario_ranking
	FROM #tmp_scenario
	
	--SELECT * FROM #tmp_scenario_ranking
	IF OBJECT_ID('tempdb..#tmp_final_shift') IS NOT NULL
		DROP table #tmp_final_shift

	CREATE TABLE #tmp_final_shift(
		commodity_one INT, 
		commodity_two INT, 
		shift_one FLOAT, 
		shift_two FLOAT
	)
	
	DECLARE @max_id INT
	SELECT @max_id = max(id) FROM #tmp_scenario WHERE shift_item = (SELECT DISTINCT shift_item FROM #tmp_scenario WHERE id = 1)
	
	INSERT INTO #tmp_final_shift(commodity_one, commodity_two, shift_one, shift_two)
	SELECT tsr.shift_item commodity_one, tsr1.shift_item commodity_two, tsr.shift_value shift_one, tsr1.shift_value shift_two 
	FROM 
	(SELECT * FROM #tmp_scenario_ranking WHERE id <= @max_id) tsr
	OUTER APPLY (SELECT * FROM #tmp_scenario_ranking WHERE id > @max_id) tsr1 

--SELECT * FROM #tmp_scenario_ranking
--SELECT * FROM #tmp_final_shift RETURN

	
	EXEC('SELECT * INTO ' + @commodity_shift_params_table + ' FROM #tmp_final_shift')

	--######## START TAKING INDEX VALUES ################--
	
	IF OBJECT_ID('tempdb..#total_val') IS NOT NULL
		DROP table #total_val
	
	CREATE TABLE #total_val(commodity_id INT, value FLOAT)

	IF @term_start IS NOT NULL
		SET @str_and = @str_and + ' AND ifb.term_start >= ''' + CAST(@term_start AS VARCHAR) + ''''
	IF @term_end IS NOT NULL
		SET @str_and = @str_and + ' AND ifb.term_end <= ''' + CAST(@term_end AS VARCHAR) + ''''
				
	SET @st_sql='
		INSERT INTO #total_val 
		SELECT commodity_id, SUM(value) value
		FROM (
			SELECT ISNULL(spcd.commodity_id, -1) commodity_id, ifb.value
			FROM   index_fees_breakdown ifb
			INNER JOIN #tmp_deals td ON ifb.source_deal_header_id = td.source_deal_header_id
			LEFT JOIN source_price_curve_def spcd ON ifb.field_id*-1 = spcd.source_curve_def_id
			WHERE  ifb.as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + '''
					AND ifb.internal_type = -1 
				' + @str_and + '
			) t
		GROUP BY commodity_id'
		
		
	exec spa_print @st_sql
	EXEC(@st_sql)
	
	--######## END TAKING INDEX VALUES ################--
	
	--calculation for non-option deals	
	
	IF @source_deal_header_id IS NOT NULL
		EXEC spa_get_multiple_commodity_shift_value @as_of_date, NULL, NULL, NULL, NULL, @source_deal_header_id, @term_start, @term_end, @delta, @process_id
	
	IF OBJECT_ID('tempdb..#tmp_final_calc_val') IS NOT NULL
		DROP table #tmp_final_calc_val
		
	CREATE TABLE #tmp_final_calc_val(
			commodity_one INT,
			commodity_two INT,
			shift_one FLOAT,
			shift_two FLOAT, 
			value_one FLOAT,
			value_two FLOAT, 
			calc_value_one FLOAT,
			calc_value_two FLOAT,
			fixed_value FLOAT,
			total_value FLOAT
			)

	IF @delta = 'y'
	BEGIN
		INSERT INTO #tmp_final_calc_val
		SELECT tfs.commodity_one, 
			tfs.commodity_two,
			tfs.shift_one,
			tfs.shift_two, 
			tv.value value_one,
			tv1.value value_two, 
			tv.value*(tfs.shift_one / 100) delta_one,
			tv1.value*(tfs.shift_two / 100) delta_two,
			tv2.value fixed_value,
			(ISNULL(tv.value*(tfs.shift_one / 100), 0) + ISNULL(tv1.value*(tfs.shift_two / 100), 0)) delta_total
		FROM #tmp_final_shift tfs
		LEFT JOIN #total_val tv ON tv.commodity_id = tfs.commodity_one
		LEFT JOIN #total_val tv1 ON tv1.commodity_id = tfs.commodity_two
		OUTER APPLY(SELECT value FROM #total_val WHERE commodity_id = -1) tv2
	END
	ELSE
	BEGIN
		INSERT INTO #tmp_final_calc_val
		SELECT tfs.commodity_one, 
			tfs.commodity_two,
			tfs.shift_one,
			tfs.shift_two, 
			tv.value value_one,
			tv1.value value_two, 
			(tv.value*(1 + (tfs.shift_one) / 100)) calc_value_one,
			(tv1.value*(1 + (tfs.shift_two) / 100)) calc_value_two,
			tv2.value fixed_value,
			(ISNULL(tv.value*(1 + (tfs.shift_one / 100)), 0) + ISNULL(tv1.value*(1 + (tfs.shift_two / 100)), 0) + ISNULL(tv2.value, 0) + isnull(tv3.value,0)) total_value
		FROM #tmp_final_shift tfs
		LEFT JOIN #total_val tv ON tv.commodity_id = tfs.commodity_one
		LEFT JOIN #total_val tv1 ON tv1.commodity_id = tfs.commodity_two
		OUTER APPLY(SELECT value FROM #total_val WHERE commodity_id = -1) tv2
		OUTER APPLY(SELECT value FROM #total_val 
					WHERE	commodity_id <> -1 
							AND commodity_id <> tfs.commodity_one 
							AND commodity_id <> isnull(tfs.commodity_two,-99)) tv3

	END
	
	SET @st_sql = 'IF OBJECT_ID (N''' + @final_calc_val +''', N''U'') IS NOT NULL
	BEGIN
		INSERT INTO #tmp_final_calc_val
		SELECT * FROM ' + @final_calc_val + '
	END'
	
	exec spa_print @st_sql
	EXEC(@st_sql)
	
	IF @purge = 'y'
		DELETE mssr FROM multiple_scenario_shift_result mssr WHERE mssr.as_of_date <= CAST(@as_of_date AS DATE) AND mssr.criteria_id = @criteria_id
	ELSE
		DELETE mssr FROM multiple_scenario_shift_result mssr
		WHERE mssr.as_of_date = CAST(@as_of_date AS DATE)
			AND mssr.criteria_id = @criteria_id

	INSERT INTO multiple_scenario_shift_result(as_of_date,
		criteria_id,
		commodity_one,
		commodity_two,
		shift_one,
		shift_two,
		value_one,
		value_two,
		calc_value_one,
		calc_value_two,
		fixed_value,
		total_value,
		term_start,
		term_end,
		delta,
		mtm_value_one,
		mtm_value_two 
		)
	SELECT CAST(@as_of_date AS DATE) as_of_date, 
		@criteria_id criteria_id,
		tfcv.commodity_one,
		tfcv.commodity_two,
		tfcv.shift_one,
		tfcv.shift_two, 
		tfcv.value_one,
		tfcv.value_two, 
		tfcv.calc_value_one,
		tfcv.calc_value_two,
		tfcv.fixed_value,
		tfcv.total_value,
		CAST(@term_start AS DATE),
		CAST(@term_end AS DATE),
		@delta,
		m1.mtm AS mtm_value_one,
		m2.mtm AS mtm_value_two  
	FROM #tmp_final_calc_val tfcv
	LEFT JOIN #tmp_mtm_value m1 ON m1.commodity_id = tfcv.commodity_one
	LEFT JOIN #tmp_mtm_value m2 ON m2.commodity_id = tfcv.commodity_two

	
	EXEC spa_print 'Finish What-If MTM Value Calculation'
	SET @desc = 'What-If MTM Value Calculation is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + '.'
	SET @errorcode = 's'
END TRY

BEGIN CATCH 
	EXEC spa_print 'Catch Error:' --+ ERROR_MESSAGE()
	IF @@TRANCOUNT > 0
		ROLLBACK
	--PRINT @process_id
	SET @errorcode = 'e'
	--EXEC spa_print ERROR_LINE()
	SET @desc = 'What-If MTM Value Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + ' (ERRORS found).'
	--PRINT @desc
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
		''What-If MTM Value Calculation'''
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '</a>'
END CATCH

EXEC spa_message_board 
	'i', 
	@user_id,
	NULL, 
	'What-If MTM Value Calculation',
	@desc, 
	NULL, 
	'', 
	@errorcode, 
	null,
	NULL,
	@process_id
