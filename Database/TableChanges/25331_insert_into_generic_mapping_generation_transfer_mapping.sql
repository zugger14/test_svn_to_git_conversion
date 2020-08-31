DECLARE @mapping_table_id INT

IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_header
	WHERE mapping_name = 'Generation Transfer Mapping'
)
BEGIN
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used, system_defined, function_ids)
	SELECT 'Generation Transfer Mapping', 18, 0, NULL
END

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Generation Transfer Mapping'

IF OBJECT_ID('tempdb..#temp_generic_mapping_definition') IS NOT NULL DROP TABLE #temp_generic_mapping_definition

SELECT *
INTO #temp_generic_mapping_definition
FROM generic_mapping_definition
WHERE 1=2

DELETE FROM generic_mapping_definition
WHERE mapping_table_id = @mapping_table_id

-- Effective Date
IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm1_label = 'Effective Date'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm1_label, clm1_udf_id)
	SELECT @mapping_table_id, field_label, udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Effective Date'
END

-- Sub Book
IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm2_label = 'Sub Book'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm2_label, clm2_udf_id)
	SELECT @mapping_table_id, 'Sub Book', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Sub Book'
END

-- Offset Sub Book
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000299)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000299, 'Offset Sub Book', 'Offset Sub Book', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000299 - Offset Sub Book.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000299 - Offset Sub Book already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (
    SELECT 1
    FROM user_defined_fields_template
    WHERE field_label = 'Offset Sub Book'
		AND field_id = -10000299
)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT sdv.value_id,
           'Offset Sub Book',
           'd',
           'NVARCHAR(250)',
           'n',
           'SELECT ssbm.book_deal_type_map_id id, ssbm.logical_name VALUE FROM source_system_book_map ssbm ORDER BY 2',
           'h',
           NULL,
           NULL,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.[code] = 'Offset Sub Book'
END

IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm3_label = 'Offset Sub Book'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm3_label, clm3_udf_id)
	SELECT @mapping_table_id, 'Offset Sub Book', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Offset Sub Book'
END

-- Transfer Book
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000300)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000300, 'Transfer Sub Book', 'Transfer Sub Book', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000300 - Transfer Sub Book.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000300 - Transfer Sub Book already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (
    SELECT 1
    FROM user_defined_fields_template
    WHERE field_label = 'Transfer Sub Book'
		AND field_id = -10000300
)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT sdv.value_id,
           'Transfer Sub Book',
           'd',
           'NVARCHAR(250)',
           'n',
           'SELECT ssbm.book_deal_type_map_id id, ssbm.logical_name VALUE FROM source_system_book_map ssbm ORDER BY 2',
           'h',
           NULL,
           NULL,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.[code] = 'Transfer Sub Book'
END

IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm4_label = 'Transfer Sub Book'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm4_label, clm4_udf_id)
	SELECT @mapping_table_id, 'Transfer Sub Book', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Transfer Sub Book'
END

-- Counterparty
IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm5_label = 'Counterparty'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm5_label, clm5_udf_id)
	SELECT @mapping_table_id, 'Counterparty', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Counterparty'
END

-- Offset Counterparty
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000301)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000301, 'Offset Counterparty', 'Offset Counterparty', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000301 - Offset Counterparty.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000301 - Offset Counterparty already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (
    SELECT 1
    FROM user_defined_fields_template
    WHERE field_label = 'Offset Counterparty'
)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT sdv.value_id,
		'Offset Counterparty',
		'd',
		'NVARCHAR(250)',
		'n',
		'SELECT source_counterparty_id id, counterparty_name value FROM source_counterparty WHERE is_active = ''y'' ORDER BY 2',
		'h',
		NULL,
		400,
		sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.[code] = 'Offset Counterparty'
END

IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm6_label = 'Offset Counterparty'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm6_label, clm6_udf_id)
	SELECT @mapping_table_id, 'Offset Counterparty', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Offset Counterparty'
END

