/*  step 1 */
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Product')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Source Product', 'Source Product'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code 
	FROM static_data_value 
	WHERE [type_id] = 5500 AND [code] = 'Source Product'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TRM Index')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'TRM Index', 'TRM Index'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TRM Index'
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


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Granularity')
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
	FROM static_data_value 
	WHERE [type_id] = 5500 AND [code] = 'Granularity'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'DealTemplate')
BEGIN
    INSERT INTO static_data_value ([type_id], [code], [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
    SELECT 5500,  'DealTemplate', 'Deal Template'   
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'DealTemplate'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Volume Frequency')
BEGIN
    INSERT INTO static_data_value ([type_id], [code], [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
    SELECT 5500, 'Volume Frequency', 'Volume Frequency'
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Volume Frequency'
END 

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Location')
BEGIN
    INSERT INTO static_data_value ([type_id], [code], [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
    SELECT 5500, 'Location', 'Location'
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code 
	FROM static_data_value 
	WHERE [type_id] = 5500 AND [code] = 'Location'
END 

/*  step 2 */
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Product'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Source Product',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source Product'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 200
    WHERE  Field_label = 'Source Product'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'TRM Index'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'TRM Index',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TRM Index'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
    WHERE  Field_label = 'TRM Index'
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
       WHERE  Field_label = 'Granularity'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Granularity',
           'd',
           'int',
           'n',
           'EXEC spa_staticdatavalues @flag = ''h'', @type_id = ''978''',
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
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_staticdatavalues @flag = ''h'', @type_id = ''978''',
		   data_type = 'int'
    WHERE  Field_label = 'Granularity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'DealTemplate'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'DealTemplate',
           'd',
           'int',
           'n',
           'EXEC spa_getDealTemplate ''s''',
           'o',
           NULL,
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'DealTemplate'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_getDealTemplate ''s''',
		   data_type = 'int',
		   udf_type = 'o'
    WHERE  Field_label = 'DealTemplate'
END

 
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Volume Frequency'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Volume Frequency',
           'd',
           'int',
           'n',
           'EXEC  spa_getVolumeFrequency NULL,NULL',
           'o',
           NULL,
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Volume Frequency'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC  spa_getVolumeFrequency NULL,NULL',
		   data_type = 'int',
		   udf_type = 'o'
    WHERE  Field_label = 'Volume Frequency'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Location'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Location',
           'd',
           'NVARCHAR(250)',
           'n',
           'EXEC spa_source_minor_location ''o''',
           'h',
           NULL,
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Location'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_source_minor_location ''o''',
		   data_type = 'NVARCHAR(250)',
		   udf_type = 'h'
    WHERE  Field_label = 'Location'
END

/* Step 3: Insert Generic Mapping Header */
IF NOT EXISTS( SELECT * FROM generic_mapping_header WHERE mapping_name = 'ENMACC Product Mapping')
BEGIN 
	INSERT INTO generic_mapping_header (
		mapping_name, 
		total_columns_used, 
		system_defined
	)
	VALUES (
		'ENMACC Product Mapping', 
		7, 
		0
	)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ENMACC Product Mapping'
	  , total_columns_used = 7
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ENMACC Product Mapping'
END

-- Mapping Definition
DECLARE @mapping_table_id INT
	  , @source_product INT
	  , @trm_index INT
	  , @commodity_id INT
	  , @granularity_id INT
	  , @template_id INT
	  , @volume_frequency INT
	  , @location int
	  
SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ENMACC Product Mapping'

SELECT @source_product = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Source Product'

SELECT @trm_index = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'TRM Index'

SELECT @commodity_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Commodity'

SELECT @granularity_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Granularity'

SELECT @template_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'DealTemplate'

SELECT @volume_frequency = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Volume Frequency'

SELECT @location = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Location'

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
		, clm5_label
		, clm5_udf_id
		, clm6_label
		, clm6_udf_id
		, clm7_label
		, clm7_udf_id
		, unique_columns_index 
	)
	SELECT @mapping_table_id
		,'Source Product'
		, @source_product
		, 'TRM Index'
		, @trm_index
		, 'Commodity'
		, @commodity_id
		, 'Granularity'
		, @granularity_id
		, 'Deal Template'
		, @template_id
		, 'Volume Frequency'
		, @volume_frequency		
		, 'Location'
		, @location
		, '1,2,4'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Source Product'
		, clm1_udf_id = @source_product
		, clm2_label = 'TRM Index'
		, clm2_udf_id = @trm_index
		, clm3_label = 'Commodity'
		, clm3_udf_id = @commodity_id
		, clm4_label = 'Granularity'
		, clm4_udf_id = @granularity_id
		, clm5_label = 'Deal Template'
		, clm5_udf_id = @template_id
		, clm6_label = 'Volume Frequency'
		, clm6_udf_id = @volume_frequency
		, clm7_label = 'Location'
		, clm7_udf_id = @location
		, unique_columns_index = '1,2,4'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ENMACC Product Mapping'
END