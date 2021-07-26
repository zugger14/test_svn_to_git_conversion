--DELETE static_data_value WHERE [type_id] = 5500 AND code = 'Prisma Counterparty' AND value_id > 0

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE Code = 'Source counterparty')
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, 50000193, 'Source counterparty', 'Source Counterparty', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 50000193 - Source Counterparty.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000370 - Source Counterparty already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = 50000193)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT 50000193, 'Source Counterparty', 't', 'VARCHAR(100)', 'y', NULL, 'h', 100, 50000193
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 300010)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, 300010, 'TRM Counterparty', 'TRM Counterparty', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 300010 - TRM Counterparty.'
END
ELSE
BEGIN
    PRINT 'Static data value 300010 - Counterparty ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000236)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT 300010, 'TRM Counterparty', 'd', 'VARCHAR(100)', 'y', 'EXEC spa_source_counterparty_maintain @flag = ''c'',  @not_int_ext_flag = ''b''', 'h', 100, 300010
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Prisma Counterparty Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Prisma Counterparty Mapping', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'Prisma Counterparty Mapping'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Prisma Counterparty Mapping'
END

DECLARE @mapping_table_id INT
	  , @Prisma_counterparty INT
	  , @counterparty_id INT
	  , @counterparty_id_value INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Prisma Counterparty Mapping'

SELECT @Prisma_counterparty = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = 50000193

SELECT @counterparty_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = 300010

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'Prisma Counterparty', @Prisma_counterparty, 'TRM Counterparty', @counterparty_id, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Source Counterparty'
	  , clm1_udf_id = @Prisma_counterparty
	  , clm2_label = 'TRM Counterparty'
	  , clm2_udf_id = @counterparty_id  
	  , unique_columns_index = '1'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Prisma Counterparty Mapping'
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Nowega GmbH' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'NOWEGA'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Nowega GmbH', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Open Grid Europe GmbH' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'OGE'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Open Grid Europe GmbH', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Open Grid Europe GmbH' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'GTS'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Open Grid Europe GmbH', @counterparty_id_value
END


IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'NetConnect Germany' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'NCG'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'NetConnect Germany', @counterparty_id_value
END


IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Gasunie Deutschland Transport Services GmbH' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'GUD'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Gasunie Deutschland Transport Services GmbH', @counterparty_id_value
END



IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Thyssengas GmbH' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'THY'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Thyssengas GmbH', @counterparty_id_value
END

IF NOT EXISTS (SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'Nowega GmbH' AND mapping_table_id = @mapping_table_id)
BEGIN
	SET @counterparty_id_value = NULL

	SELECT @counterparty_id_value = source_counterparty_id
	FROM source_counterparty
	WHERE counterparty_id = 'NOW'

	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value)
	SELECT @mapping_table_id, 'Nowega GmbH', @counterparty_id_value
END


--Delete from generic_mapping_values where mapping_table_id = 181