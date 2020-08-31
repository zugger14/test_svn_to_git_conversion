/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


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
	SELECT 5500, 'Counterparty', 'Counterparty'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Counterparty'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Invoice Date')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT 5500, 'Invoice Date', 'Invoice Date'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Invoice Date'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Time')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT 5500, 'Time', 'Time'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Time'
END
--/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE  Field_label = 'Contract')
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
           'SELECT contract_id id, contract_name value  FROM contract_group value ORDER BY 2',
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
    SET    sql_string = 'SELECT contract_id id, contract_name value  FROM contract_group value ORDER BY 2'
    WHERE  Field_label = 'Contract'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Counterparty')
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

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Invoice Date')
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
           'Invoice Date',
           'a',
           'DATETIME',
           'n',
           NULL,
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Invoice Date'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = NULL
    WHERE  Field_label = 'Invoice Date'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Time')
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
           'Time',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Time'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = NULL
    WHERE  Field_label = 'Time'
END

/* end of part 2 */

DECLARE @Contract INT
DECLARE @Counterparty INT
DECLARE @invoice_date INT
DECLARE @time INT

SELECT @Contract = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @Counterparty = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @invoice_date = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Invoice Date'
SELECT @time = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Time'

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Remit Invoice Date')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Remit Invoice Date',
		total_columns_used = 4
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Remit Invoice Date'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Remit Invoice Date',
	4
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Remit Invoice Date')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Contract',
		clm1_udf_id = @Contract,
		clm2_label = 'Counterparty',
		clm2_udf_id = @Counterparty,
		clm3_label = 'Invoice Date',
		clm3_udf_id = @invoice_date,
		clm4_label = 'Time',
		clm4_udf_id = @time
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Remit Invoice Date'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id
	)
	SELECT 
		mapping_table_id,
		'Contract', @Contract,
		'Counterparty', @Counterparty,
		'Invoice Date', @invoice_date,
		'Time', @time
	FROM generic_mapping_header 
	WHERE mapping_name = 'Remit Invoice Date'
END

--Setting Unique columns index
UPDATE gmd 
SET unique_columns_index = '1,2'
FROM generic_mapping_definition gmd
INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
WHERE gmh.mapping_name = 'Remit Invoice Date'