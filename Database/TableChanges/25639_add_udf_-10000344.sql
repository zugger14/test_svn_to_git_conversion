SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000344)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000344, 'ECM Reportable', 'ECM Reportable', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000344 - ECM Reportable.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000344 - ECM Reportable already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF    


IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'ECM Reportable')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000344, 'ECM Reportable', 'd', 'int', 'n', 'SELECT ''y'' [value], ''Yes'' [code] UNION SELECT ''n'', ''No''', 'o', NULL, 400, -10000344
	PRINT 'UDF Created.'
END
ELSE
BEGIN
	PRINT 'UDF aleady exists.'
END