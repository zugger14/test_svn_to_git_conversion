DECLARE @mapping_table_id INT

SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Framework Contract'

-- Delete from generic_mapping_values, generic_mapping_definition and generic_mapping_header

IF EXISTS (SELECT 1 FROM generic_mapping_values WHERE mapping_table_id = @mapping_table_id)
BEGIN
	DELETE FROM generic_mapping_values WHERE mapping_table_id = @mapping_table_id
END
ELSE
BEGIN
	PRINT 'Mapping table does not exists.'
END

IF EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	DELETE FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id
END
ELSE
BEGIN
	PRINT 'Mapping table does not exists.'
END

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_table_id = @mapping_table_id)
BEGIN
	DELETE FROM generic_mapping_header WHERE mapping_table_id = @mapping_table_id
END
ELSE
BEGIN
	PRINT 'Mapping table does not exists.'
END

/*  Step 1 - Defining static data for each UDF  */

IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

--------------------------------Counterparty-----------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Counterparty')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Counterparty', 'Counterparty'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Counterparty'
END
 
---------------------------------------------------------------Contract--------------------------
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Contract')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Contract', 'Contract'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Contract'
END

---------------------------------------------------------------Effective Date--------------------------

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Effective Date')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Effective Date', 'Effective Date'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Effective Date'
END

--------------------------------Tenor------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tenor')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Tenor', 'Tenor'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tenor'
END

--------------------------------Fees------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Fees')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Fees', 'Fees'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Fees'
END

--------------------------------Currency------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Currency')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Currency', 'Currency'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Currency'
END

--------------------------------Order Deadline(hh:mm)------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Order Deadline(hh:mm)')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Order Deadline(hh:mm)', 'Order Deadline(hh:mm)'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Order Deadline(hh:mm)'
END

--------------------------------Per Unit------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Per Unit')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Per Unit', 'Per Unit'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Per Unit'
END

--------------------------------Contract Volume------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Contract Volume')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Contract Volume', 'Contract Volume'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Contract Volume'
END

-----------------------------------Buy Sell----------------------------------------------
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Buy Sell')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Buy Sell', 'Buy Sell'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Buy Sell'
END

-----------------------------------UOM----------------------------------------------
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'UOM')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'UOM', 'UOM'
END
ELSE
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'UOM'
END


/* Step 2 - Defining UDF */

---------------------------------------------------------------Counterparty--------------------------
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Counterparty')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Counterparty', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc WHERE sc.is_active = ''y'''
			, 'h',	NULL, 150, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Counterparty'	
END
ELSE 
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc WHERE sc.is_active = ''y'''
	WHERE Field_label = 'Counterparty'
END
---------------------------------------------------------------Contract--------------------------
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Contract')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Contract', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT cg.contract_id, cg.contract_name FROM contract_group cg'
			, 'h',	NULL, 150, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Contract'	
END
ELSE 
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT cg.contract_id, cg.contract_name FROM contract_group cg'
	WHERE Field_label = 'Contract'
END

---------------------------------------------------------------Effective Date--------------------------
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Effective Date')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Effective Date', 'a', 'DATETIME', 'n'
			, NULL
			, 'h',	NULL, 150, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Effective Date'	
END

--------------------------------Tenor------------------------------------------------
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Tenor')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Tenor', 't', 'INT', 'n'
			, NULL
			, 'h',	NULL, 150, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Tenor'	
END

--------------------------------Fees------------------------------------------------
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Fees')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Fees', 't', 'FLOAT', 'n'
			, NULL
			, 'h',	NULL, 150, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Fees'	
END

--------------------------------Currency------------------------------------------------
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Currency')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Currency', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT source_currency_id AS id,currency_name AS VALUE FROM source_currency sc'
			, 'h',	NULL, 150, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Currency'	
END
ELSE 
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT source_currency_id AS id,currency_name AS VALUE FROM source_currency sc'
	WHERE Field_label = 'Currency'
END

--------------------------------Order Deadline(hh:mm)------------------------------------------------
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Order Deadline(hh:mm)')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Order Deadline(hh:mm)', 't', 'VARCHAR(150)', 'n'
			, NULL
			, 'h',	NULL, 150, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Order Deadline(hh:mm)'	
END

--------------------------------Per Unit------------------------------------------------
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Per Unit')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Per Unit', 'd', 'CHAR(1)', 'n'
			, 'SELECT * FROM (SELECT ''l'' AS value , ''Lump Sum'' AS label UNION SELECT ''p'', ''Per Position UOM'' UNION SELECT ''a'',  ''Per Annual'') a'
			, 'h',	NULL, 150, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Per Unit'	
END
ELSE 
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT * FROM (SELECT ''l'' AS value , ''Lump Sum'' AS label UNION SELECT ''p'', ''Per Position UOM'' UNION SELECT ''a'',  ''Per Annual'') a'
	WHERE Field_label = 'Per Unit'
END

--------------------------------Contract Volume------------------------------------------------
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Contract Volume')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Contract Volume', 't', 'VARCHAR()150', 'n'
			, NULL
			, 'h',	NULL, 150, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Contract Volume'	
END

