SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000023)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000023, 5500, 'Corporate Sector', 'Corporate Sector', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000023 - Corporate Sector.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000023 - Corporate Sector already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Corporate Sector')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000023, 'Corporate Sector', 't', 'VARCHAR(150)', 'n', NULL, 'h', NULL, 400, -10000023
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'