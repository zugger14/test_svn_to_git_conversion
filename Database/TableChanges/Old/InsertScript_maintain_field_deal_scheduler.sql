IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'scheduler')
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
	SELECT 164,
	       'scheduler',
	       'scheduler',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'SELECT cc.counterparty_contact_id, cc.name FROM counterparty_contacts cc INNER JOIN static_data_value sdv ON cc.contact_type = sdv.value_id WHERE sdv.type_id = 32200 AND sdv.code = ''scheduler''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END