---------------------------------Buy Sell------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Buy Sell')
BEGIN
	INSERT INTO user_defined_fields_template
      (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id, 'Buy Sell', 'd', 'VARCHAR(150)', 'n'
			,'SELECT 1 AS value_id, ''Buy'' AS name UNION SELECT 2 AS value_id, ''Sell'' AS name'
			, 'h', NULL, 30, iose.value_id
    FROM   #insert_output_sdv_external iose WHERE  iose.[type_name] = 'Buy Sell'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT ''b'' AS value_id, ''Buy'' AS [name] UNION SELECT ''s'' AS value_id, ''Sell'' AS [name]'
    WHERE  Field_label = 'Buy Sell'
END

---------------------------------UOM-----------------------------------------------------------
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE  Field_label = 'UOM')
BEGIN
    INSERT INTO user_defined_fields_template
      (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, SEQUENCE, field_size, field_id)
    SELECT iose.value_id, 'UOM', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT source_uom_id, uom_name FROM source_uom'
			, 'h', NULL, 30, iose.value_id
    FROM #insert_output_sdv_external iose WHERE  iose.[type_name] = 'UOM'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string ='SELECT source_uom_id, uom_name FROM source_uom' 
    WHERE Field_label = 'UOM'
END

/* Step 3 - Inserting the Mapping Table name in generic_mapping_header table */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Framework Contract')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Framework Contract',
	11
	)
END

/* Step 4 - Inserting the user defined field and its ID into generic_mapping_definition table*/

DECLARE @counterparty INT 
DECLARE @contract INT 
DECLARE @effective_date INT
DECLARE @tenor INT
DECLARE @fees INT	
DECLARE @currency INT	
DECLARE @order_deadline	INT
DECLARE @per_unit INT
DECLARE @contract_volume INT
DECLARE @buy_sell INT
DECLARE @uom INT

SELECT @counterparty = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @contract = udft.udf_template_id FROM user_defined_fields_template udft WHERE udft.Field_label = 'Contract'
SELECT @effective_date = udft.udf_template_id FROM user_defined_fields_template udft WHERE udft.Field_label = 'Effective Date'
SELECT @tenor = udft.udf_template_id FROM user_defined_fields_template udft WHERE udft.Field_label = 'Tenor'
SELECT @fees = udft.udf_template_id FROM user_defined_fields_template udft WHERE udft.Field_label = 'Fees'
SELECT @currency = udft.udf_template_id FROM user_defined_fields_template udft WHERE udft.Field_label = 'Currency'
SELECT @order_deadline = udft.udf_template_id FROM user_defined_fields_template udft WHERE udft.Field_label = 'Order Deadline(hh:mm)'
SELECT @per_unit = udft.udf_template_id FROM user_defined_fields_template udft WHERE udft.Field_label = 'Per Unit'
SELECT @contract_volume = udft.udf_template_id FROM user_defined_fields_template udft WHERE udft.Field_label = 'Contract Volume'
SELECT @buy_sell = udft.udf_template_id FROM user_defined_fields_template udft WHERE udft.Field_label = 'Buy Sell'
SELECT @uom = udft.udf_template_id FROM user_defined_fields_template udft WHERE udft.Field_label = 'UOM'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
			WHERE gmh.mapping_name = 'Framework Contract')
BEGIN
	UPDATE gmd
	SET mapping_table_id = gmh.mapping_table_id,
		clm1_label = 'Counterparty',
		clm1_udf_id = @counterparty,
		clm2_label = 'Contract',
		clm2_udf_id = @contract,
		clm3_label = 'Effective Date',
		clm3_udf_id = @effective_date,
		clm4_label = 'Tenor',
		clm4_udf_id = @tenor,
		clm5_label = 'Fees',
		clm5_udf_id = @fees,
		clm6_label = 'Currency',
		clm6_udf_id = @currency,
		clm7_label = 'Order Deadline(hh:mm)',
		clm7_udf_id = @order_deadline,
		clm8_label = 'Per Unit',
		clm8_udf_id = @per_unit,
		clm9_label = 'Contract Volume',
		clm9_udf_id = @contract_volume,
		clm10_label = 'Buy Sell',
		clm10_udf_id = @buy_sell,
		clm11_label = 'UOM',
		clm11_udf_id = @uom
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Framework Contract'

END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition
	(
		mapping_table_id,
		clm1_label,
		clm1_udf_id,
		clm2_label,
		clm2_udf_id,
		clm3_label ,
		clm3_udf_id,
		clm4_label ,
		clm4_udf_id,
		clm5_label ,
		clm5_udf_id,
		clm6_label ,
		clm6_udf_id,
		clm7_label ,
		clm7_udf_id,
		clm8_label ,
		clm8_udf_id,
		clm9_label ,
		clm9_udf_id,
		clm10_label,
		clm10_udf_id,
		clm11_label,
		clm11_udf_id,
		unique_columns_index
	)
	SELECT  mapping_table_id,
			 'Counterparty',
			 @counterparty,
			 'Contract',
			 @contract,
			 'Effective Date',
			 @effective_date,
			 'Tenor',
			 @tenor,
			 'Fees',
			 @fees,
			 'Currency',
			 @currency,
			 'Order Deadline(hh:mm)',
			 @order_deadline,
			 'Per Unit',
			 @per_unit,
			 'Contract Volume',
			 @contract_volume,
			 'Buy Sell',
			 @buy_sell,
			 'UOM',
			 @uom,
			'1,2,3'			
	FROM generic_mapping_header 
	WHERE mapping_name = 'Framework Contract' 
END