
-- Static Data Insert
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'UOM')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'UOM', 'UOM'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'UOM'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Projection Index Group')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Projection Index Group', 'Projection Index Group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Projection Index Group'
END

-- Static Data Insert END

-- UDF insert
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Projection Index Group')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Projection Index Group', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 53'
			, 'h',	NULL, 30, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Projection Index Group'	
END
ELSE
BEGIN
	PRINT 'print data already exists'
END	

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'UOM')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'UOM', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT source_uom_id, uom_id FROM  source_uom'
			, 'h',	NULL, 30, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'UOM'	
END
ELSE
BEGIN
	PRINT 'print data already exists'
END	

-- UDF insert END

-- Insert Generic Mapping
IF NOT EXISTS(SELECT 1 FROM  generic_mapping_header WHERE mapping_name = 'Projection Index Group')
BEGIN
	INSERT INTO generic_mapping_header (

	mapping_name,
	total_columns_used
	) VALUES (
	'Projection Index Group',
	2
	)
END

DECLARE @poig INT, @uom INT, @mapping_table_id INT
SELECT @poig = udf_template_id
  FROM user_defined_fields_template WHERE Field_label = 'Projection Index Group'
SELECT @uom = udf_template_id
  FROM user_defined_fields_template WHERE Field_label =  'UOM'
  
SELECT @mapping_table_id = mapping_table_id FROM  generic_mapping_header gmh 
WHERE mapping_name = 'Projection Index Group'  
  
IF NOT EXISTS(SELECT 1 FROM  generic_mapping_header gmh 
              INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
               WHERE mapping_name = 'Projection Index Group')
BEGIN
	INSERT INTO generic_mapping_definition (mapping_table_id,
											clm1_label,
											clm1_udf_id,
											clm2_label,
											clm2_udf_id)
	VALUES ( @mapping_table_id,
			'Projection Index Group',
			@poig,	
			'UOM',
			@uom)
END
ELSE
	PRINT 'data already exists.'


