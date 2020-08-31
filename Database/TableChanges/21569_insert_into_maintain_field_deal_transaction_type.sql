IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'fas_deal_type_value_id')
BEGIN
	DECLARE @field_id INT
	SELECT @field_id = MAX(field_id) + 1 FROM maintain_field_deal
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
	SELECT @field_id,
	       'fas_deal_type_value_id',                                  
	       'Transaction Type',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'y',
	       'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 400',
	       180,
	       'n',
	       NULL,
	       'n',
	       400,
	       'y',
	       'i',
	       'y' 
END
IF COL_LENGTH('source_deal_header', 'fas_deal_type_value_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD fas_deal_type_value_id INT
END

IF COL_LENGTH('source_deal_header_audit', 'fas_deal_type_value_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD fas_deal_type_value_id INT
END

IF COL_LENGTH('delete_source_deal_header', 'fas_deal_type_value_id') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD fas_deal_type_value_id INT
END

IF COL_LENGTH('source_deal_header_template', 'fas_deal_type_value_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD fas_deal_type_value_id INT
END