IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSubBookMapping]'))
DROP VIEW [dbo].vwSubBookMapping
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW vwSubBookMapping 
AS 
SELECT
	ssbm.book_deal_type_map_id
	, ssbm.fas_book_id 
	, ssbm.logical_name 
	, ssbm.source_system_book_id1
	, ssbm.source_system_book_id2
	, ssbm.source_system_book_id3
	, ssbm.source_system_book_id4
	, ssbm.fas_deal_type_value_id
	, ssbm.fas_deal_sub_type_value_id
	, ssbm.effective_start_date
	, ssbm.end_date
	, ssbm.percentage_included
	, ssbm.sub_book_group1
	, ssbm.sub_book_group2
	, ssbm.sub_book_group3
	, ssbm.sub_book_group4
	, ssbm.primary_counterparty_id
	, ssbm.accounting_code
	, sbmgc.gl_number_id_st_asset 
	, gl1.gl_account_number + ' (' + gl1.gl_account_name + ')' AS gl_number_id_st_asset_display
	, sbmgc.gl_number_id_lt_asset 
	, gl2.gl_account_number + ' (' + gl2.gl_account_name + ')' AS gl_number_id_lt_asset_display
	, sbmgc.gl_number_id_st_liab 
	, gl3.gl_account_number + ' (' + gl3.gl_account_name + ')' AS gl_number_id_st_liab_display
	, sbmgc.gl_number_id_lt_liab 
	, gl4.gl_account_number + ' (' + gl4.gl_account_name + ')' AS gl_number_id_lt_liab_display
	, sbmgc.gl_id_st_tax_asset 
	, gl5.gl_account_number + ' (' + gl5.gl_account_name + ')' AS gl_id_st_tax_asset_display
	, sbmgc.gl_id_lt_tax_asset 
	, gl6.gl_account_number + ' (' + gl6.gl_account_name + ')' AS gl_id_lt_tax_asset_display
	, sbmgc.gl_id_st_tax_liab 
	, gl7.gl_account_number + ' (' + gl7.gl_account_name + ')' AS gl_id_st_tax_liab_display
	, sbmgc.gl_id_lt_tax_liab 
	, gl8.gl_account_number + ' (' + gl8.gl_account_name + ')' AS gl_id_lt_tax_liab_display
	, sbmgc.gl_id_tax_reserve 
	, gl9.gl_account_number + ' (' + gl9.gl_account_name + ')' AS gl_id_tax_reserve_display
	, sbmgc.gl_number_id_aoci 
	, gl10.gl_account_number + ' (' + gl10.gl_account_name + ')' AS gl_number_id_aoci_display
	, sbmgc.gl_number_id_inventory
	, gl11.gl_account_number + ' (' + gl11.gl_account_name + ')' AS gl_number_id_inventory_display
	, sbmgc.gl_number_id_pnl 
	, gl12.gl_account_number + ' (' + gl12.gl_account_name + ')' AS gl_number_id_pnl_display
	, sbmgc.gl_number_id_set 
	, gl13.gl_account_number + ' (' + gl13.gl_account_name + ')' AS gl_number_id_set_display
	, sbmgc.gl_number_id_cash
	, gl14.gl_account_number + ' (' + gl14.gl_account_name + ')' AS gl_number_id_cash_display
	, sbmgc.gl_number_id_gross_set
	, gl15.gl_account_number + ' (' + gl15.gl_account_name + ')' AS gl_number_id_gross_set_display
	, sbmgc.gl_number_unhedged_der_st_asset
	, gl16.gl_account_number + ' (' + gl16.gl_account_name + ')' AS gl_number_unhedged_der_st_asset_display
	, sbmgc.gl_number_unhedged_der_lt_asset
	, gl17.gl_account_number + ' (' + gl17.gl_account_name + ')' AS gl_number_unhedged_der_lt_asset_display
	, sbmgc.gl_number_unhedged_der_st_liab
	, gl18.gl_account_number + ' (' + gl18.gl_account_name + ')' AS gl_number_unhedged_der_st_liab_display
	, sbmgc.gl_number_unhedged_der_lt_liab
	, gl19.gl_account_number + ' (' + gl19.gl_account_name + ')' AS gl_number_unhedged_der_lt_liab_display
	, sbmgc.gl_number_id_item_st_asset
	, gl20.gl_account_number + ' (' + gl20.gl_account_name + ')' AS gl_number_id_item_st_asset_display
	, sbmgc.gl_number_id_item_st_liab
	, gl21.gl_account_number + ' (' + gl21.gl_account_name + ')' AS gl_number_id_item_st_liab_display
	, sbmgc.gl_number_id_item_lt_asset
	, gl22.gl_account_number + ' (' + gl22.gl_account_name + ')' AS gl_number_id_item_lt_asset_display
	, sbmgc.gl_number_id_item_lt_liab
	, gl23.gl_account_number + ' (' + gl23.gl_account_name + ')' AS gl_number_id_item_lt_liab_display
	, sbmgc.gl_id_amortization
	, gl24.gl_account_number + ' (' + gl24.gl_account_name + ')' AS gl_id_amortization_display
	, sbmgc.gl_id_interest
	, gl25.gl_account_number + ' (' + gl25.gl_account_name + ')' AS gl_id_interest_display
	, sbmgc.gl_number_id_expense
	, gl26.gl_account_number + ' (' + gl26.gl_account_name + ')' AS gl_number_id_expense_display
