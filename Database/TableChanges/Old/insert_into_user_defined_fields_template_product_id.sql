IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Product ID')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -5720, 'Product ID', 'd', 'VARCHAR(150)', 'n', 'SELECT source_product_id, product_name FROM source_product', 'h', NULL, 180, -5720
END