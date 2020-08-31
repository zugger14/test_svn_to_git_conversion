-- Instrument Name
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000314)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000314, 'Instrument Name', 'Instrument Name', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000314 - Instrument Name.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000314 - Instrument Name already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000314)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000314, 'Instrument Name', 't', 'VARCHAR(100)', 'y', NULL, 'h', 100, -10000314
END


-- Deal Template
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000315)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000315, 'DealTemplate', 'Deal Template', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000315 - Deal Template.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000315 - Deal Template already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000315)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000315, 'DealTemplate', 'd', 'VARCHAR(100)', 'y', ' EXEC spa_getDealTemplate ''s''', 'h', 100, -10000315
END


IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Trayport Deal Template Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Trayport Deal Template Mapping', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'Trayport Deal Template Mapping'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Trayport Deal Template Mapping'
END

DECLARE @mapping_table_id INT
	  , @instrument_name INT
	  , @deal_template INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Trayport Deal Template Mapping'

SELECT @instrument_name = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000314

SELECT @deal_template = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000315

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'Instrument Name', @instrument_name, 'Deal Template', @deal_template, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Instrument Name'
	  , clm1_udf_id = @instrument_name
	  , clm2_label = 'Deal Template'
	  , clm2_udf_id = @deal_template  
	  , unique_columns_index = '1'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Trayport Deal Template Mapping'
END