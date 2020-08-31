
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))
--- INSERT STATIC DATA
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Counterparty')
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Ledger Account Debit')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Ledger Account Debit', 'Ledger Account Debit'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Ledger Account Debit'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Ledger Account Credit')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Ledger Account Credit', 'Ledger Account Credit'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Ledger Account Credit'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Cost Bearer')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Cost Bearer', 'Cost Bearer'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Cost Bearer'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Comment')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Comment', 'Comment'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Comment'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Charge Type')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Charge Type', 'Charge Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Charge Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Formula Row')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Formula Row', 'Formula Row'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Formula Row'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'UOM')
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
--- INSERT STATIC DATA END

--- INSERT UDFs

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
           'SELECT contract_id id, contract_name value FROM contract_group value WHERE is_active = ''y'' ORDER BY 2',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Contract'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT contract_id id, contract_name value FROM contract_group value WHERE is_active = ''y'' ORDER BY 2'
    WHERE  Field_label = 'Contract'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Counterparty'
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
           'Counterparty',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_counterparty_id id, counterparty_name value FROM source_counterparty WHERE is_active = ''y'' ORDER BY 2',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Counterparty'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_counterparty_id id, counterparty_name value FROM source_counterparty WHERE is_active = ''y'' ORDER BY 2'
    WHERE  Field_label = 'Counterparty'
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
           'SELECT source_commodity_id, commodity_name FROM source_commodity',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_commodity_id, commodity_name FROM source_commodity'
    WHERE  Field_label = 'Commodity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Ledger Account Debit'
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
           'Ledger Account Debit',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Ledger Account Debit'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Ledger Account Debit'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Ledger Account Credit'
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
           'Ledger Account Credit',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Ledger Account Credit'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Ledger Account Credit'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Ledger Account Credit'
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
           'Ledger Account Credit',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Ledger Account Credit'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Ledger Account Credit'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Cost Bearer'
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
           'Cost Bearer',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Cost Bearer'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Cost Bearer'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Comment'
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
           'Comment',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Comment'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Comment'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Charge Type'
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
           'Charge Type',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id id, code value FROM static_data_value sdv WHERE sdv.[type_id] = 10019 ORDER BY 2',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Charge Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT value_id id, code value FROM static_data_value sdv WHERE sdv.[type_id] = 10019 ORDER BY 2'
    WHERE  Field_label = 'Charge Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Formula Row'
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
           'Formula Row',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT n id , n value FROM seq WHERE n < 31',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Formula Row'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT n id , n value FROM seq WHERE n < 31'
    WHERE  Field_label = 'Formula Row'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'UOM'
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
           'UOM',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_uom_id, uom_name FROM source_uom',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'UOM'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_uom_id, uom_name FROM source_uom'
    WHERE  Field_label = 'UOM'
END

--- INSERT UDFs END

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'AFAS')
BEGIN
	PRINT 'AFAS Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
		mapping_name,
		total_columns_used
	) VALUES (
		'AFAS',
		10
	)
END

/* step 4: Insert into Generic Mapping Defination*/

DECLARE @contract INT
DECLARE @counterparty INT
DECLARE @commodity INT
DECLARE @ledger_account_debit INT
DECLARE @ledger_account_credit INT
DECLARE @cost_bearer INT
DECLARE @comment INT
DECLARE @charge_type INT
DECLARE @formula_row INT
DECLARE @uom INT

SELECT @contract = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @counterparty = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @commodity = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Commodity'
SELECT @ledger_account_debit = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Ledger Account Debit'
SELECT @ledger_account_credit = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Ledger Account Credit'
SELECT @cost_bearer = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Cost Bearer'
SELECT @comment = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Comment'
SELECT @charge_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Charge Type'
SELECT @formula_row = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Formula Row'
SELECT @uom = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'UOM'
  
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'AFAS')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Contract',
		clm1_udf_id = @contract,
		clm2_label = 'Counterparty',
		clm2_udf_id = @counterparty,
		clm3_label = 'Commodity',
		clm3_udf_id = @commodity,
		clm4_label = 'Ledger Account Debit',
		clm4_udf_id = @ledger_account_debit,
		clm5_label = 'Ledger Account Credit',
		clm5_udf_id = @ledger_account_credit,
		clm6_label = 'Cost Bearer',
		clm6_udf_id = @cost_bearer,
		clm7_label = 'Comment',
		clm7_udf_id = @comment,
		clm8_label = 'Charge Type',
		clm8_udf_id = @charge_type,
		clm9_label = 'Formula Row',
		clm9_udf_id = @formula_row,
		clm10_label = 'UOM',
		clm10_udf_id = @uom
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'AFAS'
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
		clm10_label, clm10_udf_id
	)
	SELECT 
		mapping_table_id,
		'Contract', @contract,
		'Counterparty', @counterparty,
		'Commodity', @commodity,
		'Ledger Account Debit', @ledger_account_debit,
		'Ledger Account Credit', @ledger_account_credit,
		'Cost Bearer', @cost_bearer,
		'Comment', @comment,
		'Charge Type', @charge_type,
		'Formula Row', @formula_row,
		'UOM', @uom
	FROM generic_mapping_header 
	WHERE mapping_name = 'AFAS'
END