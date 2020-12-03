UPDATE maintain_field_deal 
SET field_type='b' 
	, window_function_id='browse_shipper_code'
WHERE farrms_field_id IN ('shipper_code1', 'shipper_code2') 
AND header_detail = 'd'