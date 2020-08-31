IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_shift_map_gl_codes]') AND [type] IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_shift_map_gl_codes] 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_shift_map_gl_codes]
	@fas_strategy_id INT = NULL,
	@gl_grouping_value_id INT = NULL,
	@process_table VARCHAR(500) = NULL
AS
/*---------------Debug Section--------------------
--351	Grouped at Book
--352	Grouped at SBM
--350	Grouped at Strategy

DECLARE @fas_strategy_id INT,
		@gl_grouping_value_id INT,
		@process_table VARCHAR(500) = NULL

SELECT @fas_strategy_id = 1366,
	   @gl_grouping_value_id = 351,
	   @process_table = NULL--'adiha_process.dbo.map_gl_codes_farrms_admin_0099ERDA_23DFSF_SDFFSS_345TR'
------------------------------------------------*/

IF @gl_grouping_value_id = 350 --Move GL Codes to Strategy
BEGIN
	DECLARE @sql_string VARCHAR(MAX)
	
	SET @sql_string = '
		UPDATE fs
		SET fs.gl_id_amortization = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_id_amortization, ' ELSE '' END + 'sbmgc.gl_id_amortization, fb.gl_id_amortization, fs.gl_id_amortization ),
			fs.gl_id_interest = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_id_interest, ' ELSE '' END + 'sbmgc.gl_id_interest, fb.gl_id_interest, fs.gl_id_interest ),
			fs.gl_id_lt_tax_asset = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_id_lt_tax_asset, ' ELSE '' END + 'sbmgc.gl_id_lt_tax_asset, fb.gl_id_lt_tax_asset, fs.gl_id_lt_tax_asset ),
			fs.gl_id_lt_tax_liab = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_id_lt_tax_liab, ' ELSE '' END + 'sbmgc.gl_id_lt_tax_liab, fb.gl_id_lt_tax_liab, fs.gl_id_lt_tax_liab ),
			fs.gl_id_st_tax_asset = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_id_st_tax_asset, ' ELSE '' END + 'sbmgc.gl_id_st_tax_asset, fb.gl_id_st_tax_asset, fs.gl_id_st_tax_asset ),
			fs.gl_id_st_tax_liab = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_id_st_tax_liab, ' ELSE '' END + 'sbmgc.gl_id_st_tax_liab, fb.gl_id_st_tax_liab, fs.gl_id_st_tax_liab ),
			fs.gl_id_tax_reserve = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_id_tax_reserve, ' ELSE '' END + 'sbmgc.gl_id_tax_reserve, fb.gl_id_tax_reserve, fs.gl_id_tax_reserve ),
			fs.gl_number_id_aoci = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_aoci, ' ELSE '' END + 'sbmgc.gl_number_id_aoci, fb.gl_number_id_aoci, fs.gl_number_id_aoci ),
			fs.gl_number_id_cash = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_cash, ' ELSE '' END + 'sbmgc.gl_number_id_cash, fb.gl_number_id_cash, fs.gl_number_id_cash ),
			fs.gl_number_id_expense = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_expense, ' ELSE '' END + 'sbmgc.gl_number_id_expense, fb.gl_number_id_expense, fs.gl_number_id_expense ),
			fs.gl_number_id_gross_set = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_gross_set, ' ELSE '' END + 'sbmgc.gl_number_id_gross_set, fb.gl_number_id_gross_set, fs.gl_number_id_gross_set ),
			fs.gl_number_id_inventory = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_inventory, ' ELSE '' END + 'sbmgc.gl_number_id_inventory, fb.gl_number_id_inventory, fs.gl_number_id_inventory ),
			fs.gl_number_id_item_lt_asset = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_item_lt_asset, ' ELSE '' END + 'sbmgc.gl_number_id_item_lt_asset, fb.gl_number_id_item_lt_asset, fs.gl_number_id_item_lt_asset ),
			fs.gl_number_id_item_lt_liab = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_item_lt_liab, ' ELSE '' END + 'sbmgc.gl_number_id_item_lt_liab, fb.gl_number_id_item_lt_liab, fs.gl_number_id_item_lt_liab ),
			fs.gl_number_id_item_st_asset = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_item_st_asset, ' ELSE '' END + 'sbmgc.gl_number_id_item_st_asset, fb.gl_number_id_item_st_asset, fs.gl_number_id_item_st_asset ),
			fs.gl_number_id_item_st_liab = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_item_st_liab, ' ELSE '' END + 'sbmgc.gl_number_id_item_st_liab, fb.gl_number_id_item_st_liab, fs.gl_number_id_item_st_liab ),
			fs.gl_number_id_lt_asset = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_lt_asset, ' ELSE '' END + 'sbmgc.gl_number_id_lt_asset, fb.gl_number_id_lt_asset, fs.gl_number_id_lt_asset ),
			fs.gl_number_id_lt_liab = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_lt_liab, ' ELSE '' END + 'sbmgc.gl_number_id_lt_liab, fb.gl_number_id_lt_liab, fs.gl_number_id_lt_liab ),
			fs.gl_number_id_pnl = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_pnl, ' ELSE '' END + 'sbmgc.gl_number_id_pnl, fb.gl_number_id_pnl, fs.gl_number_id_pnl ),
			fs.gl_number_id_set = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_set, ' ELSE '' END + 'sbmgc.gl_number_id_set, fb.gl_number_id_set, fs.gl_number_id_set ),
			fs.gl_number_id_st_asset = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_st_asset, ' ELSE '' END + 'sbmgc.gl_number_id_st_asset, fb.gl_number_id_st_asset, fs.gl_number_id_st_asset ),
			fs.gl_number_id_st_liab = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_id_st_liab, ' ELSE '' END + 'sbmgc.gl_number_id_st_liab, fb.gl_number_id_st_liab, fs.gl_number_id_st_liab ),
			fs.gl_number_unhedged_der_lt_asset = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_unhedged_der_lt_asset, ' ELSE '' END + 'sbmgc.gl_number_unhedged_der_lt_asset, fb.gl_number_unhedged_der_lt_asset, fs.gl_number_unhedged_der_lt_asset),
			fs.gl_number_unhedged_der_lt_liab = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_unhedged_der_lt_liab, ' ELSE '' END + 'sbmgc.gl_number_unhedged_der_lt_liab, fb.gl_number_unhedged_der_lt_liab, fs.gl_number_unhedged_der_lt_liab ),
			fs.gl_number_unhedged_der_st_asset = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_unhedged_der_st_asset, ' ELSE '' END + 'sbmgc.gl_number_unhedged_der_st_asset, fb.gl_number_unhedged_der_st_asset, fs.gl_number_unhedged_der_st_asset),
			fs.gl_number_unhedged_der_st_liab = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_number_unhedged_der_st_liab, ' ELSE '' END + 'sbmgc.gl_number_unhedged_der_st_liab, fb.gl_number_unhedged_der_st_liab, fs.gl_number_unhedged_der_st_liab ),
			fs.gl_first_day_pnl = COALESCE(' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN ' tmp.gl_first_day_pnl, ' ELSE '' END + 'sbmgc.gl_first_day_pnl, fb.gl_first_day_pnl, fs.gl_first_day_pnl )
		FROM fas_strategy fs 
		LEFT JOIN portfolio_hierarchy stra
			ON stra.[entity_id] = fs.fas_strategy_id
		LEFT JOIN portfolio_hierarchy book
			on book.parent_entity_id = stra.[entity_id]
		LEFT JOIN source_system_book_map ssbm
			ON ssbm.fas_book_id = book.[entity_id]
		LEFT JOIN fas_books fb
			ON fb.fas_book_id = book.[entity_id]
		LEFT JOIN source_book_map_GL_codes sbmgc
			ON sbmgc.source_book_map_id = ssbm.book_deal_type_map_id
		' + CASE WHEN NULLIF(@process_table, '') IS NOT NULL THEN '
		OUTER APPLY (
			SELECT * FROM ' + @process_table + '
		) tmp ' 
		ELSE '' END +
		+ '
		WHERE fas_strategy_id = ' + CAST(@fas_strategy_id AS VARCHAR(10))

	EXEC(@sql_string)

	DELETE sbmgc
	FROM fas_strategy fs 
	LEFT JOIN portfolio_hierarchy stra
		ON stra.[entity_id] = fs.fas_strategy_id
	LEFT JOIN portfolio_hierarchy book
		ON book.parent_entity_id = stra.[entity_id]
	LEFT JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.[entity_id]
	LEFT JOIN fas_books fb
		ON fb.fas_book_id = book.[entity_id]
	LEFT JOIN source_book_map_GL_codes sbmgc
		ON sbmgc.source_book_map_id = ssbm.book_deal_type_map_id
	WHERE fas_strategy_id = @fas_strategy_id

	UPDATE fb
	SET fb.gl_id_amortization = NULL,
		fb.gl_id_interest = NULL,
		fb.gl_id_lt_tax_asset = NULL,
		fb.gl_id_lt_tax_liab = NULL,
		fb.gl_id_st_tax_asset = NULL,
		fb.gl_id_st_tax_liab = NULL,
		fb.gl_id_tax_reserve = NULL,
		fb.gl_number_id_aoci = NULL,
		fb.gl_number_id_cash = NULL,
		fb.gl_number_id_expense = NULL,
		fb.gl_number_id_gross_set = NULL,
		fb.gl_number_id_inventory = NULL,
		fb.gl_number_id_item_lt_asset = NULL,
		fb.gl_number_id_item_lt_liab = NULL,
		fb.gl_number_id_item_st_asset = NULL,
		fb.gl_number_id_item_st_liab = NULL,
		fb.gl_number_id_lt_asset = NULL,
		fb.gl_number_id_lt_liab = NULL,
		fb.gl_number_id_pnl = NULL,
		fb.gl_number_id_set = NULL,
		fb.gl_number_id_st_asset = NULL,
		fb.gl_number_id_st_liab = NULL,
		fb.gl_number_unhedged_der_lt_asset = NULL,
		fb.gl_number_unhedged_der_lt_liab = NULL,
		fb.gl_number_unhedged_der_st_asset = NULL,
		fb.gl_number_unhedged_der_st_liab = NULL,
		fb.gl_first_day_pnl = NULL
	FROM fas_strategy fs 
	LEFT JOIN portfolio_hierarchy stra
		ON stra.[entity_id] = fs.fas_strategy_id
	LEFT JOIN portfolio_hierarchy book
		on book.parent_entity_id = stra.[entity_id]
	LEFT JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.[entity_id]
	LEFT JOIN fas_books fb
		ON fb.fas_book_id = book.[entity_id]
	WHERE fas_strategy_id = @fas_strategy_id

	EXEC spa_ErrorHandler 0, 'Source Deal Detail', 'spa_shift_map_gl_codes', 'Success', 'Changes have been saved successfully.', @fas_strategy_id
