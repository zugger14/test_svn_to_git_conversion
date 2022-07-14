/*  step 1 : add sdv*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL 
	DROP TABLE #insert_output_sdv_external 

CREATE TABLE #insert_output_sdv_external 
( 
	value_id    INT, 
	[type_id]   INT, 
	[code] VARCHAR(500) 
)

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Block')
BEGIN
    INSERT INTO static_data_value ( [type_id], [code], [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	VALUES (
		5500, 
		'Source Block',
		'Source Block'
	)
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source Block'
END
 
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Block Definition')
BEGIN
    INSERT INTO static_data_value ( [type_id], [code], [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	VALUES (
		5500, 
		'Block Definition',
		'Block Definition'
	)
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Block Definition'
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Volume Type')
BEGIN
    INSERT INTO static_data_value ( [type_id], [code], [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	VALUES (
		5500, 
		'Volume Type',
		'Volume Type'
	)
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Volume Type'
END

/* step 1 end */

/* step 2 : UDF Template */
IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Block'
   )
BEGIN
	INSERT INTO user_defined_fields_template (
		field_name, 
		field_label,
		Field_type, 
		data_type, 
		is_required, 
		sql_string,
		udf_type, 
		field_size,
		field_id
	)
	SELECT iose.value_id,
           'Source Block',
           't',
           'NVARCHAR(250)',
           'y',
           NULL,
           'o',
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[code] = 'Source Block'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL,
		   udf_type = 'o'
    WHERE  Field_label = 'Source Block'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Block Definition'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Block Definition',
           'd',
           'VARCHAR(100)',
           'y',
           'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10018',
           'h',
           NULL,
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[code] = 'Block Definition'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
           field_size = 100,
		   sql_string = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10018'
    WHERE  Field_label = 'Block Definition'
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
           'NVARCHAR(250)',
           'n',
           'EXEC spa_source_commodity_maintain @flag = ''a''',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[code] = 'Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
           sql_string = 'EXEC spa_source_commodity_maintain @flag = ''a'''
    WHERE  Field_label = 'Commodity'
END

IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Volume Type'
   )
BEGIN
	INSERT INTO user_defined_fields_template (
		field_name, 
		field_label,
		Field_type, 
		data_type, 
		is_required, 
		sql_string,
		udf_type, 
		field_size,
		field_id
	)
	SELECT iose.value_id,
           'Volume Type',
           'd',
           'NVARCHAR(250)',
           'n',
           'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 17300',
           'o',
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[code] = 'Volume Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string =  'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 17300',
		   udf_type = 'o'
    WHERE  Field_label = 'Volume Type'
END

/* step 2 ends*/

/* Step 3: Insert Generic Mapping Header */
IF NOT EXISTS( SELECT * FROM generic_mapping_header WHERE mapping_name = 'ENMACC Block Mapping')
BEGIN 
	INSERT INTO generic_mapping_header (
		mapping_name, 
		total_columns_used, 
		system_defined
	)
	VALUES (
		'ENMACC Block Mapping', 
		4, 
		0
	)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ENMACC Block Mapping'
	  , total_columns_used = 4
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ENMACC Block Mapping'
END

-- Mapping Definition
DECLARE @mapping_table_id INT
	  , @source_block INT
	  , @block_definition INT
	  , @commodity INT
	  , @volume_type INT
	  
SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ENMACC Block Mapping'

SELECT @source_block = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Source Block'

SELECT @block_definition = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Block Definition'

SELECT @commodity = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Commodity'

SELECT @volume_type = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Volume Type'

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
		, clm4_label
		, clm4_udf_id
		, unique_columns_index
	)
	SELECT @mapping_table_id
		,'Source Block'
		, @source_block
		, 'Block Definition'
		, @block_definition
		,'Commodity'
		, @commodity
		, 'Volume Type'
		, @volume_type
		, NULL
END
ELSE
BEGIN
	UPDATE gmd
	SET	clm1_label	= 'Source Block'
		, clm1_udf_id = @source_block
		, clm2_label = 'Block Definition'
		, clm2_udf_id = @block_definition
		, clm3_label = 'Commodity'
		, clm3_udf_id = @commodity
		, clm4_label =  'Volume Type'
		, clm4_udf_id = @volume_type
		, unique_columns_index = NULL
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ENMACC Block Mapping'
END