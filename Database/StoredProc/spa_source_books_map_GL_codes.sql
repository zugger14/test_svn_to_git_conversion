IF OBJECT_ID(N'[dbo].[spa_source_books_map_GL_codes]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_source_books_map_GL_codes]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2011-09-12
-- Description: CRUD operations for table source_books_map_GL_codes
-- Params:
--	@flag CHAR(1) - Operation flag
-- ===========================================================================================================
--EXEC [spa_source_books_map_GL_codes] 's',50
CREATE PROC [dbo].[spa_source_books_map_GL_codes]
	@flag CHAR(1),
	@source_book_map_id VARCHAR(MAX) = NULL,
	@gl_number_id_st_asset INT = NULL,
	@gl_number_id_st_liab INT = NULL,
	@gl_number_id_lt_asset INT = NULL,
	@gl_number_id_lt_liab INT = NULL,
	@gl_number_id_item_st_asset INT = NULL,
	@gl_number_id_item_st_liab INT = NULL,
	@gl_number_id_item_lt_asset INT = NULL,
	@gl_number_id_item_lt_liab INT = NULL,
	@gl_number_id_aoci INT = NULL,
	@gl_number_id_pnl INT = NULL,
	@gl_number_id_set INT = NULL,
	@gl_number_id_cash INT = NULL,
	@gl_number_id_inventory INT = NULL,
	@gl_number_id_expense INT = NULL,
	@gl_number_id_gross_set INT = NULL,
	@gl_id_amortization INT = NULL,
	@gl_id_interest INT = NULL,
	@gl_id_st_tax_asset INT = NULL,
	@gl_id_st_tax_liab INT = NULL,
	@gl_id_lt_tax_asset INT = NULL,
	@gl_id_lt_tax_liab INT = NULL,
	@gl_id_tax_reserve INT = NULL,
	@gl_number_unhedged_der_st_asset INT = NULL,
	@gl_number_unhedged_der_lt_asset INT = NULL,
	@gl_number_unhedged_der_st_liab INT = NULL,
	@gl_number_unhedged_der_lt_liab INT = NULL

AS
BEGIN
	IF @flag = 'i'
	BEGIN
		INSERT INTO source_book_map_GL_codes (
			source_book_map_id,
			gl_number_id_st_asset,
			gl_number_id_st_liab,
			gl_number_id_lt_asset,
			gl_number_id_lt_liab,
			gl_number_id_item_st_asset,
			gl_number_id_item_st_liab,
			gl_number_id_item_lt_asset,
			gl_number_id_item_lt_liab,
			gl_number_id_aoci,
			gl_number_id_pnl,
			gl_number_id_set,
			gl_number_id_cash,
			gl_number_id_inventory,
			gl_number_id_expense,
			gl_number_id_gross_set,
			gl_id_amortization,
			gl_id_interest,
			gl_id_st_tax_asset,
			gl_id_st_tax_liab,
			gl_id_lt_tax_asset,
			gl_id_lt_tax_liab,
			gl_id_tax_reserve,
			gl_number_unhedged_der_st_asset,
			gl_number_unhedged_der_lt_asset,
			gl_number_unhedged_der_st_liab,
			gl_number_unhedged_der_lt_liab			
		)
		VALUES
		(
			@source_book_map_id,
			@gl_number_id_st_asset,
			@gl_number_id_st_liab,
			@gl_number_id_lt_asset,
			@gl_number_id_lt_liab,
			@gl_number_id_item_st_asset,
			@gl_number_id_item_st_liab,
			@gl_number_id_item_lt_asset,
			@gl_number_id_item_lt_liab,
			@gl_number_id_aoci,
			@gl_number_id_pnl,
			@gl_number_id_set,
			@gl_number_id_cash,
			@gl_number_id_inventory,
			@gl_number_id_expense,
			@gl_number_id_gross_set,
			@gl_id_amortization,
			@gl_id_interest,
			@gl_id_st_tax_asset,
			@gl_id_st_tax_liab,
			@gl_id_lt_tax_asset,
			@gl_id_lt_tax_liab,
			@gl_id_tax_reserve,
			@gl_number_unhedged_der_st_asset,
			@gl_number_unhedged_der_lt_asset,
			@gl_number_unhedged_der_st_liab,
			@gl_number_unhedged_der_lt_liab
		)
	END
	ELSE IF @flag = 'u'
	BEGIN
		UPDATE source_book_map_GL_codes
		SET
			gl_number_id_st_asset = @gl_number_id_st_asset,
			gl_number_id_st_liab = @gl_number_id_st_liab,
			gl_number_id_lt_asset = @gl_number_id_lt_asset,
			gl_number_id_lt_liab = @gl_number_id_lt_liab,
			gl_number_id_item_st_asset = @gl_number_id_item_st_asset,
			gl_number_id_item_st_liab = @gl_number_id_item_st_liab,
			gl_number_id_item_lt_asset = @gl_number_id_item_lt_asset,
			gl_number_id_item_lt_liab = @gl_number_id_item_lt_liab,
			gl_number_id_aoci = @gl_number_id_aoci,
			gl_number_id_pnl = @gl_number_id_pnl,
			gl_number_id_set = @gl_number_id_set,
			gl_number_id_cash = @gl_number_id_cash,
			gl_number_id_inventory = @gl_number_id_inventory,
			gl_number_id_expense = @gl_number_id_expense,
			gl_number_id_gross_set = @gl_number_id_gross_set,
			gl_id_amortization = @gl_id_amortization,
			gl_id_interest = @gl_id_interest,
			gl_id_st_tax_asset = @gl_id_st_tax_asset,
			gl_id_st_tax_liab = @gl_id_st_tax_liab,
			gl_id_lt_tax_asset = @gl_id_lt_tax_asset,
			gl_id_lt_tax_liab = @gl_id_lt_tax_liab,
			gl_id_tax_reserve = @gl_id_tax_reserve,
			gl_number_unhedged_der_st_asset=@gl_number_unhedged_der_st_asset,
			gl_number_unhedged_der_lt_asset=@gl_number_unhedged_der_lt_asset,
			gl_number_unhedged_der_st_liab=@gl_number_unhedged_der_st_liab,
			gl_number_unhedged_der_lt_liab=@gl_number_unhedged_der_lt_liab
		WHERE source_book_map_id = @source_book_map_id
	END
	ELSE IF @flag = 's'
	BEGIN
		SELECT 
			sbmgc.source_book_map_GL_codes_id,
			sbmgc.source_book_map_id,
			sbmgc.gl_number_id_st_asset,
			sbmgc.gl_number_id_st_liab,
			sbmgc.gl_number_id_lt_asset,
			sbmgc.gl_number_id_lt_liab,
			sbmgc.gl_number_id_item_st_asset,
			sbmgc.gl_number_id_item_st_liab,
			sbmgc.gl_number_id_item_lt_asset,
			sbmgc.gl_number_id_item_lt_liab,
			sbmgc.gl_number_id_aoci,
			sbmgc.gl_number_id_pnl,
			sbmgc.gl_number_id_set,
			sbmgc.gl_number_id_cash,
			gl1.gl_account_number + ' (' + gl1.gl_account_name + ')' AS gl_number_id_st_asset_display,
			gl2.gl_account_number + ' (' + gl2.gl_account_name + ')' AS gl_number_id_st_liab_display,
			gl3.gl_account_number + ' (' + gl3.gl_account_name + ')' AS gl_number_id_lt_asset_display,
			gl4.gl_account_number + ' (' + gl4.gl_account_name + ')' AS gl_number_id_lt_liab_display,
			gl5.gl_account_number + ' (' + gl5.gl_account_name + ')' AS gl_number_id_item_st_asset_display,
			gl6.gl_account_number + ' (' + gl6.gl_account_name + ')' AS gl_number_id_item_st_liab_display,
			gl7.gl_account_number + ' (' + gl7.gl_account_name + ')' AS gl_number_id_item_lt_asset_display,
			gl8.gl_account_number + ' (' + gl8.gl_account_name + ')' AS gl_number_id_item_lt_liab_display,
			gl9.gl_account_number + ' (' + gl9.gl_account_name + ')' AS gl_number_id_aoci_display,
			gl10.gl_account_number + ' (' + gl10.gl_account_name + ')' AS gl_number_id_pnl_display,
			gl11.gl_account_number + ' (' + gl11.gl_account_name + ')' AS gl_number_id_set_display,
			gl12.gl_account_number + ' (' + gl12.gl_account_name + ')' AS gl_number_id_cash_display,
			sbmgc.gl_number_id_inventory,
			gl13.gl_account_number + ' (' + gl13.gl_account_name + ')' AS gl_number_id_inventory_display,
			sbmgc.gl_id_amortization,
			gl14.gl_account_number + ' (' + gl14.gl_account_name + ')' AS gl_number_id_Amortize_display,
			sbmgc.gl_id_interest,
			gl15.gl_account_number + ' (' + gl15.gl_account_name + ')' AS gl_number_id_Intrest_display,
			sbmgc.gl_number_id_expense,
			gl16.gl_account_number + ' (' + gl16.gl_account_name + ')' AS gl_number_id_Expense_display,
			sbmgc.gl_number_id_gross_set,
			gl17.gl_account_number + ' (' + gl17.gl_account_name + ')' AS  gl_number_id_Gross_display,
			sbmgc.gl_id_st_tax_asset,
			gl18.gl_account_number + ' (' + gl18.gl_account_name + ')' AS  gl_id_st_tax_asset_display,
			sbmgc.gl_id_st_tax_liab,
			gl19.gl_account_number + ' (' + gl19.gl_account_name + ')' AS  gl_id_st_tax_liab_display,
			sbmgc.gl_id_lt_tax_asset,
			gl20.gl_account_number + ' (' + gl20.gl_account_name + ')' AS  gl_id_lt_tax_asset_display,
			sbmgc.gl_id_lt_tax_liab,
			gl21.gl_account_number + ' (' + gl21.gl_account_name + ')' AS  gl_id_lt_tax_liab_display,
			sbmgc.gl_id_tax_reserve,
			gl22.gl_account_number + ' (' + gl22.gl_account_name + ')' AS  gl_id_tax_reserve_display,
			sbmgc.gl_number_unhedged_der_st_asset,
			gl23.gl_account_number + ' (' + gl23.gl_account_name +')' as gl_number_unhedged_der_st_asset_display,
			sbmgc.gl_number_unhedged_der_lt_asset,
			gl24.gl_account_number + ' (' + gl24.gl_account_name +')' as gl_number_unhedged_der_lt_asset_display,
			sbmgc.gl_number_unhedged_der_st_liab,
			gl25.gl_account_number + ' (' + gl25.gl_account_name +')' as gl_number_unhedged_der_st_liab_display,
			sbmgc.gl_number_unhedged_der_lt_liab,
			gl26.gl_account_number + ' (' + gl26.gl_account_name +')' as gl_number_unhedged_der_lt_liab_display
		FROM source_book_map_GL_codes sbmgc
		LEFT JOIN gl_system_mapping gl1 ON  sbmgc.gl_number_id_st_asset = gl1.gl_number_id
		LEFT JOIN gl_system_mapping gl2 ON  sbmgc.gl_number_id_st_liab = gl2.gl_number_id
		LEFT JOIN gl_system_mapping gl3 ON  sbmgc.gl_number_id_lt_asset = gl3.gl_number_id
		LEFT JOIN gl_system_mapping gl4 ON  sbmgc.gl_number_id_lt_liab = gl4.gl_number_id
		LEFT JOIN gl_system_mapping gl5 ON  sbmgc.gl_number_id_item_st_asset = gl5.gl_number_id
		LEFT JOIN gl_system_mapping gl6 ON  sbmgc.gl_number_id_item_st_liab = gl6.gl_number_id
		LEFT JOIN gl_system_mapping gl7 ON  sbmgc.gl_number_id_item_lt_asset = gl7.gl_number_id
		LEFT JOIN gl_system_mapping gl8 ON  sbmgc.gl_number_id_item_lt_liab = gl8.gl_number_id
		LEFT JOIN gl_system_mapping gl9 ON  sbmgc.gl_number_id_aoci = gl9.gl_number_id
		LEFT JOIN gl_system_mapping gl10 ON  sbmgc.gl_number_id_pnl = gl10.gl_number_id
		LEFT JOIN gl_system_mapping gl11 ON  sbmgc.gl_number_id_set = gl11.gl_number_id
		LEFT JOIN gl_system_mapping gl12 ON  sbmgc.gl_number_id_cash = gl12.gl_number_id
		LEFT JOIN gl_system_mapping gl13 ON  sbmgc.gl_number_id_inventory = gl13.gl_number_id
		LEFT JOIN gl_system_mapping gl14 ON  sbmgc.gl_id_amortization = gl14.gl_number_id
		LEFT JOIN gl_system_mapping gl15 ON  sbmgc.gl_id_interest = gl15.gl_number_id
		LEFT JOIN gl_system_mapping gl16 ON  sbmgc.gl_number_id_expense = gl16.gl_number_id
		LEFT JOIN gl_system_mapping gl17 ON  sbmgc.gl_number_id_gross_set = gl17.gl_number_id
		LEFT JOIN gl_system_mapping gl18 ON  sbmgc.gl_id_st_tax_asset = gl18.gl_number_id
		LEFT JOIN gl_system_mapping gl19 ON  sbmgc.gl_id_st_tax_liab = gl19.gl_number_id
		LEFT JOIN gl_system_mapping gl20 ON  sbmgc.gl_id_lt_tax_asset = gl20.gl_number_id
		LEFT JOIN gl_system_mapping gl21 ON  sbmgc.gl_id_lt_tax_liab = gl21.gl_number_id
		LEFT JOIN gl_system_mapping gl22 ON  sbmgc.gl_id_tax_reserve = gl22.gl_number_id
		LEFT JOIN gl_system_mapping gl23 ON  sbmgc.gl_number_unhedged_der_st_asset = gl23.gl_number_id 
		LEFT JOIN gl_system_mapping gl24 ON  sbmgc.gl_number_unhedged_der_lt_asset = gl24.gl_number_id 
		LEFT JOIN gl_system_mapping gl25 ON  sbmgc.gl_number_unhedged_der_st_liab = gl25.gl_number_id 
		LEFT JOIN gl_system_mapping gl26 ON  sbmgc.gl_number_unhedged_der_lt_liab = gl26.gl_number_id 
		WHERE sbmgc.source_book_map_id  = @source_book_map_id
	END
	ELSE IF @flag = 'd'
	BEGIN
		DELETE sbmgc
		FROM   source_book_map_GL_codes sbmgc
		INNER JOIN dbo.SplitCommaSeperatedValues(@source_book_map_id) a
			ON a.item = sbmgc.source_book_map_id
	END
END