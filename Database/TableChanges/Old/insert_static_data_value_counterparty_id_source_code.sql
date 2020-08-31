
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5615)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5615', 5500, 'Counterparty ID UDF', 'Counterparty ID UDF'
	SET IDENTITY_INSERT static_data_value OFF
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5616)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5616', 5500, 'Source Code', 'Source Code'
	SET IDENTITY_INSERT static_data_value OFF
END


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = -5615)
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5615, 'counterparty id udf', 't', 'varchar(150)','n',null,'h',120,-5615
END

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = -5616)
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5616, 'source code', 't', 'varchar(150)','n',null,'h',120,-5616
END