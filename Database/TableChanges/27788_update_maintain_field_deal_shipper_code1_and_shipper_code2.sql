UPDATE maintain_field_deal 
SET field_type='d' 
	, window_function_id = NULL
WHERE farrms_field_id IN ('shipper_code1', 'shipper_code2') 
AND header_detail = 'd'