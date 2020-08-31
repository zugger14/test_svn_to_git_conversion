IF NOT EXISTS(SELECT * FROM maintain_field_deal WHERE farrms_field_id = 'arbitration')
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
	SELECT 177,
	       'arbitration',
	       'Arbitration',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'SELECT value_id,code FROM dbo.static_data_value WHERE type_id=42300',
	       180,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END