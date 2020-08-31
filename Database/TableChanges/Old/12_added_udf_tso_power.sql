SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5695)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5695, 5500, 'TSO power', 'TSO power', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5695 - TSO power.'
END
ELSE
BEGIN
	PRINT 'Static data value -5695 - TSO power already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5695)
BEGIN
	INSERT INTO user_defined_fields_template (
		field_name,
		field_label,
		Field_type,
		data_type,
		is_required,
		udf_type,
		field_size,
		field_id
	) VALUES (
		-5695,
		'TSO power',
		't',
		'varchar(150)',
		'n',
		'h',
		'120',
		-5695
	)
	PRINT 'DATA INSERTED SUCCESSFULLY'

END