IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'counterparty_id2')
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
	SELECT 146,
	       'counterparty_id2',
	       'Counterparty2',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'EXEC spa_getsourcecounterparty @flag=''s''',
	       180,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'trader_id2')
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
	SELECT 147,
	       'trader_id2',
	       'Trader2',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'SELECT source_trader_id, trader_name FROM dbo.source_traders ORDER BY trader_name',
	       180,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END