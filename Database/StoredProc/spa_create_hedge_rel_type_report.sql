IF OBJECT_ID(N'spa_create_hedge_rel_type_report', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_create_hedge_rel_type_report]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_create_hedge_rel_type_report]
	@subsidiary_id VARCHAR(MAX) = NULL,
	@strategy_id VARCHAR(MAX) = NULL, 
	@book_id VARCHAR(MAX) = NULL,
	@eff_test_profile_id VARCHAR(100) = NULL,
	@is_approved CHAR(1),
	@is_active CHAR(1),
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS

SET NOCOUNT ON

/**
DECLARE @subsidiary_id VARCHAR(MAX) = NULL,
	@strategy_id VARCHAR(MAX) = NULL, 
	@book_id VARCHAR(MAX) = NULL,
	@eff_test_profile_id VARCHAR(100) = NULL,
	@is_approved CHAR(1),
	@is_active CHAR(1),
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL

-- EXEC spa_create_hedge_rel_type_report '1', '3', '10', '4', 'y', 'y'
-- EXEC spa_create_hedge_rel_type_report NULL, NULL, NULL, '4', 'y', 'y'
-- EXEC spa_create_hedge_rel_type_report NULL, NULL, NULL, '4 - HH-CNG FOR: RSQ', 'y', 'y'
--*/

DECLARE @sql_stmt AS VARCHAR(MAX)
DECLARE @sql_stmt1 AS VARCHAR(MAX)
DECLARE @w_sql_stmt AS VARCHAR(MAX)

/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
			 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser()

SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

IF @enable_paging = 1 --paging processing
BEGIN
	IF @batch_process_id IS NULL
		SET @batch_process_id = dbo.FNAGetNewID()
		
	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

	--retrieve data from paging table instead of main table
	IF @page_no IS NOT NULL
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)
		EXEC (@sql_paging)
		RETURN
	END
END
/*******************************************1st Paging Batch END**********************************************/

--set where clauses
SET @w_sql_stmt = ''
IF @subsidiary_id IS NOT NULL
	SET @w_sql_stmt = @w_sql_stmt + ' AND sub.entity_id IN (' + @subsidiary_id + ')'
IF @strategy_id IS NOT NULL
	SET @w_sql_stmt = @w_sql_stmt + ' AND strategy.entity_id IN (' + @strategy_id + ')'
IF @book_id IS NOT NULL
	SET @w_sql_stmt = @w_sql_stmt + ' AND book.entity_id IN (' + @book_id + ')'
IF @eff_test_profile_id IS NOT NULL
	SET @w_sql_stmt = @w_sql_stmt + ' AND f.eff_test_profile_id IN (' + @eff_test_profile_id + ') '
