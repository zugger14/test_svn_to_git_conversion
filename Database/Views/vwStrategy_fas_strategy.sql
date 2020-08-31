	IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwStrategy]'))
	DROP VIEW [dbo].vwStrategy
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
    CREATE VIEW vwStrategy 
	AS 
    SELECT fas_strategy.fas_strategy_id,
		fas_strategy.source_system_id,
		fas_strategy.hedge_type_value_id,
		fas_strategy.fx_hedge_flag,
		fas_strategy.mes_gran_value_id,
		fas_strategy.gl_grouping_value_id,
		fas_strategy.no_links,
		fas_strategy.no_links_fas_eff_test_profile_id,
		fas_strategy.mes_cfv_value_id,
		fas_strategy.mes_cfv_values_value_id,
		fas_strategy.mismatch_tenor_value_id,
		fas_strategy.strip_trans_value_id,
		fas_strategy.asset_liab_calc_value_id,
		CAST(ROUND(test_range_from, 2) AS VARCHAR) AS test_range_from,
		CAST(ROUND(test_range_to, 2) AS VARCHAR) AS test_range_to,
		CAST(ROUND(additional_test_range_from, 2) AS VARCHAR) AS 
		additional_test_range_from,
		CAST(ROUND(additional_test_range_to, 2) AS VARCHAR) AS 
		additional_test_range_to,
		fas_strategy.include_unlinked_hedges,
		fas_strategy.include_unlinked_items,
		fas_strategy.gl_number_id_st_asset,
		fas_strategy.gl_number_id_st_liab,
		fas_strategy.gl_number_id_lt_asset,
		fas_strategy.gl_number_id_lt_liab,
		fas_strategy.gl_number_id_item_st_asset,
		fas_strategy.gl_number_id_item_st_liab,
		fas_strategy.gl_number_id_item_lt_asset,
		fas_strategy.gl_number_id_item_lt_liab,
		fas_strategy.gl_number_id_aoci,
		fas_strategy.gl_number_id_pnl,
		fas_strategy.gl_number_id_set,
		fas_strategy.gl_number_id_cash,
		fas_strategy.oci_rollout_approach_value_id,
		fas_strategy.create_user,
		fas_strategy.create_ts,
		fas_strategy.update_user,
		fas_strategy.update_ts,
		portfolio_hierarchy.entity_name AS entity_name,
		--portfolio_hierarchy.parent_entity_id AS parent_entity_id,
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
		CAST(ROUND(additional_test_range_from2, 2)AS VARCHAR) AS test_range_from2,
		CAST(ROUND(additional_test_range_to2, 2)AS VARCHAR) AS test_range_to2,
		fas_strategy.gl_number_id_inventory,
		gl13.gl_account_number + ' (' + gl13.gl_account_name + ')' AS gl_number_id_inventory_display, 
		fas_strategy.options_premium_approach,
		fas_strategy.gl_id_amortization,
		gl14.gl_account_number + ' (' + gl14.gl_account_name + ')' AS gl_number_id_Amortize_display,
		fas_strategy.gl_id_interest,
		gl15.gl_account_number + ' (' + gl15.gl_account_name + ')' AS gl_number_id_Intrest_display,
		fas_strategy.gl_number_id_expense,
		gl16.gl_account_number + ' (' + gl16.gl_account_name + ')' AS gl_number_id_Expense_display,
		fas_strategy.gl_number_id_gross_set,
		gl17.gl_account_number + ' (' + gl17.gl_account_name + ')' AS gl_number_id_Gross_display,
		subentity_name,
		subentity_desc,
		relationship_to_entity,
		distinct_estimation_method,
		distinct_output_metrics,
		distinct_foreign_country,
		primary_naics_code_id,
		secondary_naics_code_id,
		organization_boundary_id,
		sub_entity,fas_strategy.rollout_per_type,
		fas_strategy.gl_id_st_tax_asset,
		gl18.gl_account_number + ' (' + gl18.gl_account_name + ')' AS gl_id_st_tax_asset_display,
		fas_strategy.gl_id_st_tax_liab,
		gl19.gl_account_number + ' (' + gl19.gl_account_name + ')' AS gl_id_st_tax_liab_display,
		fas_strategy.gl_id_lt_tax_asset,
		gl20.gl_account_number + ' (' + gl20.gl_account_name + ')' AS gl_id_lt_tax_asset_display,
		fas_strategy.gl_id_lt_tax_liab,
		gl21.gl_account_number + ' (' + gl21.gl_account_name + ')' AS gl_id_lt_tax_liab_display,
		fas_strategy.gl_id_tax_reserve,
		gl22.gl_account_number + ' (' + gl22.gl_account_name + ')' AS gl_id_tax_reserve_display,
		--@total_book total_book,
		first_day_pnl_threshold,
		gl_tenor_option,
		fun_cur_value_id,
		fas_strategy.gl_number_unhedged_der_st_asset,
		gl23.gl_account_number + ' (' + gl23.gl_account_name +')' as gl_number_unhedged_der_st_asset_display,
		fas_strategy.gl_number_unhedged_der_lt_asset,
		gl24.gl_account_number + ' (' + gl24.gl_account_name +')' as gl_number_unhedged_der_lt_asset_display,
		fas_strategy.gl_number_unhedged_der_st_liab,
		gl25.gl_account_number + ' (' + gl25.gl_account_name +')' as gl_number_unhedged_der_st_liab_display,
		fas_strategy.gl_number_unhedged_der_lt_liab,
		gl26.gl_account_number + ' (' + gl26.gl_account_name +')' as gl_number_unhedged_der_lt_liab_display,
		primary_counterparty_id,
		accounting_code

	FROM fas_strategy 
	INNER JOIN portfolio_hierarchy ON fas_strategy.fas_strategy_id = portfolio_hierarchy.entity_id 
	LEFT OUTER JOIN gl_system_mapping gl1 ON fas_strategy.gl_number_id_st_asset = gl1.gl_number_id 
	LEFT OUTER JOIN gl_system_mapping gl2 ON fas_strategy.gl_number_id_st_liab = gl2.gl_number_id  
	LEFT OUTER JOIN gl_system_mapping gl3 ON fas_strategy.gl_number_id_lt_asset = gl3.gl_number_id 
	LEFT OUTER JOIN gl_system_mapping gl4 ON fas_strategy.gl_number_id_lt_liab = gl4.gl_number_id 
	LEFT OUTER JOIN gl_system_mapping gl5 ON fas_strategy.gl_number_id_item_st_asset = gl5.gl_number_id  
	LEFT OUTER JOIN gl_system_mapping gl6 ON fas_strategy.gl_number_id_item_st_liab = gl6.gl_number_id  
	LEFT OUTER JOIN gl_system_mapping gl7 ON fas_strategy.gl_number_id_item_lt_asset = gl7.gl_number_id  
	LEFT OUTER JOIN gl_system_mapping gl8 ON fas_strategy.gl_number_id_item_lt_liab = gl8.gl_number_id  
	LEFT OUTER JOIN gl_system_mapping gl9 ON fas_strategy.gl_number_id_aoci = gl9.gl_number_id   
	LEFT OUTER JOIN gl_system_mapping gl10 ON fas_strategy.gl_number_id_pnl = gl10.gl_number_id  
	LEFT OUTER JOIN gl_system_mapping gl11 ON fas_strategy.gl_number_id_set = gl11.gl_number_id 
	LEFT OUTER JOIN gl_system_mapping gl12 ON fas_strategy.gl_number_id_cash = gl12.gl_number_id 
	LEFT OUTER JOIN gl_system_mapping gl13 ON fas_strategy.gl_number_id_inventory = gl13.gl_number_id
	LEFT OUTER JOIN gl_system_mapping gl14 ON fas_strategy.gl_id_amortization = gl14.gl_number_id
	LEFT OUTER JOIN gl_system_mapping gl15 ON fas_strategy.gl_id_interest = gl15.gl_number_id
	LEFT OUTER JOIN gl_system_mapping gl16 ON fas_strategy.gl_number_id_expense = gl16.gl_number_id 
	LEFT OUTER JOIN gl_system_mapping gl17 ON fas_strategy.gl_number_id_gross_set = gl17.gl_number_id
	LEFT OUTER JOIN gl_system_mapping gl18 ON fas_strategy.gl_id_st_tax_asset = gl18.gl_number_id 
	LEFT OUTER JOIN gl_system_mapping gl19 ON fas_strategy.gl_id_st_tax_liab = gl19.gl_number_id
	LEFT OUTER JOIN gl_system_mapping gl20 ON fas_strategy.gl_id_lt_tax_asset = gl20.gl_number_id
	LEFT OUTER JOIN gl_system_mapping gl21 ON fas_strategy.gl_id_lt_tax_liab = gl21.gl_number_id
	LEFT OUTER JOIN gl_system_mapping gl22 ON fas_strategy.gl_id_tax_reserve = gl22.gl_number_id
	LEFT OUTER JOIN gl_system_mapping gl23 ON   fas_strategy.gl_number_unhedged_der_st_asset = gl23.gl_number_id 
	LEFT OUTER JOIN	gl_system_mapping gl24 ON   fas_strategy.gl_number_unhedged_der_lt_asset = gl24.gl_number_id 
	LEFT OUTER JOIN	gl_system_mapping gl25 ON   fas_strategy.gl_number_unhedged_der_st_liab = gl25.gl_number_id 
	LEFT OUTER JOIN	gl_system_mapping gl26 ON   fas_strategy.gl_number_unhedged_der_lt_liab = gl26.gl_number_id 
	LEFT OUTER JOIN fas_eff_hedge_rel_type ON fas_strategy.no_links_fas_eff_test_profile_id = fas_eff_hedge_rel_type.eff_test_profile_id
--WHERE fas_strategy.fas_strategy_id = 3
--SELECT * FROM fas_strategy