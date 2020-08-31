IF NOT EXISTS (SELECT 1 FROM application_ui_template_definition WHERE farrms_field_id = 'subsidiary_id' AND application_function_id = 10222300)
BEGIN
	INSERT INTO application_ui_template_definition
	(
		application_function_id,
		field_id,
		farrms_field_id,
		default_label,
		field_type,
		data_type,
		header_detail,
		system_required,
		field_size,
		is_disable,
		is_hidden,
		insert_required,
		data_flag,
		blank_option,
		is_primary,
		is_udf,
		is_identity
	)
	SELECT 10222300,
		   'subsidiary_id',
		   'subsidiary_id',
		   'Subsidiary',
		   'browser_label',
		   'int',
		   'h',
		   'n',
		   220,
		   'n',
		   'n',
		   'y',
		   'n',
		   'y',
		   'y',
		   'n',
		   'n'		
END

IF NOT EXISTS (SELECT 1 FROM application_ui_template_definition WHERE farrms_field_id = 'strategy_id' AND application_function_id = 10222300)
BEGIN
	INSERT INTO application_ui_template_definition
	(
		application_function_id,
		field_id,
		farrms_field_id,
		default_label,
		field_type,
		data_type,
		header_detail,
		system_required,
		field_size,
		is_disable,
		is_hidden,
		insert_required,
		data_flag,
		blank_option,
		is_primary,
		is_udf,
		is_identity
	)
	SELECT 10222300,
		   'strategy_id',
		   'strategy_id',
		   'Strategy',
		   'browser_label',
		   'int',
		   'h',
		   'n',
		   220,
		   'n',
		   'n',
		   'y',
		   'n',
		   'y',
		   'y',
		   'n',
		   'n'		
END

IF NOT EXISTS (SELECT 1 FROM application_ui_template_definition WHERE farrms_field_id = 'book_id' AND application_function_id = 10222300)
BEGIN
	INSERT INTO application_ui_template_definition
	(
		application_function_id,
		field_id,
		farrms_field_id,
		default_label,
		field_type,
		data_type,
		header_detail,
		system_required,
		field_size,
		is_disable,
		is_hidden,
		insert_required,
		data_flag,
		blank_option,
		is_primary,
		is_udf,
		is_identity
	)
	SELECT 10222300,
		   'book_id',
		   'book_id',
		   'Book',
		   'browser_label',
		   'int',
		   'h',
		   'n',
		   220,
		   'n',
		   'n',
		   'y',
		   'n',
		   'y',
		   'y',
		   'n',
		   'n'		
END

IF NOT EXISTS (SELECT 1 FROM application_ui_template_definition WHERE farrms_field_id = 'subbook_id' AND application_function_id = 10222300)
BEGIN
	INSERT INTO application_ui_template_definition
	(
		application_function_id,
		field_id,
		farrms_field_id,
		default_label,
		field_type,
		data_type,
		header_detail,
		system_required,
		field_size,
		is_disable,
		is_hidden,
		insert_required,
		data_flag,
		blank_option,
		is_primary,
		is_udf,
		is_identity
	)
	SELECT 10222300,
		   'subbook_id',
		   'subbook_id',
		   'Sub Book',
		   'browser_label',
		   'int',
		   'h',
		   'n',
		   220,
		   'n',
		   'n',
		   'y',
		   'n',
		   'y',
		   'y',
		   'n',
		   'n'		
END

IF NOT EXISTS (SELECT 1 FROM application_ui_template_definition WHERE farrms_field_id = 'label_counterparty_id' AND application_function_id = 10222300)
BEGIN
	INSERT INTO application_ui_template_definition
	(
		application_function_id,
		field_id,
		farrms_field_id,
		default_label,
		field_type,
		data_type,
		header_detail,
		system_required,
		field_size,
		is_disable,
		is_hidden,
		insert_required,
		data_flag,
		blank_option,
		is_primary,
		is_udf,
		is_identity
	)
	SELECT 10222300,
		   'label_counterparty_id',
		   'label_counterparty_id',
		   'Counterparty ID Browser',
		   'browser_label',
		   'int',
		   'h',
		   'n',
		   220,
		   'n',
		   'n',
		   'y',
		   'n',
		   'y',
		   'y',
		   'n',
		   'n'		
END

IF NOT EXISTS (SELECT 1 FROM application_ui_template_definition WHERE farrms_field_id = 'label_contract_ids' AND application_function_id = 10222300)
BEGIN
	INSERT INTO application_ui_template_definition
	(
		application_function_id,
		field_id,
		farrms_field_id,
		default_label,
		field_type,
		data_type,
		header_detail,
		system_required,
		field_size,
		is_disable,
		is_hidden,
		insert_required,
		data_flag,
		blank_option,
		is_primary,
		is_udf,
		is_identity
	)
	SELECT 10222300,
		   'label_contract_ids',
		   'label_contract_ids',
		   'Contract ID Browser',
		   'browser_label',
		   'int',
		   'h',
		   'n',
		   220,
		   'n',
		   'n',
		   'y',
		   'n',
		   'y',
		   'y',
		   'n',
		   'n'		
END

IF NOT EXISTS (SELECT 1 FROM application_ui_template_definition WHERE farrms_field_id = 'label_deal_status' AND application_function_id = 10222300)
BEGIN
	INSERT INTO application_ui_template_definition
	(
		application_function_id,
		field_id,
		farrms_field_id,
		default_label,
		field_type,
		data_type,
		header_detail,
		system_required,
		field_size,
		is_disable,
		is_hidden,
		insert_required,
		data_flag,
		blank_option,
		is_primary,
		is_udf,
		is_identity
	)
	SELECT 10222300,
		   'label_deal_status',
		   'label_deal_status',
		   'Deal Status Browser',
		   'browser_label',
		   'int',
		   'h',
		   'n',
		   220,
		   'n',
		   'n',
		   'y',
		   'n',
		   'y',
		   'y',
		   'n',
		   'n'		
END

IF NOT EXISTS (SELECT 1 FROM application_ui_template_definition WHERE farrms_field_id = 'label_deal_filter' AND application_function_id = 10222300)
BEGIN
	INSERT INTO application_ui_template_definition
	(
		application_function_id,
		field_id,
		farrms_field_id,
		default_label,
		field_type,
		data_type,
		header_detail,
		system_required,
		field_size,
		is_disable,
		is_hidden,
		insert_required,
		data_flag,
		blank_option,
		is_primary,
		is_udf,
		is_identity
	)
	SELECT 10222300,
		   'label_deal_filter',
		   'label_deal_filter',
		   'Deal Filter Browser',
		   'browser_label',
		   'int',
		   'h',
		   'n',
		   220,
		   'n',
		   'n',
		   'y',
		   'n',
		   'y',
		   'y',
		   'n',
		   'n'		
END