IF @is_approved IS NOT NULL
	SET @w_sql_stmt = @w_sql_stmt +  ' AND upper(f.profile_approved) = upper(''' + @is_approved + ''')'
IF @is_active IS NOT NULL
	SET @w_sql_stmt = @w_sql_stmt + ' AND upper(f.profile_active) = upper(''' + @is_active + ''')'

SET @sql_stmt1  = '
	(
		SELECT f.eff_test_profile_id eff_test_profile_id,
			f.inherit_assmt_eff_test_profile_id inherit_assmt_eff_test_profile_id,
			COALESCE(fi.eff_test_profile_id, f.eff_test_profile_id) used_eff_test_profile_id,
			COALESCE(fi.fas_book_id, f.fas_book_id) fas_book_id,
			COALESCE(fi.eff_test_name, f.eff_test_name) eff_test_name,
			--dbo.FNAHyperLinkText(10232000,COALESCE(fi.eff_test_name, f.eff_test_name), COALESCE(fi.eff_test_profile_id, f.eff_test_profile_id)) eff_test_name,
			COALESCE(fi.init_eff_test_approach_value_id, f.init_eff_test_approach_value_id) init_eff_test_approach_value_id,
			COALESCE(fi.init_assmt_curve_type_value_id, f.init_assmt_curve_type_value_id) init_assmt_curve_type_value_id,
			COALESCE(fi.init_curve_source_value_id, f.init_curve_source_value_id) init_curve_source_value_id,
			COALESCE(fi.init_number_of_curve_points, f.init_number_of_curve_points) init_number_of_curve_points,
			COALESCE(fi.on_eff_test_approach_value_id, f.on_eff_test_approach_value_id) on_eff_test_approach_value_id,
			COALESCE(fi.on_assmt_curve_type_value_id, f.on_assmt_curve_type_value_id) on_assmt_curve_type_value_id,
			COALESCE(fi.on_curve_source_value_id, f.on_curve_source_value_id) on_curve_source_value_id,
			COALESCE(fi.on_number_of_curve_points, f.on_number_of_curve_points) on_number_of_curve_points,
			COALESCE(fi.effective_start_date, f.effective_start_date) effective_start_date,
			COALESCE(fi.effective_end_date, f.effective_end_date) effective_end_date,
			COALESCE(fi.profile_approved_by, f.profile_approved_by) profile_approved_by,
			COALESCE(fi.item_test_price_option_value_id, f.item_test_price_option_value_id) item_test_price_option_value_id,
			COALESCE(fi.individual_link_calc, f.individual_link_calc) individual_link_calc,
			COALESCE(fi.profile_approved, f.profile_approved) profile_approved,
			COALESCE(fi.profile_active, f.profile_active) profile_active
		FROM fas_eff_hedge_rel_type f
		LEFT OUTER JOIN fas_eff_hedge_rel_type fi ON fi.eff_test_profile_id = f.inherit_assmt_eff_test_profile_id
		INNER JOIN portfolio_hierarchy book ON book.entity_id = f.fas_book_id
		INNER JOIN portfolio_hierarchy strategy ON book.parent_entity_id = strategy.entity_id
		INNER JOIN portfolio_hierarchy sub ON strategy.parent_entity_id = sub.entity_id
		WHERE 1 = 1 ' + @w_sql_stmt + '
	)'

CREATE TABLE #strip_month(
	value_id VARCHAR(4) COLLATE DATABASE_DEFAULT,
	code VARCHAR(10) COLLATE DATABASE_DEFAULT
)

INSERT INTO #strip_month
SELECT 'jan','January' UNION ALL
SELECT 'feb','February' UNION ALL
SELECT 'mar','March' UNION ALL
SELECT 'apr','April' UNION ALL
SELECT 'may','May' UNION ALL
SELECT 'jun','June' UNION ALL
SELECT 'jul','July' UNION ALL
SELECT 'aug','August' UNION ALL
SELECT 'sep','September' UNION ALL
SELECT 'oct','October' UNION ALL
SELECT 'nov','November' UNION ALL
SELECT 'dec','December'

--exec (@sql_stmt1)
--print(@sql_stmt1)

SET @sql_stmt = '
	SELECT sub.entity_name Sub,
		strategy.entity_name Strategy,
		book.entity_name Book,
		sb1.source_book_name + ''|'' + sb2.source_book_name + ''|'' + sb3.source_book_name + ''|'' + sb4.source_book_name [Source Book Mapping], 
		f.eff_test_profile_id [Relationship Type ID],
		--inherit_assmt_eff_test_profile_id [Inherit Type ID],
		--eff_test_name AS [Relationship Type],
		dbo.FNATRMWinHyperlink(''a'', 10231900, eff_test_name, ABS(fld.eff_test_profile_id),null,null,null,null,null,null,null,null,null,null,null,0) AS [Relationship Type],
		iasmt_type.code As [Inherit Assessment Type],
		iasmt_ap.code As [Inherit Series Type],
		init_number_of_curve_points [Inherit Series Points],
		iasmt_ap.code As [Ongoing Assessment Type],
		oasmt_type.code As [Ongoing Series Type],
		on_number_of_curve_points [Ongoing Series Points],
		case when(fld.hedge_or_item = ''h'') then ''Hedge'' when fld.hedge_or_item = ''i'' then ''Item'' else null end as [Hedge/Item],
		fld.deal_sequence_number as [Sequence No],
		fld.leg Leg,
		case when(fld.fixed_float_flag = ''f'') then ''Fixed'' when fld.fixed_float_flag = ''t'' THEN ''Float''	ELSE null end [Fixed/Float],
		case when (fld.buy_sell_flag = ''b'')  then ''Buy'' when fld.buy_sell_flag = ''s'' then ''Sell'' else null end [Buy/Sell],
		curve.curve_name [Index],
		stm.code [Month From],
		stm1.code [Month To],
		fld.volume_mix_percentage [Mix Percentage]
	' + @str_batch_table  + '
	FROM ' + @sql_stmt1 + ' f
	LEFT OUTER JOIN fas_eff_hedge_rel_type_detail fld ON f.used_eff_test_profile_id = fld.eff_test_profile_id
	INNER JOIN portfolio_hierarchy book ON book.entity_id = f.fas_book_id
	INNER JOIN portfolio_hierarchy strategy ON book.parent_entity_id = strategy.entity_id
	INNER JOIN portfolio_hierarchy sub ON strategy.parent_entity_id = sub.entity_id 
	LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = fld.book_deal_type_map_id 
	LEFT JOIN source_book sb1 ON sb1.source_book_id = ssbm.source_system_book_id1 
	LEFT JOIN source_book sb2 ON sb2.source_book_id = ssbm.source_system_book_id2
	LEFT JOIN source_book sb3 ON sb3.source_book_id = ssbm.source_system_book_id3
	LEFT JOIN source_book sb4 ON sb4.source_book_id = ssbm.source_system_book_id4
	LEFT OUTER JOIN static_data_Value iasmt_type ON iasmt_type.value_id = f.init_eff_test_approach_value_id
	LEFT OUTER JOIN static_data_Value iasmt_ap ON iasmt_ap.value_id = f.init_assmt_curve_type_value_id
	LEFT OUTER JOIN static_data_Value oasmt_type ON oasmt_type.value_id = f.on_eff_test_approach_value_id
	LEFT OUTER JOIN static_data_Value oasmt_ap ON oasmt_ap.value_id = f.on_assmt_curve_type_value_id
	LEFT OUTER JOIN source_price_curve_def	curve on curve.source_curve_def_id = fld.source_curve_def_id
	LEFT JOIN #strip_month stm ON stm.value_id = fld.strip_month_from
	LEFT JOIN #strip_month stm1 ON stm1.value_id = fld.strip_month_to
	WHERE 1 = 1 '
	-- SET @w_sql_stmt = ''
	-- If @subsidiary_id IS NOT NULL
	-- 	SET @w_sql_stmt = @w_sql_stmt + ' AND sub.entity_id IN (' + @subsidiary_id + ')'
	-- If @strategy_id IS NOT NULL
	-- 	SET @w_sql_stmt = @w_sql_stmt + ' AND strategy.entity_id IN (' + @strategy_id + ')'
	-- If @book_id IS NOT NULL
	-- 	SET @w_sql_stmt = @w_sql_stmt + ' AND book.entity_id IN (' + @book_id + ')'
	-- If @eff_test_profile_id IS NOT NULL
	-- 	SET @w_sql_stmt = @w_sql_stmt + ' AND f.eff_test_profile_id IN (' + @eff_test_profile_id + ')'
	-- If @is_approved IS NOT NULL
	-- 	SET @w_sql_stmt = @w_sql_stmt +  ' AND upper(f.profile_approved) = upper(''' + @is_approved + ''')'
	-- If @is_active IS NOT NULL
	-- 	SET @w_sql_stmt = @w_sql_stmt + ' AND upper(f.profile_active) = upper(''' + @is_active + ''')'

	SET @sql_stmt = @sql_stmt + @w_sql_stmt
	SET @sql_stmt = @sql_stmt + '
		ORDER BY sub.entity_name, strategy.entity_name, book.entity_name, f.eff_test_profile_id, fld.hedge_or_item, fld.deal_sequence_number, fld.leg'

	--PRINT '**' + @sql_stmt
	EXEC (@sql_stmt)

	IF @@ERROR <> 0
	EXEC spa_ErrorHandler @@ERROR, 'Fas Link detail table', 
		'spa_fas_link)detail', 'DB Error', 
		'Failed to select Link detail record.', ''

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)
	EXEC(@str_batch_table)

	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_create_hedge_rel_type_report', 'Hedging Relationship Types Report')
	EXEC(@str_batch_table)
	RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/

GO