-- Transfer Counterparty
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000302)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000302, 'Transfer Counterparty', 'Transfer Counterparty', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000302 - Transfer Counterparty.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000302 - Transfer Counterparty already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (
    SELECT 1
    FROM user_defined_fields_template
    WHERE field_label = 'Transfer Counterparty'
)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT sdv.value_id,
		'Transfer Counterparty',
		'd',
		'NVARCHAR(250)',
		'n',
		'SELECT source_counterparty_id id, counterparty_name value FROM source_counterparty WHERE is_active = ''y'' ORDER BY 2',
		'h',
		NULL,
		400,
		sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.[code] = 'Transfer Counterparty'
END

IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm7_label = 'Transfer Counterparty'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm7_label, clm7_udf_id)
	SELECT @mapping_table_id, 'Transfer Counterparty', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Transfer Counterparty'
END

-- Deal Type
IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm8_label = 'Deal Type'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm8_label, clm8_udf_id)
	SELECT @mapping_table_id, 'Deal Type', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Deal Type'
END

-- Deal Sub Type
IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm9_label = 'Deal Sub-Type'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm9_label, clm9_udf_id)
	SELECT @mapping_table_id, 'Deal Sub-Type', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Deal Sub-Type'
END

-- Contract
IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm10_label = 'Contract'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm10_label, clm10_udf_id)
	SELECT @mapping_table_id, 'Contract', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Contract'
END

-- Buy Sell
IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm11_label = 'Buy Sell'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm11_label, clm11_udf_id)
	SELECT @mapping_table_id, 'Buy Sell', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Buy Sell'
END

-- Template
IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm12_label = 'Template'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm12_label, clm12_udf_id)
	SELECT @mapping_table_id, 'Template', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Template'
END

-- From Deal
IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm13_label = 'From Deal'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm13_label, clm13_udf_id)
	SELECT @mapping_table_id, 'From Deal', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'From Deal'
END

-- Offset Deal
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000303)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000303, 'Offset Deal', 'Offset Deal', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000303 - Offset Deal.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000303 - Offset Deal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (
    SELECT 1
    FROM user_defined_fields_template
    WHERE field_label = 'Offset Deal'
)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT sdv.value_id,
           'Offset Deal',
           't',
           'NVARCHAR(250)',
           'n',
           NULL,
           'h',
           NULL,
           NULL,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.[code] = 'Offset Deal'
END

IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm14_label = 'Offset Deal'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm14_label, clm14_udf_id)
	SELECT @mapping_table_id, 'Offset Deal', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Offset Deal'
END

-- Transfer Deal
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000304)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000304, 'Transfer Deal', 'Transfer Deal', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000304 - Transfer Deal.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000304 - Transfer Deal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (
    SELECT 1
    FROM user_defined_fields_template
    WHERE field_label = 'Transfer Deal'
)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT sdv.value_id,
           'Transfer Deal',
           't',
           'NVARCHAR(250)',
           'n',
           NULL,
           'h',
           NULL,
           NULL,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.[code] = 'Transfer Deal'
END

IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm15_label = 'Transfer Deal'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm15_label, clm15_udf_id)
	SELECT @mapping_table_id, 'Transfer Deal', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Transfer Deal'
END

-- Cumulative/Delta
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000305)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000305, 'Cumulative/Delta', 'Cumulative/Delta', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000305 - Cumulative/Delta.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000305 - Cumulative/Delta already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (
    SELECT 1
    FROM user_defined_fields_template
    WHERE field_label = 'Cumulative/Delta'
)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT sdv.value_id,
           'Cumulative/Delta',
           'd',
           'NVARCHAR(250)',
           'n',
           'SELECT ''c'' [id], ''Cumulative'' [value] UNION SELECT ''d'', ''Delta''',
           'h',
           NULL,
           NULL,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.[code] = 'Cumulative/Delta'
END

IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm16_label = 'Cumulative/Delta'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm16_label, clm16_udf_id)
	SELECT @mapping_table_id, 'Cumulative/Delta', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Cumulative/Delta'
END

-- PFC Curve
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000306)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000306, 'PFC Curve', 'PFC Curve', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000306 - PFC Curve.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000306 - PFC Curve already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (
    SELECT 1
    FROM user_defined_fields_template
    WHERE field_label = 'PFC Curve'
)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT sdv.value_id,
           'PFC Curve',
           'd',
           'NVARCHAR(250)',
           'n',
           'EXEC spa_source_price_curve_def_maintain @flag = ''l'', @is_active = ''y''',
           'h',
           NULL,
           NULL,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.[code] = 'PFC Curve'
