DECLARE @mapping_table_id INT
DECLARE @udf_id INT

SELECT @mapping_table_id =select  mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Transfer Volume Mapping'

SELECT @udf_id = udf_template_id FROM user_defined_fields_template
WHERE field_label = 'Location'

UPDATE generic_mapping_definition 
SET clm11_label = 'Location',
	clm11_udf_id = @udf_id
WHERE mapping_table_id = @mapping_table_id

GO
