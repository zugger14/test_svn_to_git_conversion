SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000184)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000184, 'Evergreen Deal', 'Evergreen Deal', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000184 - Evergreen Deal.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000184 - Evergreen Deal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -10000184)
BEGIN
	INSERT INTO user_defined_fields_template (
		field_name,
		field_label,
		Field_type,
		data_type,
		is_required,
		udf_type,
		field_id,
		sql_string,
		default_Value
	) VALUES (
		-10000184,
		'Evergreen Deal',
		'd',
		'nchar(1)',
		'n',
		'h',
		-10000184,
		'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No''',
		'n'
	)
	PRINT 'DATA INSERTED SUCCESSFULLY'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000185)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000185, 'Renew Granularity', 'Renew Granularity', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000185 - Renew Granularity.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000185 - Renew Granularity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF                      

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -10000185)
BEGIN
	INSERT INTO user_defined_fields_template (
		field_name,
		field_label,
		Field_type,
		data_type,
		is_required,
		udf_type,
		field_id,
		sql_string
	) VALUES (
		-10000185,
		'Renew Granularity',
		'd',
		'INT',
		'n',
		'h',
		-10000185,
		'SELECT  ''m'' id,''Monthly'' val UNION SELECT ''q'', ''Quarterly'' UNION SELECT ''s'',''Semi-Annually'' UNION SELECT ''a'', ''Annually'' UNION SELECT ''d'', ''Daily'' '
	)
	PRINT 'DATA INSERTED SUCCESSFULLY'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000186)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000186, 'Cancellation Notice Days', 'Cancellation Notice Days', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000186 - Cancellation Notice Days.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000186 - Cancellation Notice Days already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -10000186)
BEGIN
	INSERT INTO user_defined_fields_template (
		field_name,
		field_label,
		Field_type,
		data_type,
		is_required,
		udf_type,
		field_id
	) VALUES (
		-10000186,
		'Cancellation Notice Days',
		't',
		'INT',
		'n',
		'h',
		-10000186
	)
	PRINT 'DATA INSERTED SUCCESSFULLY'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000187)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000187, 'Cancellation Alert Days', 'Cancellation Alert Days', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000187 - Cancellation Alert Days.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000187 - Cancellation Alert Days already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF  

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -10000187)
BEGIN
	INSERT INTO user_defined_fields_template (
		field_name,
		field_label,
		Field_type,
		data_type,
		is_required,
		udf_type,
		field_id
	) VALUES (
		-10000187,
		'Cancellation Alert Days',
		't',
		'INT',
		'n',
		'h',
		-10000187
	)
	PRINT 'DATA INSERTED SUCCESSFULLY'
END          

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000188)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000188, 'Cancel Date', 'Cancel Date', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000188 - Cancel Date.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000188 - Cancel Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -10000188)
BEGIN
	INSERT INTO user_defined_fields_template (
		field_name,
		field_label,
		Field_type,
		data_type,
		is_required,
		udf_type,
		field_id
	) VALUES (
		-10000188,
		'Cancel Date',
		'a',
		'DATETIME',
		'n',
		'h',
		-10000188
	)
	PRINT 'DATA INSERTED SUCCESSFULLY'
END
