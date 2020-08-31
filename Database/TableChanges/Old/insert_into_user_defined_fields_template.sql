
IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Index')
BEGIN
	INSERT INTO user_defined_fields_template
	(	
		field_name,
		Field_label,
		Field_type,
		data_type,
		is_required,
		sql_string,	
		udf_type,
		sequence,
		field_size,
		field_id
	)
	VALUES
	(
		300000,
		'Index',
		'd',
		'VARCHAR(150)',
		'n',
		'SELECT source_curve_def_id, curve_name FROM source_price_curve_def',	
		'h',
		NULL,
		30,
		300000
	)
	
END

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Tenor Bucket')
BEGIN
	INSERT INTO user_defined_fields_template
	(	
		field_name,
		Field_label,
		Field_type,
		data_type,
		is_required,
		sql_string,	
		udf_type,
		sequence,
		field_size,
		field_id
	)
	VALUES
	(
		300001,
		'Tenor Bucket',
		'd',
		'VARCHAR(150)',
		'n',
		'SELECT bucket_header_id, bucket_header_name FROM risk_tenor_bucket_header',	
		'h',
		NULL,
		30,
		300001
	)
END 

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Projection Index Group')
BEGIN
	INSERT INTO user_defined_fields_template
	(	
		field_name,
		Field_label,
		Field_type,
		data_type,
		is_required,
		sql_string,	
		udf_type,
		sequence,
		field_size,
		field_id
	)
	VALUES
	(
		300002,
		'Projection Index Group',
		'd',
		'VARCHAR(150)',
		'n',
		'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 53',	
		'h',
		NULL,
		30,
		300002
	)
END 

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'UOM From')
BEGIN
	INSERT INTO user_defined_fields_template
	(	
		field_name,
		Field_label,
		Field_type,
		data_type,
		is_required,
		sql_string,	
		udf_type,
		sequence,
		field_size,
		field_id
	)
	VALUES
	(
		300003,
		'UOM From',
		'd',
		'VARCHAR(150)',
		'n',
		'SELECT source_uom_id, uom_name FROM source_uom',	
		'h',
		NULL,
		30,
		300003
	)
END 

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'UOM To')
BEGIN
	INSERT INTO user_defined_fields_template
	(	
		field_name,
		Field_label,
		Field_type,
		data_type,
		is_required,
		sql_string,	
		udf_type,
		sequence,
		field_size,
		field_id
	)
	VALUES
	(
		300004,
		'UOM To',
		'd',
		'VARCHAR(150)',
		'n',
		'SELECT source_uom_id, uom_name FROM source_uom',	
		'h',
		NULL,
		30,
		300004
	)
END

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'ICE Trader')
BEGIN
	INSERT INTO user_defined_fields_template
	(	
		field_name,
		Field_label,
		Field_type,
		data_type,
		is_required,
		sql_string,	
		udf_type,
		sequence,
		field_size,
		field_id
	)
	VALUES
	(
		300005,
		'ICE Trader',
		't',
		'VARCHAR(150)',
		'n',
		'',	
		'h',
		NULL,
		30,
		300005
	)
END 

	IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'TRM Trader')
	BEGIN
		INSERT INTO user_defined_fields_template
	(	
		field_name,
		Field_label,
		Field_type,
		data_type,
		is_required,
		sql_string,	
		udf_type,
		sequence,
		field_size,
		field_id
	)
	VALUES
	(
		300006,
		'TRM Trader',
		'd',
		'VARCHAR(150)',
		'n',
		'SELECT st.source_trader_id, st.trader_name FROM source_traders st',	
		'h',
		NULL,
		30,
		300006
	)
END 

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'ICE Broker')
BEGIN
	INSERT INTO user_defined_fields_template
	(	
		field_name,
		Field_label,
		Field_type,
		data_type,
		is_required,
		sql_string,	
		udf_type,
		sequence,
		field_size,
		field_id
	)
	VALUES
	(
		300007,
		'ICE Broker',
		't',
		'VARCHAR(150)',
		'n',
		'',	
		'h',
		NULL,
		30,
		300007
	)
END 

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'TRM Broker')
BEGIN
	INSERT INTO user_defined_fields_template
	(	
		field_name,
		Field_label,
		Field_type,
		data_type,
		is_required,
		sql_string,	
		udf_type,
		sequence,
		field_size,
		field_id
	)
	VALUES
	(
		300008,
		'TRM Broker',
		'd',
		'VARCHAR(150)',
		'n',
		'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc WHERE ISNULL(sc.int_ext_flag, '''') = ''b''',	
		'h',
		NULL,
		30,
		300008
	)
END 

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'ICE Counterparty')
BEGIN
	INSERT INTO user_defined_fields_template
	(	
		field_name,
		Field_label,
		Field_type,
		data_type,
		is_required,
		sql_string,	
		udf_type,
		sequence,
		field_size,
		field_id
	)
	VALUES
	(
		300009,
		'ICE Counterparty',
		't',
		'VARCHAR(150)',
		'n',
		'',	
		'h',
		NULL,
		30,
		300009
	)
END 

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'TRM Counterparty')
BEGIN
INSERT INTO user_defined_fields_template
(	
	field_name,
	Field_label,
	Field_type,
	data_type,
	is_required,
	sql_string,	
	udf_type,
	sequence,
	field_size,
	field_id
)
VALUES
(
	300010,
	'TRM Counterparty',
	'd',
	'VARCHAR(150)',
	'n',
	'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc WHERE ISNULL(sc.int_ext_flag, '''') <> ''b''',	
	'h',
	NULL,
	30,
	3000010
)
END 

SELECT * FROM user_defined_fields_template

