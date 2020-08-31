SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000019)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000019, 5500, 'Financial/Non-Financial', 'Financial/Non-Financial', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000019 - Financial/Non-Financial.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000019 - Financial/Non-Financial already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Financial/Non-Financial')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000019, 'Financial/Non-Financial', 'd', 'VARCHAR(150)', 'n', 'SELECT ''F'' id, ''Financial'' code UNION ALL SELECT ''N'', ''Non-Financial''', 'h', NULL, 400, -10000019
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'