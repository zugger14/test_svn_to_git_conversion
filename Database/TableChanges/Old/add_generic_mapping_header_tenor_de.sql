
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tenor Bucket DE')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Tenor Bucket DE', 'Tenor Bucket DE'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tenor Bucket DE'
END

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Tenor Bucket DE')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Tenor Bucket DE', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT bucket_header_id, bucket_header_name FROM risk_tenor_bucket_header WHERE bucket_header_name NOT LIKE ''%UK'' AND bucket_header_name NOT LIKE ''emissions'''
				
			, 'h',	NULL, 30, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Tenor Bucket DE'	
END
ELSE 
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT bucket_header_id, bucket_header_name FROM risk_tenor_bucket_header WHERE bucket_header_name NOT LIKE ''%UK'' AND bucket_header_name NOT LIKE ''emissions'''
	WHERE Field_label = 'Tenor Bucket DE'
END

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Tenor Bucket DE')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Tenor Bucket DE',
	2
	)
END

DECLARE @tenor_bucket_de INT 
DECLARE @index INT 
SELECT @tenor_bucket_de = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Tenor Bucket DE'
SELECT @index = udft.udf_template_id
  FROM user_defined_fields_template udft WHERE udft.Field_label = 'index'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
			WHERE gmh.mapping_name = 'Tenor Bucket DE')
BEGIN
	UPDATE gmd
	SET mapping_table_id = gmh.mapping_table_id,
		clm1_label = 'Index',
		clm1_udf_id = @index,
		clm2_label = 'Tenor Bucket DE',
		clm2_udf_id = @tenor_bucket_de
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Tenor Bucket DE'

END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition
	(
		mapping_table_id,
		clm1_label,
		clm1_udf_id,
		clm2_label,
		clm2_udf_id
	)
	SELECT  mapping_table_id,
			'Index',
			@index,
			'Tenor Bucket DE',
			@tenor_bucket_de
	FROM generic_mapping_header 
	WHERE mapping_name = 'Tenor Bucket DE' 
	END

GO