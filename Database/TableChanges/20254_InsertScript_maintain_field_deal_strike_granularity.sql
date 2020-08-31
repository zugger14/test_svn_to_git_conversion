IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'strike_granularity')
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
	SELECT 189,
	       'strike_granularity',
	       'Strike Granularity',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 978',
	       180,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END