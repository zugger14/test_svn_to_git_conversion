SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5617)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5617, 5500, 'Actual Volume', 'Actual Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5617 - Actual Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value -5617 - Actual Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5667)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5667, 5500, 'Contract Volume', 'Contract Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5667 - Contract Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value -5667 - Contract Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF




--insert udf

--select * from user_defined_fields_template where field_name IN (-5617, -5667)
IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template where field_name = -5617) 
BEGIN 
	INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type
											, sequence, field_size, field_id)
	SELECT -5617, 'Actual Volume', 't', 'number', 'n', '', 'd', '', 120, -5617
END 

GO

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template where field_name = -5667) 
BEGIN 
	INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type
											, sequence, field_size, field_id)
	SELECT -5667, 'Contract Volume', 't', 'number', 'n', '', 'd', '', 120, -5667
END 

GO

