--Block Definition
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000326)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000326, 'Block Definition', 'Block Definition', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000326 - Block Definition.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000326 - Block Definition already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF  

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000326)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000326, 'Block Definition', 'd', 'VARCHAR(100)', 'y', 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10018', 'h', 100, -10000326
END

IF NOT EXISTS(SELECT * FROM generic_mapping_header WHERE mapping_name = 'Trayport Block Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Trayport Block Mapping', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'Trayport Block Mapping'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Trayport Block Mapping'
END

DECLARE @mapping_table_id INT
	  , @source_instrument INT
	  , @block_definition INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Trayport Block Mapping'

SELECT @source_instrument = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = 50003251

SELECT @block_definition = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000326

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'Source Instrument', @source_instrument, 'Block Definition', @block_definition, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Source Instrument'
	  , clm1_udf_id = @source_instrument
	  , clm2_label = 'Block Definition'
	  , clm2_udf_id = @block_definition  
	  , unique_columns_index = '1'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Trayport Block Mapping'
END