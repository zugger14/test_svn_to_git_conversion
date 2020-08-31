

/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 2/18/2014 12:34:34 PM
 * By : Shushil Bohara (@sbohara@pioneersolutionsglobal.com)
 ***********************************************************

 * Modified by	: Sangam Ligal
 * Purpose		: To adapt the changes for 'Commodity Shift Report' and its view.
 * Modified Date: 4 March. 2014

 EXEC dbo.spa_calc_shift_value '2013-06-28', NULL, NULL, NULL, NULL, 6, NULL, NULL, 'n'
 */
IF OBJECT_ID('spa_calc_shift_value') IS NOT NULL
DROP PROC dbo.spa_calc_shift_value
GO
CREATE PROC dbo.spa_calc_shift_value
	@as_of_date DATETIME
	, @sub_id VARCHAR(100)=NULL
	, @strategy_id VARCHAR(100)=NULL
	, @book_id VARCHAR(100)=NULl
	, @source_book_mapping_id VARCHAR (100)=NULL
	, @portfolio_group_id INT
	, @term_start DATETIME = null
	, @term_end DATETIME = NULL
	, @delta CHAR(1) = 'n'
	, @purge CHAR(1) = 'n'
	, @process_id VARCHAR(100) = NULL
	, @param VARCHAR(MAX) = NULL
AS
/*


IF OBJECT_ID('tempdb..#book') IS NOT NULL
DROP table #book
IF OBJECT_ID('tempdb..#tmp_deals') IS NOT NULL
DROP table #tmp_deals
IF OBJECT_ID('tempdb..#whatif_shift') IS NOT NULL
DROP table #whatif_shift
IF OBJECT_ID('tempdb..#tmp_commodity_shift') IS NOT NULL
DROP table #tmp_commodity_shift
IF OBJECT_ID('tempdb..#shift_val') IS NOT NULL
DROP table #shift_val
IF OBJECT_ID('tempdb..#tmp_final_shift') IS NOT NULL
DROP table #tmp_final_shift
IF OBJECT_ID('tempdb..#total_val') IS NOT NULL
DROP table #total_val
IF OBJECT_ID('tempdb..#tmp_final_calc_val') IS NOT NULL
DROP table #tmp_final_calc_val


DECLARE @as_of_date DATETIME = '2013-6-28'
	, @sub_id VARCHAR(100)=NULL
	, @strategy_id VARCHAR(100)=NULL
	, @book_id VARCHAR(100)=NULL
	, @source_book_mapping_id VARCHAR (100)=NULL
	, @portfolio_group_id INT = 6
	, @term_start DATETIME = NULL
	, @term_end DATETIME = NULL
	, @delta CHAR(1) = 'n'
	, @purge CHAR(1) = 'n'
	, @process_id VARCHAR(100) = '28E2B60B_1CCA_4A59_9AEC_B321FB5EA895'
	, @param VARCHAR(MAX) = NULL
	
--*/
DECLARE @simulation_days INT, 
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
	@commodity_shift_params_table VARCHAR(MAX)

SET @module = 'Shift Value Calculation'
SET @source = 'Shift Value Calculation'	
SET @errorcode = 's'

IF @process_id IS NULL
	SET @process_id = REPLACE(NEWID(), '-', '_')
IF @user_id IS NULL	
	SET @user_id = dbo.fnadbuser()

SELECT @commodity_shift_params_table = dbo.FNAProcessTableName('commodity_shift_params', @user_id, @process_id)

DECLARE @st_sql varchar(5000), @str_and VARCHAR(250)
SET @str_and = ''

