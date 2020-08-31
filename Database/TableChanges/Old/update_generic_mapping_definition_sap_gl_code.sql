UPDATE dbo.generic_mapping_definition 
SET clm8_udf_id = 
(
	SELECT udf_template_id FROM dbo.user_defined_fields_template WHERE field_name = 
	(
		SELECT value_id  FROM dbo.static_data_value WHERE code = 'Accounting Key'
	)
) WHERE mapping_table_id = 41
