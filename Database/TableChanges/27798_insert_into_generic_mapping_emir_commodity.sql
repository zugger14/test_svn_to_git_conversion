-- 1 STATIC DATA VALUE

IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL 
 DROP TABLE #insert_output_sdv_external 
CREATE TABLE #insert_output_sdv_external 
( 
	value_id    INT, 
	[type_id]   INT, 
	[code] VARCHAR(500) 
) 

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Commodity')
BEGIN
    INSERT INTO static_data_value (
		[type_id],  
		[code], 
		[description]
	)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	VALUES (
		5500, 
		'Commodity',
		'Commodity'
	)
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Commodity'
END
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Energy Commodity')
BEGIN
    INSERT INTO static_data_value (
		[type_id],  
		[code], 
		[description]
	) 
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	VALUES (
		5500, 
		'Energy Commodity',
		'Energy Commodity'
	)
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Energy Commodity'
END

-- 2 UDF Template
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Commodity'
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
           'Commodity',
           'd',
           'nvarchar(250)',
           'y',
           'EXEC spa_source_commodity_maintain @flag = ''a''',
           'h',
           100,
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
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Energy Commodity'
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
           'Energy Commodity',
           't',
           'nvarchar(250)',
           'n',
           NULL,
           'h',
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[code] = 'Energy Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Energy Commodity'
END

--Generic Mapping Table 
IF NOT EXISTS( SELECT * FROM generic_mapping_header WHERE mapping_name = 'EMIR Commodity')
BEGIN 
	INSERT INTO generic_mapping_header (
		mapping_name, 
		total_columns_used, 
		system_defined
	)
	VALUES (
		'EMIR Commodity', 
		2, 
		0
	)
END

-- Mapping Definition
DECLARE @mapping_table_id INT
	  , @commodity INT
	  , @energy_commodity INT
	  
SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'EMIR Commodity'

SELECT @commodity = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Commodity')

SELECT @energy_commodity = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Energy Commodity')


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
		,'Commodity'
		, @commodity
		, 'Energy Commodity'
		, @energy_commodity
		, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET	clm1_label	= 'Commodity'
		, clm1_udf_id = @commodity
		, clm2_label = 'Energy Commodity'
		, clm2_udf_id = @energy_commodity
		, unique_columns_index = '1'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'EMIR Commodity'
END