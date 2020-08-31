IF NOT EXISTS (SELECT * FROM process_table_archive_policy WHERE tbl_name = 'source_deal_pnl_detail')
BEGIN
	INSERT INTO	process_table_archive_policy
	SELECT	'source_deal_pnl_detail', 
			'',
			0,
			NULL,
			'[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor],[pnl_adjustment_value],[deal_volume],[curve_id],[accrued_interest],[price],[discount_rate],[no_days_left],[days_year],[discount_factor],[create_user],[create_ts],[update_user],[update_ts],[curve_as_of_date],[internal_deal_type_value_id],[internal_deal_subtype_value_id],[curve_uom_conv_factor],[curve_fx_conv_factor],[price_fx_conv_factor],[curve_value],[fixed_cost],[fixed_price],[formula_value],[price_adder],[price_multiplier],[strike_price],[buy_sell_flag],[expired_term],[und_pnl_set],[fixed_cost_fx_conv_factor],[formula_fx_conv_factor],[price_adder1_fx_conv_factor],[price_adder2_fx_conv_factor],[volume_multiplier],[volume_multiplier2],[price_adder2],[pay_opposite],[market_value],[contract_value],[dis_market_value],[dis_contract_value]',
			'pnl_as_of_date',
			'm',
			2150
	UNION ALL
	SELECT	'source_deal_pnl_detail', 
			'_arch1',
			1,
			NULL,
			'[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor],[pnl_adjustment_value],[deal_volume],[curve_id],[accrued_interest],[price],[discount_rate],[no_days_left],[days_year],[discount_factor],[create_user],[create_ts],[update_user],[update_ts],[curve_as_of_date],[internal_deal_type_value_id],[internal_deal_subtype_value_id],[curve_uom_conv_factor],[curve_fx_conv_factor],[price_fx_conv_factor],[curve_value],[fixed_cost],[fixed_price],[formula_value],[price_adder],[price_multiplier],[strike_price],[buy_sell_flag],[expired_term],[und_pnl_set],[fixed_cost_fx_conv_factor],[formula_fx_conv_factor],[price_adder1_fx_conv_factor],[price_adder2_fx_conv_factor],[volume_multiplier],[volume_multiplier2],[price_adder2],[pay_opposite],[market_value],[contract_value],[dis_market_value],[dis_contract_value]',
			'pnl_as_of_date',
			'm',
			2150
	UNION ALL
	SELECT	'source_deal_pnl_detail', 
			'_arch2',
			0,
			NULL,
			'[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor],[pnl_adjustment_value],[deal_volume],[curve_id],[accrued_interest],[price],[discount_rate],[no_days_left],[days_year],[discount_factor],[create_user],[create_ts],[update_user],[update_ts],[curve_as_of_date],[internal_deal_type_value_id],[internal_deal_subtype_value_id],[curve_uom_conv_factor],[curve_fx_conv_factor],[price_fx_conv_factor],[curve_value],[fixed_cost],[fixed_price],[formula_value],[price_adder],[price_multiplier],[strike_price],[buy_sell_flag],[expired_term],[und_pnl_set],[fixed_cost_fx_conv_factor],[formula_fx_conv_factor],[price_adder1_fx_conv_factor],[price_adder2_fx_conv_factor],[volume_multiplier],[volume_multiplier2],[price_adder2],[pay_opposite],[market_value],[contract_value],[dis_market_value],[dis_contract_value]',
			'pnl_as_of_date',
			'm',
			2150
END

UPDATE	process_table_archive_policy
SET		frequency_type = 'd'
WHERE	tbl_name = 'source_deal_pnl_detail'