BEGIN TRY
	--############# START COLLECTING DEALS ##################--
	IF OBJECT_ID('tempdb..#tmp_book_param_result') IS NOT NULL
		DROP table #tmp_book_param_result
	CREATE TABLE #tmp_book_param_result(
		[ID] [int] NULL,
		[Ref ID] [VARCHAR](100) NULL,
		[Deal Date][VARCHAR](50) NULL,
		[Ext ID] [VARCHAR](50) NULL,
		[Physical/Financial Flag] [VARCHAR](50) NULL,
		[Counterparty] [VARCHAR](100) NULL,
		[Entire Term Start][VARCHAR](50) NULL,
		[Entire Term End][VARCHAR](50) NULL,
		[Deal Type] [VARCHAR](100) NULL,
		[Deal Sub Type] [VARCHAR](100) NULL,
		[Option Flag] [VARCHAR](100) NULL,
		[Option Type] [VARCHAR](100) NULL,
		[Excercise Type] [VARCHAR](100) NULL,
		[Group1] [VARCHAR](50) NULL,
		[Group2] [VARCHAR](50) NULL,
		[Group3] [VARCHAR](50) NULL,
		[Group4] [VARCHAR](50) NULL,
		[Description 1] [VARCHAR](100) NULL,
		[Description 2] [VARCHAR](100) NULL,
		[Description 3] [VARCHAR](100) NULL,
		[Deal Category] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[Trader] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
		[Hedge/Item Flag] [VARCHAR](500) COLLATE DATABASE_DEFAULT NULL,
		[Hedge Type] [VARCHAR](500) COLLATE DATABASE_DEFAULT NULL,
		[Assign Type] [VARCHAR](500) COLLATE DATABASE_DEFAULT NULL,
		[Legal Entity] [INT] NULL,
		[Deal Locked] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[Pricing] [VARCHAR](500) COLLATE DATABASE_DEFAULT NULL,
		[Create TS] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[Confirm Status] [VARCHAR](500) COLLATE DATABASE_DEFAULT NULL,
		[Signed Off By] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
		[Verified Date] [DATETIME] NULL,
		[Broker] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
		[Comments] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
		[Commodity] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
		[Deal Rule] [INT] NULL,
		[Confirm Rule] [INT] NULL
	)

	CREATE TABLE #book(
		book_id                 INT,
		book_deal_type_map_id   INT,
		source_system_book_id1  INT,
		source_system_book_id2  INT,
		source_system_book_id3  INT,
		source_system_book_id4  INT,
		func_cur_id             INT
	)

	CREATE TABLE #tmp_deals(
		id INT IDENTITY(1,1),
		source_deal_header_id INT
	)

	CREATE TABLE #whatif_shift(
		source_curve_def_id INT,
		curve_shift_val FLOAT, 
		curve_shift_per FLOAT
	)

	IF COALESCE(@sub_id, @strategy_id, @book_id, @source_book_mapping_id) IS NOT NULL
	BEGIN
		SET @st_sql='
			INSERT INTO #book (
				book_id,
				book_deal_type_map_id,
				source_system_book_id1,
				source_system_book_id2,
				source_system_book_id3,
				source_system_book_id4,
				func_cur_id 
				)		
			SELECT
				book.entity_id,
				book_deal_type_map_id,
				source_system_book_id1,
				source_system_book_id2,
				source_system_book_id3,
				source_system_book_id4,
				fs.func_cur_value_id
			FROM source_system_book_map sbm            
				INNER JOIN portfolio_hierarchy book (NOLOCK) ON book.entity_id = sbm.fas_book_id
				INNER JOIN Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
				INNER JOIN Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
				LEFT JOIN fas_subsidiaries fs ON  sb.entity_id = fs.fas_subsidiary_id
			WHERE 1=1'
			--	AND sb.entity_id IN (' + @sub_id + ')
			--	AND stra.entity_id IN (' + @strategy_id + ')
			--	AND book.entity_id IN (' + @book_id + ')
			--	AND sbm.book_deal_type_map_id IN (' + @source_book_mapping_id + ')
			--'	
			+ CASE WHEN  @sub_id IS NULL THEN '' ELSE ' AND sb.entity_id IN (' + @sub_id + ')' END
			+ CASE WHEN  @strategy_id IS NULL THEN '' ELSE ' AND stra.entity_id IN (' + @strategy_id + ')' END
			+ CASE WHEN  @book_id IS NULL THEN '' ELSE ' AND book.entity_id IN (' + @book_id + ')' END
			+ CASE WHEN  @source_book_mapping_id IS NULL THEN '' ELSE ' AND sbm.book_deal_type_map_id IN (' + @source_book_mapping_id + ')' END
					
		EXEC spa_print @st_sql	
		EXEC(@st_sql)
	END
		
	IF @portfolio_group_id IS NOT NULL
	BEGIN
		DECLARE book_cursor CURSOR FOR
		--portfolio mapping book params
		SELECT book_parameter
		FROM portfolio_group_book
		WHERE portfolio_group_id = @portfolio_group_id
	
		FOR READ ONLY
	
		OPEN book_cursor
		FETCH NEXT FROM book_cursor INTO @book_parameter
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO #tmp_book_param_result 
			EXEC(@book_parameter)
		
			FETCH NEXT FROM book_cursor INTO @book_parameter
		END
		CLOSE book_cursor
		DEALLOCATE book_cursor
	END

	INSERT INTO #tmp_deals
	SELECT id deal_id FROM #tmp_book_param_result
	UNION
	SELECT deal_id
	FROM portfolio_group_deal
	WHERE portfolio_group_id = @portfolio_group_id
	UNION
	SELECT DISTINCT sdh.source_deal_header_id
	FROM source_deal_header sdh 
	INNER JOIN #book sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 
	AND sdh.source_system_book_id2 = sbm.source_system_book_id2 
	AND sdh.source_system_book_id3 = sbm.source_system_book_id3 
	AND sdh.source_system_book_id4 = sbm.source_system_book_id4 
	AND sdh.deal_date <= @as_of_date
	AND sdh.entire_term_end >= @as_of_date
	--========================================
	--test
	--SELECT '#tmp_deals',* FROM #tmp_deals td
	--test
	
	--IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_deals)
	--BEGIN 
	--	--INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
	--	SELECT  @process_id, 'Error', @module, @source, 'Shift Value Calculation', ' Deals are not found. ', 'Please check data.'
	--	RETURN
	--	--RAISERROR ('CatchError', 16, 1)
	--END

	--############# END COLLECTING DEALS ##################--

	--TRUNCATE TABLE #tmp_deals INSERT INTO #tmp_deals SELECT item FROM dbo.SplitCommaSeperatedValues('3134,3137,3341') scsv
	
	--RETURN
	--######## START COLLECTING SHIFT DETAILS #############--

	CREATE TABLE #tmp_commodity_shift (
		rnk int
		, commodity_id int null
		, shift_from float null
		, shift_to float null
		, shift_increment float null
	)
		
	SET @sql = '
	INSERT INTO #tmp_commodity_shift (rnk, commodity_id
				, shift_from
				, shift_to
				, shift_increment) 
	SELECT 	rnk, commodity_id
			, shift_from
			, shift_to
			, shift_increment 
	FROM ' + @commodity_shift_params_table 
	EXEC spa_print @sql	
	exec(@sql)

	--test
	--SELECT '#tmp_commodity_shift',* FROM #tmp_commodity_shift tcs
	--RETURN

		
	CREATE TABLE #shift_val(
		rnk INT,
		commodity_id INT, 
		shift_from FLOAT, 
		shift_to FLOAT, 
		shift_increment FLOAT
		)

	;WITH user_rec(rnk, commodity_id, shift_from, shift_to, shift_increment) AS (
		SELECT rnk, commodity_id, shift_from, shift_to, shift_increment FROM #tmp_commodity_shift
		UNION ALL 
		SELECT rnk, commodity_id, shift_from + shift_increment, shift_to, shift_increment FROM user_rec 
		WHERE shift_from + shift_increment <= shift_to AND user_rec.shift_increment <> 0
	)
	INSERT INTO #shift_val
	--SELECT RANK() OVER (ORDER BY commodity_id) rnk, * FROM user_rec ORDER BY commodity_id
	SELECT * FROM user_rec ORDER BY commodity_id
	OPTION (MAXRECURSION 0)
	
	--test	
	--SELECT '#shift_val',* FROM #shift_val
		
	--IF NOT EXISTS(SELECT TOP 1 1 FROM #shift_val)
	--BEGIN 
	--	--INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
	--	SELECT  @process_id, 'Error', @module, @source, 'Shift Value Calculation', ' Shift value not found', 'Please check data.'
	--	RETURN
	--	--RAISERROR ('CatchError', 16, 1)
	--END

	CREATE TABLE #tmp_final_shift(
		commodity_one INT, 
		commodity_two INT, 
		shift_one FLOAT, 
		shift_two FLOAT
		)

	IF ((SELECT COUNT(DISTINCT rnk) FROM #tmp_commodity_shift) > 1)
		INSERT INTO #tmp_final_shift
		SELECT sv.commodity_id commodity_one, t.commodity_id commodity_two, sv.shift_from shift_one, t.shift_from shift_two FROM #shift_val sv
		CROSS APPLY(SELECT * FROM #shift_val WHERE rnk > sv.rnk) t
		WHERE sv.rnk <> t.rnk --sv.commodity_id <> t.commodity_id 
		ORDER BY sv.commodity_id, t.commodity_id, sv.shift_from, t.shift_from
	ELSE
		INSERT INTO #tmp_final_shift
		SELECT commodity_id, NULL, shift_from, NULL FROM #shift_val

	--######## END COLLECTING SHIFT DETAILS #############--
	--test
	--SELECT '#tmp_final_shift',* FROM #tmp_final_shift
	--######## START TAKING INDEX VALUES ################--
	CREATE TABLE #total_val(
		commodity_id INT,
		value FLOAT
		)

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
			
	
	EXEC spa_print @st_sql	
	EXEC(@st_sql)
	
	--test
	--SELECT '#total_val',* FROM #total_val 
	
	--IF NOT EXISTS(SELECT TOP 1 1 FROM #total_val)
	--BEGIN 
	--	--INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
	--	SELECT  @process_id, 'Error', @module, @source, 'Shift Value Calculation', ' Index value not found for as of date: ' 
	--	+ dbo.FNADateFormat(@as_of_date), 'Please check data.'
	--	RETURN
	--	--RAISERROR ('CatchError', 16, 1)
	--END

	--######## END TAKING INDEX VALUES ################--
		
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
		SELECT tfs.commodity_one, tfs.commodity_two,
			tfs.shift_one,
			tfs.shift_two, 
			tv.value value_one,
			tv1.value value_two, 
			tv.value*(tfs.shift_one / 100) delta_one,
			tv1.value*(tfs.shift_two / 100) delta_two,
			tv2.value fixed_value,
			(tv.value*(tfs.shift_one / 100) + ISNULL(tv1.value*(tfs.shift_two / 100), 0)) delta_total
		FROM #tmp_final_shift tfs
		LEFT JOIN #total_val tv ON tv.commodity_id = tfs.commodity_one
		LEFT JOIN #total_val tv1 ON tv1.commodity_id = tfs.commodity_two
		OUTER APPLY(SELECT value FROM #total_val WHERE commodity_id = -1) tv2
	END
	ELSE
	BEGIN
		INSERT INTO #tmp_final_calc_val
		SELECT tfs.commodity_one, tfs.commodity_two,
			tfs.shift_one,
			tfs.shift_two, 
			tv.value value_one,
			tv1.value value_two, 
			tv.value*(1 + (tfs.shift_one) / 100) calc_value_one,
			tv1.value*(1 + (tfs.shift_two) / 100) calc_value_two,
			tv2.value fixed_value,
			--tv3.value other_value,
			tv.value*(1 + (tfs.shift_one / 100)) + ISNULL(tv1.value*(1 + (tfs.shift_two / 100)), 0) + ISNULL(tv2.value, 0) + isnull(tv3.value,0) total_value
		FROM #tmp_final_shift tfs
		LEFT JOIN #total_val tv ON tv.commodity_id = tfs.commodity_one
		LEFT JOIN #total_val tv1 ON tv1.commodity_id = tfs.commodity_two
		OUTER APPLY(SELECT value FROM #total_val WHERE commodity_id = -1) tv2
		OUTER APPLY(SELECT value FROM #total_val 
					WHERE	commodity_id <> -1 
							AND commodity_id <> tfs.commodity_one 
							AND commodity_id <> isnull(tfs.commodity_two,-99)) tv3

	END
		

	IF OBJECT_ID(N'tempdb..#tmp_result') IS NOT NULL
	BEGIN
	EXEC spa_print '***here***'
		insert into #tmp_result 
		SELECT cast(@as_of_date AS datetime) as_of_date, * FROM #tmp_final_calc_val
	END 
	ELSE
	BEGIN
		SELECT cast(@as_of_date AS datetime) as_of_date, * FROM #tmp_final_calc_val
	END
		
		
	--SET @desc = 'MTM Simulation Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + '.'	
	--SET @errorcode = 's'
		
	--INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps) 
	--SELECT  @process_id, 'Success', @module, @source, 'Shift Value Calculation', ' Shift Value Calculation done for as of date: ' 
	--+ dbo.FNADateFormat(@as_of_date), 'Please check data.'
END TRY

BEGIN CATCH 
	EXEC spa_print 'Catch Error:'-- + ERROR_MESSAGE()
	IF @@TRANCOUNT > 0
		ROLLBACK
	--PRINT @process_id
	SET @errorcode = 'e'
	--PRINT ERROR_LINE()
	SET @desc = 'Shift Value Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_id) + ' (ERRORS found).'
	--PRINT @desc
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
		''Shift Value Calculation'''
END CATCH

--IF @errorcode = 'e'
--BEGIN
--	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'

--	SET @url_desc = '<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''+@process_id+'''">Click here...</a>'
--	SELECT 'Error' ErrorCode, 'Calculate Shift Value' MODULE, 
--			'spa_calc_shift_value' Area, 'DB Error' Status, 'Shift Value Calculation process is completed with error, Please view this report. ' + @url_desc MESSAGE, '' Recommendation
--END
--ELSE
--BEGIN
--	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_id + '&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'',
--		''Shift Value Calculation'''
	
--	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'
--	EXEC spa_ErrorHandler 0, 'Shift Value Calculation', 'Shift Value Calculation', 'Success', @desc, ''
--END

--EXEC spa_message_board 
--	'i', 
--	@user_id,
--	NULL, 
--	'Shift Value Calculation',
--	@desc, 
--	'', 
--	'', 
--	@errorcode, 
--	'Shift Value Calculation',
--	NULL,
--	@process_id
