IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5711)
BEGIN
	PRINT 'Data already exists.'
	RETURN
END
ELSE
BEGIN
	DECLARE @mapping_table_id_sap_doc INT
	SELECT @mapping_table_id_sap_doc = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Non EFET SAP Doc Type'

	DECLARE @mapping_table_id_sap_gl INT
	SELECT @mapping_table_id_sap_gl = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Non EFET SAP GL Mapping'
	
	DELETE FROM user_defined_fields_template WHERE Field_label = 'Sub Process'
	DELETE FROM static_data_value WHERE code = 'Sub_Process'
	DELETE FROM static_data_value WHERE code = 'Sub Process'
	
	SET IDENTITY_INSERT static_data_value ON
	IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5711)
	BEGIN
		INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
		VALUES (-5711, 5500, 'Sub Process', 'Sub Process', 'farrms_admin', GETDATE())
		PRINT 'Inserted static data value -5711 - Sub Process.'
	END
	ELSE
	BEGIN
		PRINT 'Static data value -5711 - Sub Process already EXISTS.'
	END
	SET IDENTITY_INSERT static_data_value OFF
	
	IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Sub Process')
	BEGIN
		INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id) 
		VALUES (-5711, 'Sub Process', 'd', 'VARCHAR(150)', 'n', 'SELECT  ''i'' as ID, ''Inbound'' name UNION ALL SELECT  ''o'' as ID, ''Outbound'' name UNION ALL  SELECT ''s'' as ID, ''Self-Billing'' name', 'h', NULL, 30,-5711)
	END

	DECLARE @udf_template_id_sub_process INT 
	SET @udf_template_id_sub_process = SCOPE_IDENTITY() 
	
	UPDATE generic_mapping_definition
	SET clm2_label = 'Sub Process', 
		clm2_udf_id = @udf_template_id_sub_process
	WHERE mapping_table_id = @mapping_table_id_sap_doc

	UPDATE generic_mapping_definition
	SET clm2_label = 'Sub Process', 
		clm2_udf_id = @udf_template_id_sub_process
	WHERE mapping_table_id = @mapping_table_id_sap_gl
END