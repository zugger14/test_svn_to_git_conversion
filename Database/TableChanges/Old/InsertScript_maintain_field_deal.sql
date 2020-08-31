IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'counterparty_trader')
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
	SELECT 138,
	       'counterparty_trader',
	       'Counterparty Trader',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'SELECT cc.counterparty_contact_id, cc.name FROM counterparty_contacts cc INNER JOIN static_data_value sdv ON cc.contact_type = sdv.value_id WHERE sdv.type_id = 32200 AND sdv.code = ''Trader''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'internal_counterparty')
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
	SELECT 139,
	       'internal_counterparty',
	       'Internal Counterparty',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'EXEC spa_getsourcecounterparty @flag=''s'', @int_ext_flag=''i''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'settlement_vol_type')
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
	SELECT 140,
	       'settlement_vol_type',
	       'Settlement Volume',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'SELECT ''n'' code,''Net'' Data UNION  SELECT ''g'' code,''Gross'' Data',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'detail_commodity_id')
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
	SELECT 141,
	       'detail_commodity_id',
	       'Commodity',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'EXEC spa_source_commodity_maintain ''a''',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT * FROM maintain_field_deal WHERE farrms_field_id = 'detail_pricing')
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
	SELECT 142,
	       'detail_pricing',
	       'Pricing',
	       'd',
	       'int',
	       NULL,
	       'd',
	       'n',
	       'SELECT value_id,code FROM dbo.static_data_value WHERE type_id=1600',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT * FROM maintain_field_deal WHERE farrms_field_id = 'pricing_start')
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
	SELECT 143,
	       'pricing_start',
	       'Pricing Start',
	       'a',
	       'datetime',
	       NULL,
	       'd',
	       'n',
	       NULL,
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT * FROM maintain_field_deal WHERE farrms_field_id = 'pricing_end')
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
	SELECT 144,
	       'pricing_end',
	       'Pricing End',
	       'a',
	       'datetime',
	       NULL,
	       'd',
	       'n',
	       NULL,
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END