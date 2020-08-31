IF NOT EXISTS(SELECT * FROM maintain_field_deal WHERE farrms_field_id = 'counterparty2_trader')
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
	SELECT 178,
	       'counterparty2_trader',
	       'Counterpaty2 Trader',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'SELECT cc.counterparty_contact_id, cc.name FROM counterparty_contacts cc INNER JOIN static_data_value sdv ON cc.contact_type = sdv.value_id WHERE sdv.type_id = 32200 AND sdv.value_id = -32200',
	       180,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END