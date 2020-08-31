IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5620)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5620', 5500, 'PRP Code Power', 'PRP Code Power'
	SET IDENTITY_INSERT static_data_value OFF
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5621)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5621', 5500, 'PRP Code Gas', 'PRP Code Gas'
	SET IDENTITY_INSERT static_data_value OFF
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5622)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5622', 5500, 'EAN Code Power', 'EAN Code Power'
	SET IDENTITY_INSERT static_data_value OFF
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5623)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id, type_id, code, description)
	SELECT '-5623', 5500, 'EAN Code Gas', 'EAN Code Gas'
	SET IDENTITY_INSERT static_data_value OFF
END


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = -5620)
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5620, 'PRP Code Power', 't', 'varchar(150)','n',null,'h',120,-5620
END

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = -5621)
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5621, 'PRP Code Gas', 't', 'varchar(150)','n',null,'h',120,-5621
END

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = -5622)
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5622, 'EAN Code Power', 'd', 'varchar(150)','n',null,'h',120,-5622
END

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = -5623)
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5623, 'EAN Code Gas', 't', 'varchar(150)','n',null,'h',120,-5623
END