IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'origin')
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
	SELECT 155,
	       'origin',
	       'Origin',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'EXEC spa_counterparty_products ''o''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'form')
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
	SELECT 156,
	       'form',
	       'Form',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'EXEC spa_counterparty_products ''f''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'organic')
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
	SELECT 157,
	       'organic',
	       'Organic',
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

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'attribute1')
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
	SELECT 158,
	       'attribute1',
	       'Attribute1',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'EXEC spa_counterparty_products ''a''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'attribute2')
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
	SELECT 159,
	       'attribute2',
	       'Attribute2',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'EXEC spa_counterparty_products ''b''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'attribute3')
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
	SELECT 160,
	       'attribute3',
	       'Attribute3',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'EXEC spa_counterparty_products ''c''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'attribute4')
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
	SELECT 161,
	       'attribute4',
	       'Attribute4',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'EXEC spa_counterparty_products ''e''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'attribute5')
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
	SELECT 162,
	       'attribute5',
	       'Attribute5',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'EXEC spa_counterparty_products ''f''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END