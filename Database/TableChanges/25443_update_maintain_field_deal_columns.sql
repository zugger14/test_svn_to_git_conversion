UPDATE maintain_field_deal 
SET update_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'physical_financial_flag'

UPDATE maintain_field_deal 
SET update_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'entire_term_start'

UPDATE maintain_field_deal 
SET update_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'entire_term_end'

UPDATE maintain_field_deal 
SET insert_required = 'y'
	, update_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'source_deal_type_id'

UPDATE maintain_field_deal 
SET insert_required = 'y'
	, update_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'contract_id'

UPDATE maintain_field_deal 
SET system_required = 'y'
	, insert_required = 'y'
	, update_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'commodity_id'

UPDATE maintain_field_deal 
SET system_required = 'y'
	, insert_required = 'y'
	, update_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'pricing_type'

UPDATE maintain_field_deal 
SET system_required = 'y'
	, update_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'profile_granularity'

UPDATE maintain_field_deal 
SET system_required = 'y'
	, insert_required = 'y'
	, update_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'internal_desk_id'

UPDATE maintain_field_deal 
SET system_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'deal_status'

UPDATE maintain_field_deal 
SET system_required = 'y' 
WHERE header_detail = 'h'
	AND farrms_field_id = 'confirm_status_type'

UPDATE maintain_field_deal 
SET system_required = 'y'
	, update_required = 'y' 
WHERE header_detail = 'd'
	AND farrms_field_id = 'location_id'

UPDATE maintain_field_deal 
SET system_required = 'y' 
WHERE header_detail = 'd'
	AND farrms_field_id = 'fixed_price_currency_id'

UPDATE maintain_field_deal 
SET system_required = 'y' 
WHERE header_detail = 'd'
	AND farrms_field_id = 'total_volume'

UPDATE maintain_field_deal 
SET system_required = 'y' 
WHERE header_detail = 'd'
	AND farrms_field_id = 'position_uom'