END
ELSE IF @gl_grouping_value_id = 351 --Move GL Codes to Book
BEGIN
	UPDATE fb
	SET fb.gl_id_amortization = COALESCE(sbmgc.gl_id_amortization, fs.gl_id_amortization, fb.gl_id_amortization ),
		fb.gl_id_interest = COALESCE(sbmgc.gl_id_interest, fs.gl_id_interest, fb.gl_id_interest ),
		fb.gl_id_lt_tax_asset = COALESCE(sbmgc.gl_id_lt_tax_asset, fs.gl_id_lt_tax_asset, fb.gl_id_lt_tax_asset ),
		fb.gl_id_lt_tax_liab = COALESCE(sbmgc.gl_id_lt_tax_liab, fs.gl_id_lt_tax_liab, fb.gl_id_lt_tax_liab ),
		fb.gl_id_st_tax_asset = COALESCE(sbmgc.gl_id_st_tax_asset, fs.gl_id_st_tax_asset, fb.gl_id_st_tax_asset ),
		fb.gl_id_st_tax_liab = COALESCE(sbmgc.gl_id_st_tax_liab, fs.gl_id_st_tax_liab, fb.gl_id_st_tax_liab ),
		fb.gl_id_tax_reserve = COALESCE(sbmgc.gl_id_tax_reserve, fs.gl_id_tax_reserve, fb.gl_id_tax_reserve ),
		fb.gl_number_id_aoci = COALESCE(sbmgc.gl_number_id_aoci, fs.gl_number_id_aoci, fb.gl_number_id_aoci ),
		fb.gl_number_id_cash = COALESCE(sbmgc.gl_number_id_cash, fs.gl_number_id_cash, fb.gl_number_id_cash ),
		fb.gl_number_id_expense = COALESCE(sbmgc.gl_number_id_expense, fs.gl_number_id_expense, fb.gl_number_id_expense ),
		fb.gl_number_id_gross_set = COALESCE(sbmgc.gl_number_id_gross_set, fs.gl_number_id_gross_set, fb.gl_number_id_gross_set ),
		fb.gl_number_id_inventory = COALESCE(sbmgc.gl_number_id_inventory, fs.gl_number_id_inventory, fb.gl_number_id_inventory ),
		fb.gl_number_id_item_lt_asset = COALESCE(sbmgc.gl_number_id_item_lt_asset, fs.gl_number_id_item_lt_asset, fb.gl_number_id_item_lt_asset ),
		fb.gl_number_id_item_lt_liab = COALESCE(sbmgc.gl_number_id_item_lt_liab, fs.gl_number_id_item_lt_liab, fb.gl_number_id_item_lt_liab ),
		fb.gl_number_id_item_st_asset = COALESCE(sbmgc.gl_number_id_item_st_asset, fs.gl_number_id_item_st_asset, fb.gl_number_id_item_st_asset ),
		fb.gl_number_id_item_st_liab = COALESCE(sbmgc.gl_number_id_item_st_liab, fs.gl_number_id_item_st_liab, fb.gl_number_id_item_st_liab ),
		fb.gl_number_id_lt_asset = COALESCE(sbmgc.gl_number_id_lt_asset, fs.gl_number_id_lt_asset, fb.gl_number_id_lt_asset ),
		fb.gl_number_id_lt_liab = COALESCE(sbmgc.gl_number_id_lt_liab, fs.gl_number_id_lt_liab, fb.gl_number_id_lt_liab ),
		fb.gl_number_id_pnl = COALESCE(sbmgc.gl_number_id_pnl, fs.gl_number_id_pnl, fb.gl_number_id_pnl ),
		fb.gl_number_id_set = COALESCE(sbmgc.gl_number_id_set, fs.gl_number_id_set, fb.gl_number_id_set ),
		fb.gl_number_id_st_asset = COALESCE(sbmgc.gl_number_id_st_asset, fs.gl_number_id_st_asset, fb.gl_number_id_st_asset ),
		fb.gl_number_id_st_liab = COALESCE(sbmgc.gl_number_id_st_liab, fs.gl_number_id_st_liab, fb.gl_number_id_st_liab ),
		fb.gl_number_unhedged_der_lt_asset = COALESCE(sbmgc.gl_number_unhedged_der_lt_asset, fs.gl_number_unhedged_der_lt_asset, fb.gl_number_unhedged_der_lt_asset),
		fb.gl_number_unhedged_der_lt_liab = COALESCE(sbmgc.gl_number_unhedged_der_lt_liab, fs.gl_number_unhedged_der_lt_liab, fb.gl_number_unhedged_der_lt_liab ),
		fb.gl_number_unhedged_der_st_asset = COALESCE(sbmgc.gl_number_unhedged_der_st_asset, fs.gl_number_unhedged_der_st_asset, fb.gl_number_unhedged_der_st_asset),
		fb.gl_number_unhedged_der_st_liab = COALESCE(sbmgc.gl_number_unhedged_der_st_liab, fs.gl_number_unhedged_der_st_liab, fb.gl_number_unhedged_der_st_liab ),
		fb.gl_first_day_pnl = COALESCE(sbmgc.gl_first_day_pnl, fs.gl_first_day_pnl, fb.gl_first_day_pnl )
	FROM fas_strategy fs 
	LEFT JOIN portfolio_hierarchy stra
		ON stra.[entity_id] = fs.fas_strategy_id
	LEFT JOIN portfolio_hierarchy book
		on book.parent_entity_id = stra.[entity_id]
	LEFT JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.[entity_id]
	LEFT JOIN fas_books fb
		ON fb.fas_book_id = book.[entity_id]
	LEFT JOIN source_book_map_GL_codes sbmgc
		ON sbmgc.source_book_map_id = ssbm.book_deal_type_map_id
	WHERE fas_strategy_id = @fas_strategy_id

	DELETE sbmgc
	FROM fas_strategy fs 
	LEFT JOIN portfolio_hierarchy stra
		ON stra.[entity_id] = fs.fas_strategy_id
	LEFT JOIN portfolio_hierarchy book
		ON book.parent_entity_id = stra.[entity_id]
	LEFT JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.[entity_id]
	LEFT JOIN fas_books fb
		ON fb.fas_book_id = book.[entity_id]
	LEFT JOIN source_book_map_GL_codes sbmgc
		ON sbmgc.source_book_map_id = ssbm.book_deal_type_map_id
	WHERE fas_strategy_id = @fas_strategy_id

	UPDATE fs
	SET fs.gl_id_amortization = NULL,
		fs.gl_id_interest = NULL,
		fs.gl_id_lt_tax_asset = NULL,
		fs.gl_id_lt_tax_liab = NULL,
		fs.gl_id_st_tax_asset = NULL,
		fs.gl_id_st_tax_liab = NULL,
		fs.gl_id_tax_reserve = NULL,
		fs.gl_number_id_aoci = NULL,
		fs.gl_number_id_cash = NULL,
		fs.gl_number_id_expense = NULL,
		fs.gl_number_id_gross_set = NULL,
		fs.gl_number_id_inventory = NULL,
		fs.gl_number_id_item_lt_asset = NULL,
		fs.gl_number_id_item_lt_liab = NULL,
		fs.gl_number_id_item_st_asset = NULL,
		fs.gl_number_id_item_st_liab = NULL,
		fs.gl_number_id_lt_asset = NULL,
		fs.gl_number_id_lt_liab = NULL,
		fs.gl_number_id_pnl = NULL,
		fs.gl_number_id_set = NULL,
		fs.gl_number_id_st_asset = NULL,
		fs.gl_number_id_st_liab = NULL,
		fs.gl_number_unhedged_der_lt_asset = NULL,
		fs.gl_number_unhedged_der_lt_liab = NULL,
		fs.gl_number_unhedged_der_st_asset = NULL,
		fs.gl_number_unhedged_der_st_liab = NULL,
		fs.gl_first_day_pnl = NULL
	FROM fas_strategy fs 
	WHERE fs.fas_strategy_id = @fas_strategy_id

	EXEC spa_ErrorHandler 0, 'Source Deal Detail', 'spa_shift_map_gl_codes', 'Success', 'Changes have been saved successfully.', @fas_strategy_id
