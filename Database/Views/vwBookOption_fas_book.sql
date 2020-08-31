IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwBookOption]'))
DROP VIEW [dbo].[vwBookOption]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW vwBookOption AS SELECT fb.fas_book_id,
       no_link,
       no_links_fas_eff_test_profile_id,
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
     
       accounting_type,
	   accounting_code,
       --fas_books.*, 
      ph.entity_name AS entity_name,
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
       fas_eff_hedge_rel_type.eff_test_name AS no_links_fas_eff_test_profile_id_name,
       gl_number_id_inventory,
       gl13.gl_account_number + ' (' + gl13.gl_account_name + ')' AS gl_number_id_inventory_display,
       gl_id_amortization,
       gl14.gl_account_number + ' (' + gl14.gl_account_name + ')' AS gl_number_id_Amortize_display,
       gl_id_interest,
       gl15.gl_account_number + ' (' + gl15.gl_account_name + ')' AS gl_number_id_Intrest_display,
       gl_number_id_expense,
       gl16.gl_account_number + ' (' + gl16.gl_account_name + ')' AS gl_number_id_Expense_display,
       gl_number_id_gross_set,
       gl17.gl_account_number + ' (' + gl17.gl_account_name + ')' AS  gl_number_id_Gross_display,
       convert_uom_id,
      cost_approach_id,
      gl_id_st_tax_asset,
       gl18.gl_account_number + ' (' + gl18.gl_account_name + ')' AS  gl_id_st_tax_asset_display,
      gl_id_st_tax_liab,
       gl19.gl_account_number + ' (' + gl19.gl_account_name + ')' AS  gl_id_st_tax_liab_display,
       gl_id_lt_tax_asset,
       gl20.gl_account_number + ' (' + gl20.gl_account_name + ')' AS  gl_id_lt_tax_asset_display,
       gl_id_lt_tax_liab,
       gl21.gl_account_number + ' (' + gl21.gl_account_name + ')' AS  gl_id_lt_tax_liab_display,
       gl_id_tax_reserve,
       gl22.gl_account_number + ' (' + gl22.gl_account_name + ')' AS  gl_id_tax_reserve_display,
      legal_entity,
      tax_perc,
      hedge_item_same_sign,
       fun_cur_value_id,
       hedge_type_value_id,
	   gl_number_unhedged_der_st_asset,
	   gl23.gl_account_number + ' (' + gl23.gl_account_name +')' as gl_number_unhedged_der_st_asset_display,
	gl_number_unhedged_der_lt_asset,
	   gl24.gl_account_number + ' (' + gl24.gl_account_name +')' as gl_number_unhedged_der_lt_asset_display,
	   gl_number_unhedged_der_st_liab,
	   gl25.gl_account_number + ' (' + gl25.gl_account_name +')' as gl_number_unhedged_der_st_liab_display,
	   gl_number_unhedged_der_lt_liab,
	   gl26.gl_account_number + ' (' + gl26.gl_account_name +')' as gl_number_unhedged_der_lt_liab_display,
	   primary_counterparty_id
FROM   fas_books fb
       INNER JOIN portfolio_hierarchy ph
            ON  fb.fas_book_id = ph.entity_id
       LEFT OUTER JOIN gl_system_mapping gl1
            ON  fb.gl_number_id_st_asset = gl1.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl2
            ON  fb.gl_number_id_st_liab = gl2.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl3
            ON  fb.gl_number_id_lt_asset = gl3.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl4
            ON  fb.gl_number_id_lt_liab = gl4.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl5
            ON  fb.gl_number_id_item_st_asset = gl5.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl6
            ON  fb.gl_number_id_item_st_liab = gl6.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl7
            ON  fb.gl_number_id_item_lt_asset = gl7.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl8
            ON  fb.gl_number_id_item_lt_liab = gl8.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl9
            ON  fb.gl_number_id_aoci = gl9.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl10
            ON  fb.gl_number_id_pnl = gl10.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl11
            ON  fb.gl_number_id_set = gl11.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl12
            ON  fb.gl_number_id_cash = gl12.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl13
            ON  fb.gl_number_id_inventory = gl13.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl14
            ON  fb.gl_id_amortization = gl14.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl15
            ON  fb.gl_id_interest = gl15.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl16
            ON  fb.gl_number_id_expense = gl16.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl17
            ON  fb.gl_number_id_gross_set = gl17.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl18
            ON  fb.gl_id_st_tax_asset = gl18.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl19
            ON  fb.gl_id_st_tax_liab = gl19.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl20
            ON  fb.gl_id_lt_tax_asset = gl20.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl21
            ON  fb.gl_id_lt_tax_liab = gl21.gl_number_id
       LEFT OUTER JOIN gl_system_mapping gl22
            ON  fb.gl_id_tax_reserve = gl22.gl_number_id
		LEFT OUTER JOIN gl_system_mapping gl23 
			ON   fb.gl_number_unhedged_der_st_asset = gl23.gl_number_id 
		LEFT OUTER JOIN	gl_system_mapping gl24 
			ON   fb.gl_number_unhedged_der_lt_asset = gl24.gl_number_id 
		LEFT OUTER JOIN	gl_system_mapping gl25 
			ON   fb.gl_number_unhedged_der_st_liab = gl25.gl_number_id 
		LEFT OUTER JOIN	gl_system_mapping gl26 
			ON   fb.gl_number_unhedged_der_lt_liab = gl26.gl_number_id        
		LEFT OUTER JOIN fas_eff_hedge_rel_type
            ON  fb.no_links_fas_eff_test_profile_id = fas_eff_hedge_rel_type.eff_test_profile_id