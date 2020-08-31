IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5693)
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
		-5693,
		'LEI Code',
		't',
		'varchar(150)',
		'n',
		'h',
		'120',
		-5693
	)
	PRINT 'DATA INSERTED SUCCESSFULLY'

END