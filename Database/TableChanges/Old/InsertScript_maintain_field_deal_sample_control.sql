IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'sample_control')
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
	SELECT 168,
	       'sample_control',
	       'Subject to Sample Control',
	       'c',
	       'char',
	       NULL,
	       'h',
	       'n',
	       'SELECT ''y'' code, ''Yes'' value UNION select ''n'',''No''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'detail_sample_control')
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
	SELECT 169,
	       'detail_sample_control',
	       'Subject to Sample Control',
	       'c',
	       'char',
	       NULL,
	       'd',
	       'n',
	       'SELECT ''y'' code, ''Yes'' value UNION select ''n'',''No''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END