END
ELSE IF @gl_grouping_value_id = 352 --Move GL Codes to SubBook
BEGIN
	INSERT INTO source_book_map_GL_codes (
		source_book_map_id, gl_id_amortization, gl_id_interest, gl_id_lt_tax_asset, gl_id_lt_tax_liab, gl_id_st_tax_asset, gl_id_st_tax_liab, gl_id_tax_reserve,
		gl_number_id_aoci, gl_number_id_cash, gl_number_id_expense, gl_number_id_gross_set, gl_number_id_inventory, gl_number_id_item_lt_asset,
		gl_number_id_item_lt_liab, gl_number_id_item_st_asset, gl_number_id_item_st_liab, gl_number_id_lt_asset, gl_number_id_lt_liab, gl_number_id_pnl,
		gl_number_id_set, gl_number_id_st_asset, gl_number_id_st_liab, gl_number_unhedged_der_lt_asset, gl_number_unhedged_der_lt_liab,
		gl_number_unhedged_der_st_asset, gl_number_unhedged_der_st_liab, gl_first_day_pnl
	)
	SELECT ssbm.book_deal_type_map_id,
			ISNULL(fb.gl_id_amortization, fs.gl_id_amortization) gl_id_amortization,
			ISNULL(fb.gl_id_interest, fs.gl_id_interest) gl_id_interest,
			ISNULL(fb.gl_id_lt_tax_asset, fs.gl_id_lt_tax_asset) gl_id_lt_tax_asset,
			ISNULL(fb.gl_id_lt_tax_liab, fs.gl_id_lt_tax_liab) gl_id_lt_tax_liab,
			ISNULL(fb.gl_id_st_tax_asset, fs.gl_id_st_tax_asset) gl_id_st_tax_asset,
			ISNULL(fb.gl_id_st_tax_liab, fs.gl_id_st_tax_liab) gl_id_st_tax_liab,
			ISNULL(fb.gl_id_tax_reserve, fs.gl_id_tax_reserve) gl_id_tax_reserve,
			ISNULL(fb.gl_number_id_aoci, fs.gl_number_id_aoci) gl_number_id_aoci,
			ISNULL(fb.gl_number_id_cash, fs.gl_number_id_cash) gl_number_id_cash,
			ISNULL(fb.gl_number_id_expense, fs.gl_number_id_expense) gl_number_id_expense,
			ISNULL(fb.gl_number_id_gross_set, fs.gl_number_id_gross_set) gl_number_id_gross_set,
			ISNULL(fb.gl_number_id_inventory, fs.gl_number_id_inventory) gl_number_id_inventory,
			ISNULL(fb.gl_number_id_item_lt_asset, fs.gl_number_id_item_lt_asset) gl_number_id_item_lt_asset,
			ISNULL(fb.gl_number_id_item_lt_liab, fs.gl_number_id_item_lt_liab) gl_number_id_item_lt_liab,
			ISNULL(fb.gl_number_id_item_st_asset, fs.gl_number_id_item_st_asset) gl_number_id_item_st_asset,
			ISNULL(fb.gl_number_id_item_st_liab, fs.gl_number_id_item_st_liab) gl_number_id_item_st_liab,
			ISNULL(fb.gl_number_id_lt_asset, fs.gl_number_id_lt_asset) gl_number_id_lt_asset,
			ISNULL(fb.gl_number_id_lt_liab, fs.gl_number_id_lt_liab) gl_number_id_lt_liab,
			ISNULL(fb.gl_number_id_pnl, fs.gl_number_id_pnl) gl_number_id_pnl,
			ISNULL(fb.gl_number_id_set, fs.gl_number_id_set) gl_number_id_set,
			ISNULL(fb.gl_number_id_st_asset, fs.gl_number_id_st_asset) gl_number_id_st_asset,
			ISNULL(fb.gl_number_id_st_liab, fs.gl_number_id_st_liab) gl_number_id_st_liab,
			ISNULL(fb.gl_number_unhedged_der_lt_asset, fs.gl_number_unhedged_der_lt_asset) gl_number_unhedged_der_lt_asset,
			ISNULL(fb.gl_number_unhedged_der_lt_liab, fs.gl_number_unhedged_der_lt_liab) gl_number_unhedged_der_lt_liab,
			ISNULL(fb.gl_number_unhedged_der_st_asset, fs.gl_number_unhedged_der_st_asset) gl_number_unhedged_der_st_asset,
			ISNULL(fb.gl_number_unhedged_der_st_liab, fs.gl_number_unhedged_der_st_liab) gl_number_unhedged_der_st_liab,
			ISNULL(fb.gl_first_day_pnl, fs.gl_first_day_pnl)
	FROM fas_strategy fs 
	LEFT JOIN portfolio_hierarchy stra
		ON stra.[entity_id] = fs.fas_strategy_id
	LEFT JOIN portfolio_hierarchy book
		on book.parent_entity_id = stra.[entity_id]
	LEFT JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.[entity_id]
	LEFT JOIN fas_books fb
		ON fb.fas_book_id = book.[entity_id]
	LEFT JOIN source_book_map_GL_codes sbmg 
		ON sbmg.source_book_map_id = ssbm.book_deal_type_map_id
	WHERE fas_strategy_id = @fas_strategy_id
		AND sbmg.source_book_map_id IS NULL
		AND ssbm.book_deal_type_map_id IS NOT NULL
		
	UPDATE fs
	SET fs.gl_id_amortization = NULL,
		fs.gl_id_interest = NULL,
		fs.gl_id_lt_tax_asset = NULL,
		fs.gl_id_lt_tax_liab = NULL,
		fs.gl_id_st_tax_asset = NULL,
		fs.gl_id_st_tax_liab = NULL,
		fs.gl_id_tax_reserve = NULL,
		fs.gl_number_id_aoci = NULL,
		fs.gl_number_id_cash = NULL,
		fs.gl_number_id_expense = NULL,
		fs.gl_number_id_gross_set = NULL,
		fs.gl_number_id_inventory = NULL,
		fs.gl_number_id_item_lt_asset = NULL,
		fs.gl_number_id_item_lt_liab = NULL,
		fs.gl_number_id_item_st_asset = NULL,
		fs.gl_number_id_item_st_liab = NULL,
		fs.gl_number_id_lt_asset = NULL,
		fs.gl_number_id_lt_liab = NULL,
		fs.gl_number_id_pnl = NULL,
		fs.gl_number_id_set = NULL,
		fs.gl_number_id_st_asset = NULL,
		fs.gl_number_id_st_liab = NULL,
		fs.gl_number_unhedged_der_lt_asset = NULL,
		fs.gl_number_unhedged_der_lt_liab = NULL,
		fs.gl_number_unhedged_der_st_asset = NULL,
		fs.gl_number_unhedged_der_st_liab = NULL,
		fs.gl_first_day_pnl = NULL
	FROM fas_strategy fs 
	WHERE fs.fas_strategy_id = @fas_strategy_id

	UPDATE fb
	SET fb.gl_id_amortization = NULL,
		fb.gl_id_interest = NULL,
		fb.gl_id_lt_tax_asset = NULL,
		fb.gl_id_lt_tax_liab = NULL,
		fb.gl_id_st_tax_asset = NULL,
		fb.gl_id_st_tax_liab = NULL,
		fb.gl_id_tax_reserve = NULL,
		fb.gl_number_id_aoci = NULL,
		fb.gl_number_id_cash = NULL,
		fb.gl_number_id_expense = NULL,
		fb.gl_number_id_gross_set = NULL,
		fb.gl_number_id_inventory = NULL,
		fb.gl_number_id_item_lt_asset = NULL,
		fb.gl_number_id_item_lt_liab = NULL,
		fb.gl_number_id_item_st_asset = NULL,
		fb.gl_number_id_item_st_liab = NULL,
		fb.gl_number_id_lt_asset = NULL,
		fb.gl_number_id_lt_liab = NULL,
		fb.gl_number_id_pnl = NULL,
		fb.gl_number_id_set = NULL,
		fb.gl_number_id_st_asset = NULL,
		fb.gl_number_id_st_liab = NULL,
		fb.gl_number_unhedged_der_lt_asset = NULL,
		fb.gl_number_unhedged_der_lt_liab = NULL,
		fb.gl_number_unhedged_der_st_asset = NULL,
		fb.gl_number_unhedged_der_st_liab = NULL,
		fb.gl_first_day_pnl = NULL
	FROM fas_strategy fs 
	LEFT JOIN portfolio_hierarchy stra
		ON stra.[entity_id] = fs.fas_strategy_id
	LEFT JOIN portfolio_hierarchy book
		on book.parent_entity_id = stra.[entity_id]
	LEFT JOIN source_system_book_map ssbm
		ON ssbm.fas_book_id = book.[entity_id]
	LEFT JOIN fas_books fb
		ON fb.fas_book_id = book.[entity_id]
	WHERE fas_strategy_id = @fas_strategy_id

	EXEC spa_ErrorHandler 0, 'Source Deal Detail', 'spa_shift_map_gl_codes', 'Success', 'Changes have been saved successfully.', @fas_strategy_id
END
GO