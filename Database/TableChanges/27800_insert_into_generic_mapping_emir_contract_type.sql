--1 Static Data Value
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL 
 DROP TABLE #insert_output_sdv_external 
CREATE TABLE #insert_output_sdv_external 
( 
	value_id    INT, 
	[type_id]   INT, 
	[code] VARCHAR(500) 
)

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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'EMIR Contract Type')
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
		'EMIR Contract Type',
		'EMIR Contract Type'
	)
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'EMIR Contract Type'
END

-- 2 UDF Template

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
       WHERE  Field_label = 'EMIR Contract Type'
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
           'EMIR Contract Type',
           't',
           'VARCHAR(250)',
           'n',
           NULL,
           'h',
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[code] = 'EMIR Contract Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string =  NULL
    WHERE  Field_label = 'EMIR Contract Type'
END

--Generic Mapping Table 
IF NOT EXISTS( SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'EMIR Contract Type')
BEGIN 
	INSERT INTO generic_mapping_header (
		mapping_name, 
		total_columns_used, 
		system_defined
	)
	VALUES (
		'EMIR Contract Type', 
		2, 
		0
	)
END

-- Mapping Definition
DECLARE @mapping_table_id INT
	  , @deal_type INT
	  , @emir_contract_type INT
	  
SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'EMIR Contract Type'

SELECT @deal_type = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Deal Type')

SELECT @emir_contract_type = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'EMIR Contract Type')

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
		, 'Deal Type'
		, @deal_type
		, 'EMIR Contract Type'
		, @emir_contract_type
		, NULL
END
ELSE
BEGIN
	UPDATE gmd
	SET	 clm1_label	= 'Deal Type'
		, clm1_udf_id = @deal_type
		, clm2_label	= 'EMIR Contract Type'
		, clm2_udf_id = @emir_contract_type
		, unique_columns_index = NULL
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'EMIR Contract Type'
END