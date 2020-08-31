IF NOT EXISTS (SELECT * FROM process_table_archive_policy WHERE tbl_name = 'source_deal_detail_audit')
BEGIN
	INSERT INTO	process_table_archive_policy
	SELECT	'source_deal_detail_audit', 
			'',
			0,
			NULL,
			'source_deal_detail_id,source_deal_header_id,term_start,term_end,Leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,deal_detail_description,formula_id,volume_left,settlement_volume,settlement_uom,create_user,create_ts,update_user,update_ts,user_action,price_adder,price_multiplier,settlement_date,day_count_id,location_id,physical_financial_flag,Booked,fixed_cost,header_audit_id,multiplier,adder_currency_id,fixed_cost_currency_id,formula_currency_id,price_adder2,price_adder_currency2,volume_multiplier2,total_volume,pay_opposite,formula_text,capacity,meter_id,settlement_currency,standard_yearly_volume,price_uom_id,category,profile_code,pv_party',
			'update_ts',
			'd',
			2150
	UNION ALL
	SELECT	'source_deal_detail_audit', 
			'_arch1',
			1,
			NULL,
			'source_deal_detail_id,source_deal_header_id,term_start,term_end,Leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,deal_detail_description,formula_id,volume_left,settlement_volume,settlement_uom,create_user,create_ts,update_user,update_ts,user_action,price_adder,price_multiplier,settlement_date,day_count_id,location_id,physical_financial_flag,Booked,fixed_cost,header_audit_id,multiplier,adder_currency_id,fixed_cost_currency_id,formula_currency_id,price_adder2,price_adder_currency2,volume_multiplier2,total_volume,pay_opposite,formula_text,capacity,meter_id,settlement_currency,standard_yearly_volume,price_uom_id,category,profile_code,pv_party',
			'update_ts',
			'd',
			2150
	UNION ALL
	SELECT	'source_deal_detail_audit', 
			'_arch2',
			0,
			NULL,
			'source_deal_detail_id,source_deal_header_id,term_start,term_end,Leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,deal_detail_description,formula_id,volume_left,settlement_volume,settlement_uom,create_user,create_ts,update_user,update_ts,user_action,price_adder,price_multiplier,settlement_date,day_count_id,location_id,physical_financial_flag,Booked,fixed_cost,header_audit_id,multiplier,adder_currency_id,fixed_cost_currency_id,formula_currency_id,price_adder2,price_adder_currency2,volume_multiplier2,total_volume,pay_opposite,formula_text,capacity,meter_id,settlement_currency,standard_yearly_volume,price_uom_id,category,profile_code,pv_party',
			'update_ts',
			'd',
			2150
END