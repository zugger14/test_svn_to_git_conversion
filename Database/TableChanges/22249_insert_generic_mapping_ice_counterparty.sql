DELETE static_data_value WHERE [type_id] = 5500 AND code = 'ICE Counterparty' AND value_id > 0

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000257)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000257, 'ICE Counterparty', 'ICE Counterparty', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000257 - ICE Counterparty.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000257 - ICE Counterparty already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000257)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000257, 'ICE Counterparty', 't', 'VARCHAR(100)', 'y', NULL, 'h', 100, -10000257
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000236)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000236, 'Counterparty ID', 'Counterparty ID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000236 - Counterparty ID.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000236 - Counterparty ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000236)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000236, 'Counterparty ID', 'd', 'VARCHAR(100)', 'y', 'EXEC spa_source_counterparty_maintain @flag=''q''', 'h', 100, -10000236
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'ICE Counterparty Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('ICE Counterparty Mapping', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ICE Counterparty Mapping'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ICE Counterparty Mapping'
END

DECLARE @mapping_table_id INT
	  , @ice_counterparty INT
	  , @counterparty_id INT
	  , @counterparty_id_value INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ICE Counterparty Mapping'

SELECT @ice_counterparty = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000257

SELECT @counterparty_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000236

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'ICE Counterparty', @ice_counterparty, 'Counterparty ID', @counterparty_id, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'ICE Counterparty'
	  , clm1_udf_id = @ice_counterparty
	  , clm2_label = 'Counterparty ID'
	  , clm2_udf_id = @counterparty_id  
	  , unique_columns_index = '1'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ICE Counterparty Mapping'
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'AMX' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'AMERENER'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'AMX', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'BCGH' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'LANDMARK'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'BCGH', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'CENBR' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'CHOINATG'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'CENBR', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'CNX' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'CANAPOWE'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'CNX', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'EMFLB' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'EVOLFUTU'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'EMFLB', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'EQUUS' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'EQUUSEGP'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'EQUUS', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'ICAPE' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'APBENERG'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'ICAPE', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'PREBR' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'TULLPREB'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'PREBR', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'pvmfut' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'PVMFUTUR'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'pvmfut', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'SFLBR' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'SPECENER'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'SFLBR', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'TRIBRK' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'TRIDBROK'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'TRIBRK', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Citigroup Global Markets Inc' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'CITIGL'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Citigroup Global Markets Inc', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'ICE NGX Canada Inc.' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'NATUEX'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'ICE NGX Canada Inc.', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'SG Americas Securities, LLC (FIU)' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'NEWEDG'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'SG Americas Securities, LLC (FIU)', @counterparty_id_value
END