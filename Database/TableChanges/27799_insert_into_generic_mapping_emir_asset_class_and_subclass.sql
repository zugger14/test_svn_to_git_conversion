--1 Static Data Value
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Asset Class')
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
		'Asset Class',
		'Asset Class'
	)
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Asset Class'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Asset Sub Class')
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
		'Asset Sub Class',
		'Asset Sub Class'
	)
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Asset Sub Class'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Type')
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
		'Deal Type',
		'Deal Type'
	)
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Deal Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Multiplier')
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
		'Multiplier',
		'Multiplier'
	)
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Multiplier'
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
           'VARCHAR(150)',
           'n',
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
       WHERE  Field_label = 'Asset Class'
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
           'Asset Class',
           't',
           'NVARCHAR(250)',
           'n',
           NULL,
           'h',
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[code] = 'Asset Class'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Asset Class'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Asset Sub Class'
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
           'Asset Sub Class',
           't',
           'NVARCHAR(250)',
           'n',
           NULL,
           'h',
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[code] = 'Asset Sub Class'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL
    WHERE  Field_label = 'Asset Sub Class'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Type'
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
           'Deal Type',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''n''',
           'h',
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[code] = 'Deal Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string =  'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''n'''
    WHERE  Field_label = 'Deal Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Multiplier'
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
           'Multiplier',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[code] = 'Multiplier'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string =  NULL
    WHERE  Field_label = 'Multiplier'
END

--Generic Mapping Table 
IF NOT EXISTS( SELECT * FROM generic_mapping_header WHERE mapping_name = 'EMIR Asset Class and Subclass')
BEGIN 
	INSERT INTO generic_mapping_header (
		mapping_name, 
		total_columns_used, 
		system_defined
	)
	VALUES (
		'EMIR Asset Class and Subclass', 
		5, 
		0
	)
END

-- Mapping Definition
DECLARE @mapping_table_id INT
	  , @commodity INT
	  , @asset_class INT
	  , @asset_sub_class INT
	  , @deal_type INT
	  , @multiplier INT
	  
SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'EMIR Asset Class and Subclass'

SELECT @commodity = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Commodity')

SELECT @asset_class = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Asset Class')

SELECT @asset_sub_class = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Asset Sub Class')

SELECT @deal_type = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Deal Type')

SELECT @multiplier = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Multiplier')

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
		, unique_columns_index
	)
	SELECT @mapping_table_id
		,'Commodity'
		, @commodity
		, 'Asset Class'
		, @asset_class
		, 'Asset Sub Class'
	    , @asset_sub_class
		, 'Deal Type'
		, @deal_type
		, 'Multiplier'
		, @multiplier
		, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET	clm1_label	= 'Commodity'
		, clm1_udf_id = @commodity
		, clm2_label	= 'Asset Class'
		, clm2_udf_id = @asset_class
		, clm3_label	= 'Asset Sub Class'
		, clm3_udf_id = @asset_sub_class
		, clm4_label	= 'Deal Type'
		, clm4_udf_id = @deal_type
		, clm5_label	= 'Multiplier'
		, clm5_udf_id = @multiplier
		, unique_columns_index = '1'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'EMIR Asset Class and Subclass'
END