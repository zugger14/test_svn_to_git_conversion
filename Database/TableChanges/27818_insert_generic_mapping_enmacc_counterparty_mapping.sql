/* step 1:Defining static data for each UDF */
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL 
 DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external 
( 
	value_id     INT, 
     [type_id]   INT, 
    [type_name] VARCHAR(500) 
) 

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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TRM Counterparty')  
BEGIN 
    INSERT INTO static_data_value ([type_id], code, [description]) 
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code 
		INTO #insert_output_sdv_external 
    SELECT '5500', 'TRM Counterparty', 'TRM Counterparty' 
END 
ELSE 
BEGIN 
    INSERT INTO #insert_output_sdv_external 
    SELECT value_id, [type_id], code 
    FROM static_data_value 
    WHERE [type_id] = 5500 
           AND [code] = 'TRM Counterparty' 
END 

/*step 2 Defining UDF*/

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
           'NVARCHAR(250)',
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
       WHERE  Field_label = 'TRM Counterparty'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'TRM Counterparty',
           'd',
           'NVARCHAR(250)',
           'n',
           'EXEC spa_source_counterparty_maintain @flag = ''c'',  @not_int_ext_flag = ''b''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TRM Counterparty'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_source_counterparty_maintain @flag = ''c'',  @not_int_ext_flag = ''b'''
    WHERE  Field_label = 'TRM Counterparty'
END


/* Step 3: Insert Generic Mapping Header */
IF NOT EXISTS( SELECT * FROM generic_mapping_header WHERE mapping_name = 'ENMACC Counterparty Mapping')
BEGIN 
	INSERT INTO generic_mapping_header ( mapping_name, total_columns_used, system_defined)
	VALUES ( 'ENMACC Counterparty Mapping', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ENMACC Counterparty Mapping'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ENMACC Counterparty Mapping'
END

-- Mapping Definition
DECLARE @mapping_table_id INT
	  , @source_counterparty INT
	  , @trm_counterparty INT
	  
SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ENMACC Counterparty Mapping'

SELECT @source_counterparty = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Source Counterparty'

SELECT @trm_counterparty = udf_template_id 
FROM user_defined_fields_template 
WHERE  Field_label = 'TRM Counterparty'

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id
		, clm1_label
		, clm1_udf_id
		, clm2_label
		, clm2_udf_id
		, unique_columns_index
	)
	SELECT @mapping_table_id
		,'Source Counterparty'
		, @source_counterparty
		, 'TRM Counterparty'
		, @trm_counterparty
		, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET	clm1_label	= 'Source Counterparty'
		, clm1_udf_id = @source_counterparty
		, clm2_label	= 'TRM Counterparty'
		, clm2_udf_id = @trm_counterparty
		, unique_columns_index = '1'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ENMACC Counterparty Mapping'
END