-- Delete duplicate external value id as value id should be negative if used in udf
DECLARE @wrong_value_id INT

SELECT @wrong_value_id = value_id
FROM static_data_value
WHERE [type_id] = 5500
	AND [code] = 'ICE Trader'
	AND value_id > 0

DELETE user_defined_fields_template WHERE field_name = @wrong_value_id
DELETE static_data_value WHERE [type_id] = 5500 AND [code] = 'ICE Trader' AND value_id = @wrong_value_id

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000252)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000252, 'ICE Trader', 'ICE Trader', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000252 - ICE Trader.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000252 - ICE Trader already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000252)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000252, 'ICE Trader', 't', 'VARCHAR(100)', 'y', NULL, 'h', 100, -10000252
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000253)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000253, 'Trader ID', 'Trader ID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000253 - Trader ID.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000253 - Trader ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000253)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000253, 'Trader ID', 'd', 'VARCHAR(100)', 'y', NULL, 'h', 100, -10000253
END        

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'ICE Trader Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('ICE Trader Mapping', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ICE Trader Mapping'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ICE Trader Mapping'
END

DECLARE @mapping_table_id INT
	  , @ice_trader INT
	  , @trader_id INT
	  , @trader_id_value INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ICE Trader Mapping'

SELECT @ice_trader = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000252

SELECT @trader_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000253

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'ICE Trader', @ice_trader, 'Trader ID', @trader_id, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'ICE Trader'
	  , clm1_udf_id = @ice_trader
	  , clm2_label = 'Trader ID'
	  , clm2_udf_id = @trader_id
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ICE Trader Mapping'
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'pcooke89' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @trader_id_value = NULL

	SELECT @trader_id_value = source_trader_id
	FROM source_traders
	WHERE trader_id = 'PIERCOOK'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'pcooke89', @trader_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'amcdonald1' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @trader_id_value = NULL

	SELECT @trader_id_value = source_trader_id
	FROM source_traders
	WHERE trader_id = 'ANTHMCDO'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'amcdonald1', @trader_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'csener2' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @trader_id_value = NULL

	SELECT @trader_id_value = source_trader_id
	FROM source_traders
	WHERE trader_id = 'CANSENE'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'csener2', @trader_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'ftrottier' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @trader_id_value = NULL

	SELECT @trader_id_value = source_trader_id
	FROM source_traders
	WHERE trader_id = 'FRANTROT'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'ftrottier', @trader_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'golsen5' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @trader_id_value = NULL

	SELECT @trader_id_value = source_trader_id
	FROM source_traders
	WHERE trader_id = 'GREGOLSE'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'golsen5', @trader_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'pmadonna4' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @trader_id_value = NULL

	SELECT @trader_id_value = source_trader_id
	FROM source_traders
	WHERE trader_id = 'PHILMADO'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'pmadonna4', @trader_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'sishwanthlal' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @trader_id_value = NULL

	SELECT @trader_id_value = source_trader_id
	FROM source_traders
	WHERE trader_id = 'SHAUISHW'
	
	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'sishwanthlal', @trader_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'slaroche' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @trader_id_value = NULL

	SELECT @trader_id_value = source_trader_id
	FROM source_traders
	WHERE trader_id = 'SIMOLARO'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'slaroche', @trader_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'tdziedzic1' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @trader_id_value = NULL

	SELECT @trader_id_value = source_trader_id
	FROM source_traders
	WHERE trader_id = 'TOMADZIE'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'tdziedzic1', @trader_id_value
END