DECLARE @field_id INT
SET @field_id = (SELECT  MAX(field_id) + 1 FROM maintain_field_deal)

IF NOT EXISTS(SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'product_classification')
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
	SELECT @field_id,
	       'product_classification',                                  
	       'Product Classification',
	       'd',
	       'int',
	       NULL,
	       'h',
	       'y',
	       'SELECT null [value_id], '''' [code] UNION ALL SELECT value_id, code FROM dbo.static_data_value WHERE type_id = 107400',
	       NULL,
	       'n',
	       NULL,
	       'n',
	       NULL,
	       'y',
	       'i',
	       'y' 
END

IF COL_LENGTH('source_deal_header', 'product_classification') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD product_classification INT
END

IF COL_LENGTH('source_deal_header_audit', 'product_classification') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD product_classification INT
END

IF COL_LENGTH('delete_source_deal_header', 'product_classification') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD product_classification INT
END

IF COL_LENGTH('source_deal_header_template', 'product_classification') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD product_classification INT
END