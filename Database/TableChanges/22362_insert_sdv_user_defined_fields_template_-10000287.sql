SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000287)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000287, 'Service Type', 'Service Type', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000287 - Service Type.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000287 - Service Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'Service Type')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000287','Service Type','d','INT','n','SELECT ''1'' ID, ''Unit Contingent'' code UNION ALL SELECT ''2'' ID, ''Firm'' code  UNION ALL SELECT ''3'' ID, ''Forward Transfer'' code ','h',230,-10000287
END 
ELSE 
BEGIN
	UPDATE user_defined_fields_template
		SET data_type = 'INT'
	WHERE field_label = 'Service Type'
END
