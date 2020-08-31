IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
GO

CREATE TABLE #insert_output_sdv_external(
	value_id INT,
	[type_id] INT,
	[type_name] VARCHAR(500)
)

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Counterparty')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '307221', '5500', 'Counterparty', 'Counterparty'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Contract'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Contract')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '307222', '5500', 'Contract', 'Contract'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Contract'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Delivery Point')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '-5722', '5500', 'Delivery Point', 'Delivery Point'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Delivery Point'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Charge Type')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '-5723', '5500', 'Charge Type', 'Charge Type'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Charge Type'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Remit Reporting')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '-5724', '5500', 'Remit Reporting', 'Remit Reporting'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Remit Reporting'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Formula Row')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '-5725', '5500', 'Formula Row', 'Formula Row'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Formula Row'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Commodity')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '-5500', '5500', 'Commodity', 'Commodity'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Commodity'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Link Transaction')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '-5726', '5500', 'Link Transaction', 'Link Transaction'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Link Transaction'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Invoice Date')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '-5727', '5500', 'Invoice Date', 'Invoice Date'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Invoice Date'	AND TYPE_ID = 5500
END
/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (SELECT * FROM   user_defined_fields_template WHERE  Field_label = 'Counterparty')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Counterparty',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_counterparty_id id, counterparty_name value FROM source_counterparty WHERE is_active = ''y'' ORDER BY 2',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Counterparty'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'SELECT source_counterparty_id id, counterparty_name value FROM source_counterparty WHERE is_active = ''y'' ORDER BY 2'
    WHERE  Field_label = 'Counterparty'
END


IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Contract')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Contract',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT contract_id id, contract_name value  FROM contract_group value ORDER BY 2',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Contract'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'SELECT contract_id id, contract_name value  FROM contract_group value ORDER BY 2'
    WHERE  Field_label = 'Contract'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Delivery Point')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Delivery Point',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Delivery Point'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Delivery Point'
END


IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Charge Type')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Charge Type',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id id, code value FROM static_data_value sdv WHERE sdv.[type_id] = 10019 ORDER BY 2',
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Charge Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = 'SELECT value_id id, code value FROM static_data_value sdv WHERE sdv.[type_id] = 10019 ORDER BY 2'
    WHERE  Field_label = 'Charge Type'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Remit Reporting')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Remit Reporting',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT 1 id, ''Price'' value UNION ALL select 2, ''Contract Quantity'' UNION ALL SELECT 3,  ''Notional Amount''',
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Remit Reporting'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = 'SELECT 1 id, ''Price'' value UNION ALL select 2, ''Contract Quantity'' UNION ALL SELECT 3,  ''Notional Amount'''
    WHERE  Field_label = 'Remit Reporting'
END


IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Formula Row')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Formula Row',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT n id, n value FROM seq  WHERE n <=25',
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Formula Row'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = 'SELECT n id, n value FROM seq  WHERE n <=25'
    WHERE  Field_label = 'Formula Row'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Commodity')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Commodity',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT sc.source_commodity_id id, sc.commodity_id value FROM source_commodity sc',
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = 'SELECT sc.source_commodity_id id, sc.commodity_id value FROM source_commodity sc'
    WHERE  Field_label = 'Commodity'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Link Transaction')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Link Transaction',
           't',
           'VARCHAR(255)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Link Transaction'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Link Transaction'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Invoice Date')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Invoice Date',
           'a',
           'DATETIME',
           'n',
           NULL,
           'h',
           NULL,
           150,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Invoice Date'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 150,
		sql_string = NULL
    WHERE  Field_label = 'Invoice Date'
END

DECLARE @counterparty_id INT
DECLARE @contract_id INT
DECLARE @delivery_point INT
DECLARE @charge_type INT
DECLARE @remit_reporting INT
DECLARE @formula_row INT
DECLARE @commodity INT
DECLARE @link_transaction INT
DECLARE @invoice_date INT

SELECT @counterparty_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @contract_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @delivery_point = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Delivery Point'
SELECT @charge_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Charge Type'
SELECT @remit_reporting = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Remit Reporting'
SELECT @formula_row = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Formula Row'
SELECT @commodity = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Commodity'
SELECT @link_transaction = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Link Transaction'
SELECT @invoice_date = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Invoice Date'
/* end of part 2 */
/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Remit Execution')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Remit Execution',
		total_columns_used = 9,
		system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Remit Execution'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Remit Execution',
	9
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Remit Execution')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Counterparty',
		clm1_udf_id = @counterparty_id,
		clm2_label = 'Contract',
		clm2_udf_id = @contract_id,
		clm3_label = 'Commodity',
		clm3_udf_id = @commodity,
		clm4_label = 'Delivery Point',
		clm4_udf_id = @delivery_point,
		clm5_label = 'Charge Type',
		clm5_udf_id = @charge_type,
		clm6_label = 'Remit Reporting',
		clm6_udf_id = @remit_reporting,
		clm7_label = 'Formula Row',
		clm7_udf_id = @formula_row,
		clm8_label = 'Link Transaction',
		clm8_udf_id = @link_transaction,
		clm9_label = 'Invoice Date',
		clm9_udf_id = @invoice_date,
		required_columns_index = '1,2,3,4,5,6,7,8,9'
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Remit Execution'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id,
		clm5_label, clm5_udf_id,
		clm6_label, clm6_udf_id,
		clm7_label, clm7_udf_id,
		clm8_label, clm8_udf_id,
		clm9_label, clm9_udf_id,
		required_columns_index
	)
	SELECT 
		mapping_table_id,
		'Counterparty', @counterparty_id,
		'Contract', @contract_id,
		'Commodity', @commodity,
		'Delivery Point', @delivery_point,
		'Charge Type', @charge_type,
		'Remit Reporting', @remit_reporting,
		'Formula Row', @formula_row,
		'Link Transaction', @formula_row,
		'Invoice Date', @formula_row,
		'1,2,3,4,5,6,7,8,9'
	FROM generic_mapping_header 
	WHERE mapping_name = 'Remit Execution'
END

