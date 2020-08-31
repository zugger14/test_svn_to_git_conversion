
UPDATE maintain_field_deal 
SET system_required = 'y'
WHERE header_detail = 'h'
	AND farrms_field_id = 'fas_deal_type_value_id'

UPDATE maintain_field_deal 
SET is_disable = 'n'
	, system_required = 'y'
WHERE header_detail = 'h'
	AND farrms_field_id = 'confirm_status_type'

UPDATE maintain_field_deal 
SET system_required = 'y',
	is_disable = 'y'
WHERE header_detail = 'd'
	AND farrms_field_id = 'buy_sell_flag'

UPDATE maintain_field_deal 
SET system_required = 'y'
WHERE header_detail = 'd'
	AND farrms_field_id = 'physical_financial_flag'

UPDATE maintain_field_deal 
SET system_required = 'y'
WHERE header_detail = 'd'
	AND farrms_field_id = 'fixed_price_currency_id'