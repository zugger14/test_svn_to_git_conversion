DECLARE @mapping_table_id INT
DECLARE @udf_id INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Transfer Volume Mapping'

SELECT @udf_id = udf_template_id FROM user_defined_fields_template
WHERE field_label = 'Delivery Path'

UPDATE generic_mapping_definition 
SET clm20_label = 'Delivery Path',
	clm20_udf_id = @udf_id
WHERE mapping_table_id = @mapping_table_id

GO