END

IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm17_label = 'PFC Curve'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm17_label, clm17_udf_id)
	SELECT @mapping_table_id, 'PFC Curve', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'PFC Curve'
END

-- Aggregation Level
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000307)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000307, 'Aggregation Level', 'Aggregation Level', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000307 - Aggregation Level.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000307 - Aggregation Level already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (
    SELECT 1
    FROM user_defined_fields_template
    WHERE field_label = 'Aggregation Level'
)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT sdv.value_id,
           'Aggregation Level',
           'd',
           'NVARCHAR(250)',
           'n',
           'EXEC spa_staticdatavalues @flag = ''h'', @type_id = 978',
           'h',
           NULL,
           NULL,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.[code] = 'Aggregation Level'
END

IF NOT EXISTS (
	SELECT 1
	FROM generic_mapping_definition
	WHERE mapping_table_id = @mapping_table_id
		AND clm18_label = 'Aggregation Level'
)
BEGIN
	INSERT INTO #temp_generic_mapping_definition(mapping_table_id, clm18_label, clm18_udf_id)
	SELECT @mapping_table_id, 'Aggregation Level', udf_template_id
	FROM user_defined_fields_template udft
	INNER JOIN static_data_value sdv ON sdv.value_id = udft.field_id
		AND sdv.[type_id] = 5500
	WHERE sdv.code = 'Aggregation Level'
END

INSERT INTO generic_mapping_definition (
	mapping_table_id,clm1_label,clm1_udf_id,clm2_label,clm2_udf_id,clm3_label,clm3_udf_id,clm4_label,clm4_udf_id,
	clm5_label,clm5_udf_id,clm6_label,clm6_udf_id,clm7_label,clm7_udf_id,clm8_label,clm8_udf_id,clm9_label,
	clm9_udf_id,clm10_label,clm10_udf_id,clm11_label,clm11_udf_id,clm12_label,clm12_udf_id,clm13_label,
	clm13_udf_id,clm14_label,clm14_udf_id,clm15_label,clm15_udf_id,clm16_label,clm16_udf_id,
	clm17_label,clm17_udf_id,clm18_label,clm18_udf_id
)
SELECT mapping_table_id,
	MAX(clm1_label) clm1_label,
	MAX(clm1_udf_id) clm1_udf_id,
	MAX(clm2_label) clm2_label,
	MAX(clm2_udf_id) clm2_udf_id,
	MAX(clm3_label) clm3_label,
	MAX(clm3_udf_id) clm3_udf_id,
	MAX(clm4_label) clm4_label,
	MAX(clm4_udf_id) clm4_udf_id,
	MAX(clm5_label) clm5_label,
	MAX(clm5_udf_id) clm5_udf_id,
	MAX(clm6_label) clm6_label,
	MAX(clm6_udf_id) clm6_udf_id,
	MAX(clm7_label) clm7_label,
	MAX(clm7_udf_id) clm7_udf_id,
	MAX(clm8_label) clm8_label,
	MAX(clm8_udf_id) clm8_udf_id,
	MAX(clm9_label) clm9_label,
	MAX(clm9_udf_id) clm9_udf_id,
	MAX(clm10_label) clm10_label,
	MAX(clm10_udf_id) clm10_udf_id,
	MAX(clm11_label) clm11_label,
	MAX(clm11_udf_id) clm11_udf_id,
	MAX(clm12_label) clm12_label,
	MAX(clm12_udf_id) clm12_udf_id,
	MAX(clm13_label) clm13_label,
	MAX(clm13_udf_id) clm13_udf_id,
	MAX(clm14_label) clm14_label,
	MAX(clm14_udf_id) clm14_udf_id,
	MAX(clm15_label) clm15_label,
	MAX(clm15_udf_id) clm15_udf_id,
	MAX(clm16_label) clm16_label,
	MAX(clm16_udf_id) clm16_udf_id,
	MAX(clm17_label) clm17_label,
	MAX(clm17_udf_id) clm17_udf_id,
	MAX(clm18_label) clm18_label,
	MAX(clm18_udf_id) clm18_udf_id
FROM #temp_generic_mapping_definition
GROUP BY mapping_table_id

GO