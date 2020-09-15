SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000355)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000355, 'Reporting On Behalf', 'Reporting On Behalf', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000355 - Reporting On Behalf.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000355 - Reporting On Behalf already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Reporting On Behalf')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000355, 'Reporting On Behalf', 'd', 'VARCHAR(150)', 'n', 'SELECT ''y'' [value], ''Yes'' [code] UNION SELECT ''n'', ''No''', 'h', NULL, 400, -10000355
	PRINT 'UDF Created.'
END
ELSE
BEGIN
	PRINT 'UDF aleady exists.'
END
	
