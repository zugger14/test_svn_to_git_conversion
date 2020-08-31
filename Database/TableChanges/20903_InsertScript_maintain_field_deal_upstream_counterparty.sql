IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'upstream_counterparty')
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
	SELECT 201,
	       'upstream_counterparty',
	       'Upstream Counterparty',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'EXEC spa_source_counterparty_maintain @flag = ''c'', @is_active = ''y'', @not_int_ext_flag = ''b''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END