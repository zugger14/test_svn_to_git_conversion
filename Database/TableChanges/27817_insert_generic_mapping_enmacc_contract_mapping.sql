/*  step 1 */
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Counterparty') 
BEGIN 
    INSERT INTO static_data_value ( [type_id], code, [description] ) 
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code 
        INTO #insert_output_sdv_external 
    SELECT '5500', 'Source Counterparty', 'Source Counterparty' 
END 
ELSE 
BEGIN 
    INSERT INTO #insert_output_sdv_external 
    SELECT value_id, [type_id], code 
    FROM static_data_value 
    WHERE [type_id] = 5500 
           AND [code] = 'Source Counterparty' 
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
	FROM static_data_value 
	WHERE [type_id] = 5500 AND [code] = 'Commodity'
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
	FROM static_data_value 
	WHERE [type_id] = 5500 AND [code] = 'Contract'
END

/*  step 2 */

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Counterparty'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Source Counterparty',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source Counterparty'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 200
    WHERE  Field_label = 'Source Counterparty'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Commodity'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Commodity',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_source_commodity_maintain @flag = ''a''',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
           sql_string = 'EXEC spa_source_commodity_maintain @flag = ''a'''
    WHERE  Field_label = 'Commodity'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Contract'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Contract',
           'd',
           'VARCHAR(250)',
           'n',
           'EXEC spa_contract_group @flag = ''n''',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Contract'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
           sql_string = 'EXEC spa_contract_group @flag = ''n'''
    WHERE  Field_label = 'Contract'
END

/* Step 3: Insert Generic Mapping Header */
IF NOT EXISTS( SELECT * FROM generic_mapping_header WHERE mapping_name = 'ENMACC Contract Mapping')
BEGIN 
	INSERT INTO generic_mapping_header (
		mapping_name, 
		total_columns_used, 
		system_defined
	)
	VALUES (
		'ENMACC Contract Mapping', 
		3, 
		0
	)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ENMACC Contract Mapping'
	  , total_columns_used = 3
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ENMACC Contract Mapping'
END

-- Mapping Definition
DECLARE @mapping_table_id INT
	  , @source_counterparty INT
	  , @commodity INT
	  , @contract INT
	  
SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ENMACC Contract Mapping'

SELECT @source_counterparty = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Source Counterparty'

SELECT @commodity = udf_template_id 
FROM user_defined_fields_template 
WHERE  Field_label = 'Commodity'

SELECT @contract = udf_template_id 
FROM user_defined_fields_template 
WHERE  Field_label = 'Contract'

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id
		, clm1_label
		, clm1_udf_id
		, clm2_label
		, clm2_udf_id
		, clm3_label
		, clm3_udf_id
		, unique_columns_index
	)
	SELECT @mapping_table_id
		,'Source Counterparty'
		, @source_counterparty
		, 'Commodity'
		, @commodity
		, 'Contract'
		, @contract
		, '1,2'
END
ELSE
BEGIN
	UPDATE gmd
	SET	clm1_label	= 'Source Counterparty'
		, clm1_udf_id = @source_counterparty
		, clm2_label	= 'Commodity'
		, clm2_udf_id = @commodity		
		, clm3_label	= 'Contract'
		, clm3_udf_id = @contract
		, unique_columns_index = '1,2'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ENMACC Contract Mapping'
END