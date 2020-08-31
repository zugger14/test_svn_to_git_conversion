
/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Book')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Book', 'Book'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Book'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Commodity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Commodity', 'Commodity'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Commodity'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Location')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Location', 'Location'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Location'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Contract')
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Currency')
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'PNL')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'PNL', 'PNL'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'PNL'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Accounting Key')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Accounting Key', 'Accounting Key'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Accounting Key'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'GL Account')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'GL Account', 'GL Account'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'GL Account'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'VAT Code')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'VAT Code', 'VAT Code'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'VAT Code'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Cost Encoding')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Cost Encoding', 'Cost Encoding'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Cost Encoding'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'GL Account Balance For Estimate')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'GL Account Balance For Estimate', 'GL Account Balance For Estimate'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'GL Account Balance For Estimate'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'VAT Code Estimate')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'VAT Code Estimate', 'VAT Code Estimate'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'VAT Code Estimate'
END
/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Book'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Book',
           'd',
           'VARCHAR(150)',
           'n',
           'select source_book_id,source_system_book_id from source_book where source_system_book_type_value_id=50',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Book'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'select source_book_id,source_system_book_id from source_book where source_system_book_type_value_id=50'
    WHERE  Field_label = 'Book'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Commodity'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Commodity',
           'd',
           'VARCHAR(150)',
           'n',
           'select source_book_id,source_system_book_id from source_book where source_system_book_type_value_id=51',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'select source_book_id,source_system_book_id from source_book where source_system_book_type_value_id=51'
    WHERE  Field_label = 'Commodity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Location'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Location',
           'd',
           'VARCHAR(150)',
           'n',
           'select source_book_id,source_system_book_id from source_book where source_system_book_type_value_id=52',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Location'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'select source_book_id,source_system_book_id from source_book where source_system_book_type_value_id=52'
    WHERE  Field_label = 'Location'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Contract'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Contract',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT contract_id AS id,contract_name AS value FROM contract_group cg',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Contract'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT contract_id AS id,contract_name AS value FROM contract_group cg'
    WHERE  Field_label = 'Contract'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Currency'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Currency',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_currency_id AS id,currency_name AS VALUE FROM source_currency sc',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Currency'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_currency_id AS id,currency_name AS VALUE FROM source_currency sc'
    WHERE  Field_label = 'Currency'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Buy Sell'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Buy Sell',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''b'' AS id, ''Buy'' AS value UNION ALL SELECT ''s'', ''Sell''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Buy Sell'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 
           'SELECT ''b'' AS id, ''Buy'' AS value UNION ALL SELECT ''s'', ''Sell'''
    WHERE  Field_label = 'Buy Sell'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'PNL'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'PNL',
           't',
           'VARCHAR(MAX)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'PNL'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 
           ''
    WHERE  Field_label = 'PNL'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Accounting Key'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Accounting Key',
           'd',
           'VARCHAR(MAX)',
           'n',
           'SELECT ''40'' AS id, ''40'' AS value UNION ALL SELECT ''50'', ''50''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Accounting Key'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''40'' AS id, ''40'' AS value UNION ALL SELECT ''50'', ''50'''
    WHERE  Field_label = 'Accounting Key'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'GL Account'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'GL Account',
           'd',
           'VARCHAR(MAX)',
           'n',
           'SELECT gl_number_id, gl_account_number FROM gl_system_mapping',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'GL Account'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT gl_number_id, gl_account_number FROM gl_system_mapping'
    WHERE  Field_label = 'GL Account'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'VAT Code'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'VAT Code',
           'd',
           'VARCHAR(MAX)',
           'n',
           'SELECT sdv.value_id, sdv.[description] FROM static_data_value sdv WHERE sdv.[type_id]=10004',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'VAT Code'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sdv.value_id, sdv.[description] FROM static_data_value sdv WHERE sdv.[type_id]=10004'
    WHERE  Field_label = 'VAT Code'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Cost Encoding'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Cost Encoding',
           'd',
           'VARCHAR(MAX)',
           'n',
           'SELECT sdv.value_id, sdv.[description] FROM static_data_value sdv WHERE sdv.[type_id]=10005',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Cost Encoding'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sdv.value_id, sdv.[description] FROM static_data_value sdv WHERE sdv.[type_id]=10005'
    WHERE  Field_label = 'Cost Encoding'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'GL Account Balance For Estimate'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'GL Account Balance For Estimate',
           'd',
           'VARCHAR(MAX)',
           'n',
           'SELECT sdv.value_id, sdv.[description] FROM static_data_value sdv WHERE sdv.[type_id]=10006',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'GL Account Balance For Estimate'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sdv.value_id, sdv.[description] FROM static_data_value sdv WHERE sdv.[type_id]=10006'
    WHERE  Field_label = 'GL Account Balance For Estimate'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'VAT Code Estimate'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'VAT Code Estimate',
           'd',
           'VARCHAR(MAX)',
           'n',
           'SELECT sdv.value_id, sdv.[description] FROM static_data_value sdv WHERE sdv.[type_id]=10004',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'VAT Code Estimate'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 
           'SELECT sdv.value_id, sdv.[description] FROM static_data_value sdv WHERE sdv.[type_id]=10004'
    WHERE  Field_label = 'VAT Code Estimate'
END

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'SAP GL Code Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'SAP GL Code Mapping',
	13
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @book_id INT
DECLARE @commodity_id INT
DECLARE @location_id INT
DECLARE @contract_id INT
DECLARE @currency INT
DECLARE @country_id INT
DECLARE @buy_sell_flag INT
DECLARE @pnl INT
DECLARE @accounting_key INT
DECLARE @gl_account INT
DECLARE @vat_code INT
DECLARE @cost_encoding INT
DECLARE @gl_account_balance_for_estimate INT
DECLARE @vat_code_estimate INT

SELECT @book_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Book'
SELECT @commodity_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Commodity'
SELECT @location_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Location'  
SELECT @contract_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'  
SELECT @currency = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Currency'  
SELECT @buy_sell_flag = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Buy Sell'  
SELECT @pnl = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'PNL'  
SELECT @accounting_key = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Accounting Key'  
SELECT @gl_account = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'GL Account'  
SELECT @vat_code = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'VAT Code'  
SELECT @cost_encoding = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Cost Encoding'  
SELECT @gl_account_balance_for_estimate = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'GL Account Balance For Estimate'  
SELECT @vat_code_estimate = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'VAT Code Estimate'


IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'SAP GL Code Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Book',
		clm1_udf_id = @book_id,
		clm2_label = 'Commodity',
		clm2_udf_id = @commodity_id,
		clm3_label = 'Location',
		clm3_udf_id = @location_id,
		clm4_label = 'Contract',
		clm4_udf_id = @contract_id,
		clm5_label = 'Currency',
		clm5_udf_id = @currency,
		clm6_label = 'Buy Sell',
		clm6_udf_id = @buy_sell_flag,
		clm7_label = 'PNL',
		clm7_udf_id = @pnl,
		clm8_label = 'Accounting Key',
		clm8_udf_id = @accounting_key,
		clm9_label = 'GL Account',
		clm9_udf_id = @gl_account,
		clm10_label = 'VAT Code',
		clm10_udf_id = @vat_code,
		clm11_label = 'Cost Encoding',
		clm11_udf_id = @cost_encoding,
		clm12_label = 'GL Account Balance For Estimate',
		clm12_udf_id = @gl_account_balance_for_estimate,
		clm13_label = 'VAT Code Estimate',
		clm13_udf_id = @vat_code_estimate
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'SAP GL Code Mapping'
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
		clm10_label, clm10_udf_id,
		clm11_label, clm11_udf_id,
		clm12_label, clm12_udf_id,
		clm13_label, clm13_udf_id
	)
	SELECT 
		mapping_table_id,
		'Book', @book_id,
		'Commodity', @commodity_id,
		'Location', @location_id,
		'Contract', @contract_id,
		'Currency', @currency,
		'Buy Sell', @buy_sell_flag,
		'PNL', @pnl,
		'Accounting Key',@accounting_key,
		'GL Account', @gl_account,
		'VAT Code',@vat_code,
		'Cost Encoding', @cost_encoding,
		'GL Account Balance For Estimate', @gl_account_balance_for_estimate,
		'VAT Code Estimate', @vat_code_estimate
		
	FROM generic_mapping_header 
	WHERE mapping_name = 'SAP GL Code Mapping'
END