FROM source_system_book_map ssbm 
LEFT JOIN source_book_map_GL_codes sbmgc ON sbmgc.source_book_map_id = ssbm.book_deal_type_map_id
LEFT JOIN gl_system_mapping gl1 ON sbmgc.gl_number_id_st_asset  = gl1.gl_number_id 
LEFT JOIN gl_system_mapping gl2 ON sbmgc.gl_number_id_lt_asset = gl2.gl_number_id  
LEFT JOIN gl_system_mapping gl3 ON sbmgc.gl_number_id_st_liab = gl3.gl_number_id 
LEFT JOIN gl_system_mapping gl4 ON sbmgc.gl_number_id_lt_liab = gl4.gl_number_id 
LEFT JOIN gl_system_mapping gl5 ON sbmgc.gl_id_st_tax_asset = gl5.gl_number_id  
LEFT JOIN gl_system_mapping gl6 ON sbmgc.gl_id_lt_tax_asset = gl6.gl_number_id  
LEFT JOIN gl_system_mapping gl7 ON sbmgc.gl_id_st_tax_liab = gl7.gl_number_id  
LEFT JOIN gl_system_mapping gl8 ON sbmgc.gl_id_lt_tax_liab = gl8.gl_number_id  
LEFT JOIN gl_system_mapping gl9 ON sbmgc.gl_id_tax_reserve = gl9.gl_number_id   
LEFT JOIN gl_system_mapping gl10 ON sbmgc.gl_number_id_aoci = gl10.gl_number_id  
LEFT JOIN gl_system_mapping gl11 ON sbmgc.gl_number_id_inventory = gl11.gl_number_id 
LEFT JOIN gl_system_mapping gl12 ON sbmgc.gl_number_id_pnl = gl12.gl_number_id 
LEFT JOIN gl_system_mapping gl13 ON sbmgc.gl_number_id_set = gl13.gl_number_id
LEFT JOIN gl_system_mapping gl14 ON sbmgc.gl_number_id_cash = gl14.gl_number_id
LEFT JOIN gl_system_mapping gl15 ON sbmgc.gl_number_id_gross_set = gl15.gl_number_id
LEFT JOIN gl_system_mapping gl16 ON sbmgc.gl_number_unhedged_der_st_asset = gl16.gl_number_id
LEFT JOIN gl_system_mapping gl17 ON sbmgc.gl_number_unhedged_der_lt_asset = gl17.gl_number_id
LEFT JOIN gl_system_mapping gl18 ON sbmgc.gl_number_unhedged_der_st_liab = gl18.gl_number_id
LEFT JOIN gl_system_mapping gl19 ON sbmgc.gl_number_unhedged_der_lt_liab = gl19.gl_number_id
LEFT JOIN gl_system_mapping gl20 ON sbmgc.gl_number_id_item_st_asset = gl20.gl_number_id
LEFT JOIN gl_system_mapping gl21 ON sbmgc.gl_number_id_item_st_liab = gl21.gl_number_id
LEFT JOIN gl_system_mapping gl22 ON sbmgc.gl_number_id_item_lt_asset = gl22.gl_number_id
LEFT JOIN gl_system_mapping gl23 ON sbmgc.gl_number_id_item_lt_liab = gl23.gl_number_id
LEFT JOIN gl_system_mapping gl24 ON sbmgc.gl_id_amortization = gl24.gl_number_id
LEFT JOIN gl_system_mapping gl25 ON sbmgc.gl_id_interest = gl25.gl_number_id
LEFT JOIN gl_system_mapping gl26 ON sbmgc.gl_number_id_expense = gl26.gl_number_id