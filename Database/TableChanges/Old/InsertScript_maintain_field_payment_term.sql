IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'payment_term')
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
	SELECT 174,
	       'payment_term',
	       'Payment Term',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'SELECT value_id, code FROM static_data_value WHERE type_id = 20000 ORDER BY code',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END