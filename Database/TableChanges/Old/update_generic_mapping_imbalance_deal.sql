DECLARE @mapping_table_id INT

SELECT @mapping_table_id = mapping_table_id
FROM   generic_mapping_header
WHERE  mapping_name = 'Imbalance Deal'

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
	SELECT '5500', 'Counterparty', 'Counterparty'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Counterparty'
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Meter')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Meter', 'Meter'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Meter'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Insert Template')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Insert Template', 'Insert Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Offset Template'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Offset Template')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Offset Template', 'Offset Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Offset Template'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Closeout Template')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Closeout Template', 'Closeout Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Closeout Template'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Imbalance Transfer Template')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Imbalance Transfer Template', 'Imbalance Transfer Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Imbalance Transfer Template'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Reporting Contract')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Reporting Contract', 'Reporting Contract'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Reporting Contract'
END
/* step 1 end */

/* step 2 start*/
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
           'SELECT cg.contract_id, cg.contract_name FROM contract_group cg',
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
    SET    sql_string = 'SELECT cg.contract_id, cg.contract_name FROM contract_group cg'
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
           'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Counterparty'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc'
    WHERE  Field_label = 'Counterparty'
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
           'SELECT sml.source_minor_location_id, sml.Location_Name FROM source_minor_location sml',
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
    SET    sql_string = 'SELECT sml.source_minor_location_id, sml.Location_Name FROM source_minor_location sml'
    WHERE  Field_label = 'Location'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Meter'
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
           'Meter',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT meter_id, recorderid FROM meter_id',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Meter'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT meter_id, recorderid FROM meter_id'
    WHERE  Field_label = 'Meter'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Insert Template'
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
           'Insert Template',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT sdht.template_id, sdht.template_name FROM source_deal_header_template sdht',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Insert Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sdht.template_id, sdht.template_name FROM source_deal_header_template sdht'
    WHERE  Field_label = 'Insert Template'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Offset Template'
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
           'Offset Template',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT sdht.template_id, sdht.template_name FROM source_deal_header_template sdht',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Offset Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sdht.template_id, sdht.template_name FROM source_deal_header_template sdht'
    WHERE  Field_label = 'Offset Template'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Closeout Template'
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
           'Closeout Template',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT sdht.template_id, sdht.template_name FROM source_deal_header_template sdht',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Closeout Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sdht.template_id, sdht.template_name FROM source_deal_header_template sdht'
    WHERE  Field_label = 'Closeout Template'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Imbalance Transfer Template'
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
           'Imbalance Transfer Template',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT sdht.template_id, sdht.template_name FROM source_deal_header_template sdht',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Imbalance Transfer Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sdht.template_id, sdht.template_name FROM source_deal_header_template sdht'
    WHERE  Field_label = 'Imbalance Transfer Template'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Reporting Contract'
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
           'Reporting Contract',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT cg.contract_id, cg.contract_name FROM contract_group cg',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Reporting Contract'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT cg.contract_id, cg.contract_name FROM contract_group cg'
    WHERE  Field_label = 'Reporting Contract'
END

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Imbalance Deal')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Imbalance Deal',
	9
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @contract INT
DECLARE @counterparty INT
DECLARE @location INT
DECLARE @meter INT
DECLARE @insert_template INT
DECLARE @offset_template INT
DECLARE @closeout_template INT
DECLARE @imbalance_transfer_template INT
DECLARE @reporting_contract INT

SELECT @contract = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @counterparty = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @location = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Location'  
SELECT @meter = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Meter'
SELECT @insert_template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Insert Template'  
SELECT @offset_template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Offset Template'
SELECT @closeout_template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Closeout Template'
SELECT @imbalance_transfer_template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Imbalance Transfer Template'
SELECT @reporting_contract = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Reporting Contract'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Imbalance Deal')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Contract',
		clm1_udf_id = @contract,
		clm2_label = 'Counterparty',
		clm2_udf_id = @counterparty,
		clm3_label = 'Location',
		clm3_udf_id = @location,
		clm4_label = 'Meter',
		clm4_udf_id = @meter,
		clm5_label = 'Insert Template',
		clm5_udf_id = @insert_template,
		clm6_label = 'Offset Template',
		clm6_udf_id = @offset_template,
		clm7_label = 'Closeout Template',
		clm7_udf_id = @closeout_template,
		clm8_label = 'Imbalance Transfer Template',
		clm8_udf_id = @imbalance_transfer_template,
		clm9_label = 'Reporting Contract',
		clm9_udf_id = @reporting_contract
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Imbalance Deal'
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
		clm9_label, clm9_udf_id
	)
	SELECT 
		mapping_table_id,
		'Contract', @contract,
		'Counterparty', @counterparty,
		'Location', @location,
		'Meter',@meter,
		'Insert Template', @insert_template,
		'Offset Template', @offset_template,
		'Closeout Template', @closeout_template,
		'Imbalance Transfer Template', @imbalance_transfer_template,
		'Reporting Contract', @reporting_contract
	FROM generic_mapping_header 
	WHERE mapping_name = 'Imbalance Deal'
END
