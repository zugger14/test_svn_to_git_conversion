DECLARE @static_data_value INT
SELECT @static_data_value = value_id FROM static_data_value WHERE code = 'Order ID' AND type_id = 5500

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Order ID')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT @static_data_value, 'Order ID', 't', 'nvarchar(MAX)', 'n', NULL, 'h', NULL, 400, @static_data_value
	PRINT 'UDF Created.'
END
ELSE
BEGIN
	PRINT 'UDF aleady exists.'
END

IF Exists(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Order ID')
BEGIN
DECLARE @mapping_table_id INT   
SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'XConnect Tag Definition' 

DECLARE @tag_id int 
SELECT @tag_id = (MAX(clm1_value) + 1) FROM generic_mapping_values WHERE mapping_table_id = @mapping_table_id and clm5_value = 7

IF NOT EXISTS(SELECT 1 from generic_mapping_header gmh INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id 
	WHERE mapping_name = 'XConnect Tag Definition' AND gmv.clm4_value = 'OrderID' AND gmv.clm5_value IN('7')) 
BEGIN 
	INSERT INTO generic_mapping_values(mapping_table_id, clm1_value, clm2_value, clm3_value, clm4_value, clm5_value) 
	VALUES (@mapping_table_id,@tag_id,'OrderID',NULL,'OrderID','7')
END
END
