IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5694)
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
		-5694,
		'LEI Code Type',
		't',
		'varchar(150)',
		'n',
		'h',
		'120',
		-5694
	)
	PRINT 'DATA INSERTED SUCCESSFULLY'

END