DECLARE @field_id INT
SELECT @field_id = MAX(field_id) FROM maintain_field_deal
IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'fx_rounding')
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
	SELECT @field_id +1,
	       'fx_rounding',
	       'FX Rounding',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'SELECT 0 [name], 0 [value] UNION SELECT 1,1 UNION SELECT 2,2 UNION SELECT 3,3 UNION SELECT 4,4 UNION SELECT 5,5 UNION SELECT 6,6 UNION SELECT 7,7 UNION SELECT 8,8 UNION SELECT 9,9 UNION SELECT 10,10',
	       180,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF COL_LENGTH('source_deal_header', 'fx_rounding') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD fx_rounding INT
END

IF COL_LENGTH('source_deal_header_audit', 'fx_rounding') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD fx_rounding INT
END

IF COL_LENGTH('delete_source_deal_header', 'fx_rounding') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD fx_rounding INT
END

IF COL_LENGTH('source_deal_header_template', 'fx_rounding') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD fx_rounding INT
END

SELECT @field_id = MAX(field_id) FROM maintain_field_deal
IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'fx_option')
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
	SELECT @field_id + 1,
	       'fx_option',
	       'FX Option',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'n',
	       'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 104500',
	       180,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF COL_LENGTH('source_deal_header', 'fx_option') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD fx_option INT
END

IF COL_LENGTH('source_deal_header_audit', 'fx_option') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD fx_option INT
END

IF COL_LENGTH('delete_source_deal_header', 'fx_option') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD fx_option INT
END

IF COL_LENGTH('source_deal_header_template', 'fx_option') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD fx_option INT
END



