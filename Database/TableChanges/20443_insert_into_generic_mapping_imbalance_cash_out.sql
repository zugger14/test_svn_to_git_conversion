--Imbalance deal
/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Granularity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Granularity', 'Granularity'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Granularity'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Volume Threshold')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Volume Threshold', 'Volume Threshold'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Volume Threshold'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Settlement on Cash Out')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Settlement on Cash Out', 'Settlement on Cash Out'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Settlement on Cash Out'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Price/Formula')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Price/Formula', 'Price/Formula'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Price/Formula'
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

/* step 1 end */

/* step 2 start*/

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Granularity'
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
           'Granularity',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value WHERE value_id IN (981,980)',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Granularity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value WHERE value_id IN (981,980)'
    WHERE  Field_label = 'Granularity'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Volume Threshold'
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
           'Volume Threshold',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Volume Threshold'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'Volume Threshold'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Settlement on Cash Out'
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
           'Settlement on Cash Out',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Settlement on Cash Out'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'Settlement on Cash Out'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Price/Formula'
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
           'Price/Formula',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Price/Formula'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'Price/Formula'
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

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Imbalance Cash Out')
BEGIN
	UPDATE generic_mapping_header
	SET total_columns_used = 4
	WHERE mapping_name = 'Imbalance Cash Out'
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used,
	function_ids
	) VALUES (
	'Imbalance Cash Out',
	5,
	'10211400,10211300'
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @granularity INT
DECLARE @volume_threshold INT
DECLARE @settlement_on_cash_out INT
DECLARE @price_volume INT
DECLARE @contract INT

SELECT @contract = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @granularity = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Granularity'  
SELECT @volume_threshold = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Volume Threshold'
SELECT @settlement_on_cash_out = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Settlement on Cash Out'
SELECT @price_volume = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Price/Formula'  

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Imbalance Cash Out')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Contract',
		clm1_udf_id = @contract,
		clm2_label = 'Granularity',
		clm2_udf_id = @granularity,
		clm3_label = 'Volume Threshold',
		clm3_udf_id = @volume_threshold,
		clm4_label = 'Settlement on Cash Out',
		clm4_udf_id = @settlement_on_cash_out,
		clm5_label = 'Price/Formula',
		clm5_udf_id = @price_volume,
		primary_column_index = 1
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Imbalance Cash Out'
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
		primary_column_index
	)
	SELECT 
		mapping_table_id,
		'Contract', @contract,
		'Granularity', @granularity,
		'Volume Threshold',@volume_threshold,
		'Settlement on Cash Out', @settlement_on_cash_out,
		'Price/Formula', @price_volume,
		1
	FROM generic_mapping_header 
	WHERE mapping_name = 'Imbalance Cash Out'
END

