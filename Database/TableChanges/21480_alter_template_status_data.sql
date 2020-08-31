UPDATE mftd 
	SET mftd.default_value = 5604
		, mftd.value_required = 'y'
FROM maintain_field_template_detail mftd
INNER JOIN maintain_field_deal mfd
ON mftd.field_id = mfd.field_id
WHERE  mfd.farrms_field_id =  'deal_status'
 
UPDATE source_deal_header_template SET deal_status = 5604
 
UPDATE mftd 
	SET  mftd.default_value = 17200
		, mftd.value_required = 'y'
FROM maintain_field_template_detail mftd
INNER JOIN maintain_field_deal mfd
	ON mftd.field_id = mfd.field_id
WHERE  mfd.farrms_field_id =  'confirm_status_type'
 
UPDATE source_deal_header_template SET confirm_status_type = 17200
 