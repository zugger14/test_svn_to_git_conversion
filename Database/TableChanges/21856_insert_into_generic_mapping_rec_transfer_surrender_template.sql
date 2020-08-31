UPDATE generic_mapping_header
SET mapping_name = 'REC Transfer/Surrender Template'
WHERE mapping_name = 'RPS REC Import Template'


/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Source Template')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Deal Source Template', 'Deal Source Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Deal Source Template'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Jurisdiction')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Jurisdiction', 'Jurisdiction'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Jurisdiction'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Retirement Types')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Retirement Types', 'Retirement Types'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Retirement Types'
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Source Template'
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
           'Deal Source Template',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT template_id, template_name FROM source_deal_header_template WHERE is_active = ''y''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Source Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT template_id, template_name FROM source_deal_header_template WHERE is_active = ''y'''
    WHERE  Field_label = 'Deal Source Template'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Jurisdiction'
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
           'Jurisdiction',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10002',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Jurisdiction'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10002'
    WHERE  Field_label = 'Jurisdiction'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Retirement Types'
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
           'Retirement Types',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10013',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Retirement Types'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10013'
    WHERE  Field_label = 'Retirement Types'
END

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'REC Transfer/Surrender Template')
BEGIN
	PRINT 'Mapping Table Already Exists'
	UPDATE generic_mapping_header SET total_columns_used = 3 WHERE mapping_name = 'REC Transfer/Surrender Template'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'REC Transfer/Surrender Template',
	3
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @deal_source_template INT, @jurisdiction INT, @retirement_types INT

SELECT @deal_source_template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Source Template'
SELECT @jurisdiction = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Jurisdiction'
SELECT @retirement_types = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Retirement Types'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'REC Transfer/Surrender Template')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Deal Source Template',
		clm1_udf_id = @deal_source_template,
		clm2_label = 'Jurisdiction',
		clm2_udf_id = @jurisdiction,
		clm3_label = 'Retirement Types',
		clm3_udf_id = @retirement_types	,
		unique_columns_index = '1,2,3',
		required_columns_index = '1,3'				
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'REC Transfer/Surrender Template'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		unique_columns_index, required_columns_index
	)
	SELECT 
		mapping_table_id,
		'Deal Source Template', @deal_source_template,
		'Jurisdiction', @jurisdiction,
		'Retirement Types', @retirement_types,
		'1,2,3','1,3'	
	FROM generic_mapping_header 
	WHERE mapping_name = 'REC Transfer/Surrender Template'
END

