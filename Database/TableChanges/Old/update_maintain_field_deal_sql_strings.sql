UPDATE maintain_field_deal SET field_size = 180

UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_getDealTemplate @flag=''s'''
WHERE farrms_field_id = 'template_id'

UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_source_deal_type_maintain ''x'''
WHERE farrms_field_id = 'source_deal_type_id'

UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_source_deal_type_maintain ''x'', ''y'''
WHERE farrms_field_id = 'deal_sub_type_type_id'

UPDATE maintain_field_deal
SET field_type = 'a',
	is_disable = 'y'
WHERE farrms_field_id IN ('create_ts', 'update_ts')

UPDATE maintain_field_deal
SET field_type = 't',
	is_disable = 'y'
WHERE farrms_field_id IN ('create_user', 'update_user')

UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_source_minor_location ''o'', @is_active = ''y'''
WHERE farrms_field_id = 'location_id'

UPDATE maintain_field_deal
SET sql_string = 'EXEC spa_source_commodity_maintain ''a'''
WHERE farrms_field_id = 'commodity_id'

UPDATE maintain_field_deal
SET data_type = 'number'
WHERE farrms_field_id IN ('deal_volume','volume_left', 'settlement_volume', 'price_adder', 'price_multiplier', 'multiplier', 'price_adder2', 'volume_multiplier2', 'total_volume', 'capacity', 'standard_yearly_volume')

UPDATE maintain_field_deal
SET data_type = 'price'
WHERE farrms_field_id IN ('rec_price', 'broker_unit_fees', 'broker_fixed_cost', 'fixed_price', 'option_strike_price', 'fixed_cost')

UPDATE user_defined_fields_template
SET data_type = 'number'
WHERE data_type IN ('float', 'numeric')

UPDATE maintain_field_deal
SET is_disable = 'n'
WHERE farrms_field_id IN ('term_start', 'term_end', 'trader_id', 'deal_date')

UPDATE maintain_field_deal 
SET field_size = 100
WHERE header_detail = 'd' AND 
(farrms_field_id IN ('physical_financial_flag', 'buy_sell_flag', 'Leg', 'deal_volume', 'total_volume', 'term_frequency', 'deal_volume_frequency')
OR farrms_field_id LIKE '%uom%'
OR farrms_field_id LIKE '%currency%'
OR farrms_field_id LIKE '%cost%'
OR farrms_field_id LIKE '%price%')


