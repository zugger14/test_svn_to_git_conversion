SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000020)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000020, 5500, 'EEA', 'EEA', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000020 - EEA.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000020 - EEA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'EEA')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000020, 'EEA', 'd', 'VARCHAR(150)', 'n', 'SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''', 'h', NULL, 400, -10000020
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'