IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'profile_granularity')
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
	SELECT 191,
	       'profile_granularity',
	       'Volume Frequency',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 978, @value_ids = ''993,981,982,980,991,992,990''',
	       180,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END