DELETE static_data_value WHERE [type_id] = 5500 AND code = 'Prisma Trader' AND value_id > 0

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000371)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000371, 'Prisma Trader', 'Prisma Trader', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000371 - Prisma Trader.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000371 - Prisma Trader already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000371)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000371, 'Prisma Trader', 't', 'VARCHAR(100)', 'y', NULL, 'h', 100, -10000371
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

IF NOT EXISTS(SELECT * FROM user_defined_fields_template WHERE field_id = -10000253)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000253, 'Trader ID', 'd', 'VARCHAR(100)', 'y', NULL, 'h', 100, -10000253
END        

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Prisma Trader Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Prisma Trader Mapping', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'Prisma Trader Mapping'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Prisma Trader Mapping'
END

DECLARE @mapping_table_id INT
	  , @prisma_trader INT
	  , @trader_id INT
	  , @trader_id_value INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Prisma Trader Mapping'

SELECT @prisma_trader = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000371

SELECT @trader_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000253

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'Prisma Trader', @prisma_trader, 'Trader ID', @trader_id, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Prisma Trader'
	  , clm1_udf_id = @prisma_trader
	  , clm2_label = 'Prisma ID'
	  , clm2_udf_id = @trader_id
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Prisma Trader Mapping'
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'stefan.erdmann@enercity-trade.de' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @trader_id_value = NULL

	SELECT @trader_id_value = source_trader_id
	FROM source_traders
	WHERE trader_id = 'Stefan Erdmann'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'stefan.erdmann@enercity-trade.de', @trader_id_value
END
