IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'confirmation_template')
BEGIN
	INSERT INTO maintain_field_deal (
	    field_id,
	    farrms_field_id,
	    default_label,
	    field_type,
	    data_type,
	    default_validation,
	    header_detail,
	    system_required,
	    sql_string,
	    field_size,
	    is_disable,
	    window_function_id,
	    is_hidden,
	    default_value,
	    insert_required,
	    data_flag,
	    update_required
	  )
	SELECT 185,
	       'confirmation_template',
	       'Confirmation Template',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'SELECT template_id,template_name FROM contract_report_template WHERE template_type=33 AND template_category = 42018',
	       180,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END