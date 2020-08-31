--step 1: insert static_data_type --external

IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Internal Portfolio')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Internal Portfolio', 'Internal Portfolio'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Internal Portfolio'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Counterparty Group')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Counterparty Group', 'Counterparty Group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Counterparty Group'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Instrument Type')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Instrument Type', 'Instrument Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Instrument Type'
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tenor Bucket')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Tenor Bucket', 'Tenor Bucket'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tenor Bucket'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'UOM To')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'UOM To', 'UOM To'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'UOM To'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Index')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Index ', 'Index'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Index'
END

--Step2: Insert UDF

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Internal Portfolio')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Internal Portfolio', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 50'
			, 'h',	NULL, 30, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Internal Portfolio'	
END
ELSE 
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 50'
	WHERE Field_label = 'Internal Portfolio'
END

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Counterparty Group')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Counterparty Group', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 51'
			, 'h',	NULL, 30, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Counterparty Group'	
END
ELSE 
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 51'
	WHERE Field_label = 'Counterparty Group'
END

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Instrument Type')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Instrument Type', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 52'
			, 'h',	NULL, 30, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Instrument Type'	
END
ELSE 
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 52'
	WHERE Field_label = 'Instrument Type'
END

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Projection Index Group')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Projection Index Group', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 53'
			, 'h',	NULL, 30, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Projection Index Group'	
END
ELSE 
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 53'
	WHERE Field_label = 'Projection Index Group'
END

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'Index')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Index', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT source_curve_def_id, curve_name FROM source_price_curve_def'
			, 'h',	NULL, 30, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Index'	
END


IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label IN('Tenor Bucket', 'Tenor Bucket UK') )
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'Tenor Bucket', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT bucket_header_id, bucket_header_name FROM risk_tenor_bucket_header'
			, 'h',	NULL, 30, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'Tenor Bucket'	
END

--SELECT * FROM user_defined_fields_template udft order by 1 desc
--Step3: Insert Generic Mapping Header
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'UK Power Dynamic Limit')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'UK Power Dynamic Limit',
	4
	)
END

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'UK Gas Dynamic Limit')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN	
INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'UK Gas Dynamic Limit',
	4
	)
END

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'UK Coal Dynamic Limit')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN
INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'UK Coal Dynamic Limit',
	4
	)
END	

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Tenor Bucket')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN
INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Tenor Bucket',
	2
	)
END	
                                                                                                                                                                                              
DECLARE @internal_portfolio INT 
DECLARE @counterparty_group INT
DECLARE @instrument_type INT
DECLARE @projection_index_group INT 
DECLARE @tenor_bucket INT 
DECLARE @uom_to INT 
DECLARE @index INT

--SELECT * FROM  user_defined_fields_template 


--5
	
SELECT @internal_portfolio = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Internal Portfolio'
SELECT @counterparty_group = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty Group'
SELECT @instrument_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Instrument Type'
SELECT @projection_index_group = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Projection Index Group'
SELECT @tenor_bucket = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Tenor Bucket'
SELECT @uom_to = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'UOM To'
SELECT @index = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Index'                                                                                                                                                                                          


--SELECT @internal_portfolio, @counterparty_group,@instrument_type, @projection_index_group, @tenor_bucket, @uom_to, @index

--Step4: Insert Generic Mapping Detail
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id WHERE gmh.mapping_name = 'UK Power Dynamic Limit')
BEGIN
	UPDATE gmd
	SET mapping_table_id = gmh.mapping_table_id,
		clm1_label = 'Internal Portfolio',
		clm1_udf_id = @internal_portfolio,
		clm2_label = 'Counterparty Group',
		clm2_udf_id = @counterparty_group,
		clm3_label = 'Instrument Type',
		clm3_udf_id = @instrument_type,
		clm4_label = 'Projection Index Group',
		clm4_udf_id = @projection_index_group
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'UK Power Dynamic Limit'
	
END
ELSE
	BEGIN
		INSERT INTO generic_mapping_definition
	(
		mapping_table_id,
		clm1_label,
		clm1_udf_id,
		clm2_label,
		clm2_udf_id,
		clm3_label,
		clm3_udf_id,
		clm4_label,
		clm4_udf_id
	)
	SELECT  mapping_table_id,
			'Internal Portfolio',
			@internal_portfolio,
			'Counterparty Group',
			@counterparty_group,
			'Instrument Type',
			@instrument_type,
			'Projection Index Group',
			@projection_index_group
	FROM generic_mapping_header 
	WHERE mapping_name = 'UK Power Dynamic Limit' 
END
	
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'UK Gas Dynamic Limit')
BEGIN
	UPDATE gmd
	SET mapping_table_id = gmh.mapping_table_id,
		clm1_label = 'Internal Portfolio',
		clm1_udf_id = @internal_portfolio,
		clm2_label = 'Counterparty Group',
		clm2_udf_id = @counterparty_group,
		clm3_label = 'Instrument Type',
		clm3_udf_id = @instrument_type,
		clm4_label = 'Projection Index Group',
		clm4_udf_id = @projection_index_group
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'UK Gas Dynamic Limit'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition
	(
		mapping_table_id,
		clm1_label,
		clm1_udf_id,
		clm2_label,
		clm2_udf_id,
		clm3_label,
		clm3_udf_id,
		clm4_label,
		clm4_udf_id
	)
	SELECT  mapping_table_id,
				'Internal Portfolio',
				@internal_portfolio,
				'Counterparty Group',
				@counterparty_group,
				'Instrument Type',
				@instrument_type,
				'Projection Index Group',
				@projection_index_group
	FROM generic_mapping_header
	WHERE mapping_name = 'UK Gas Dynamic Limit' 
	--INNER JOIN user_defined_fields_template udft ON udft.Field_label = gm
END

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'UK Coal Dynamic Limit')
BEGIN
	UPDATE gmd
	SET mapping_table_id = gmh.mapping_table_id,
		clm1_label = 'Internal Portfolio',
		clm1_udf_id = @internal_portfolio,
		clm2_label = 'Counterparty Group',
		clm2_udf_id = @counterparty_group,
		clm3_label = 'Instrument Type',
		clm3_udf_id = @instrument_type,
		clm4_label = 'Projection Index Group',
		clm4_udf_id = @projection_index_group
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'UK Coal Dynamic Limit'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition
	(
		mapping_table_id,
		clm1_label,
		clm1_udf_id,
		clm2_label,
		clm2_udf_id,
		clm3_label,
		clm3_udf_id,
		clm4_label,
		clm4_udf_id
	)
	SELECT  mapping_table_id,
				'Internal Portfolio',
				@internal_portfolio,
				'Counterparty Group',
				@counterparty_group,
				'Instrument Type',
				@instrument_type,
				'Projection Index Group',
				@projection_index_group
	FROM generic_mapping_header 
	WHERE mapping_name = 'UK Coal Dynamic Limit' 
END

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Tenor Bucket')
BEGIN
	UPDATE gmd
	SET mapping_table_id = gmh.mapping_table_id,
		clm1_label = 'Index',
		clm1_udf_id = @index,
		clm2_label = 'Tenor Bucket',
		clm2_udf_id = @tenor_bucket
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Tenor Bucket'
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
				'Tenor Bucket',
				@tenor_bucket
				
	FROM generic_mapping_header 
	WHERE mapping_name = 'Tenor Bucket' 
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'MTM')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'MTM', 'MTM'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'MTM'
END

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE Field_label = 'MTM')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT 	iose.value_id,	'MTM', 'd', 'VARCHAR(150)', 'n'
			, 'SELECT ''y'' AS id, ''Yes'' AS Name UNION ALL SELECT ''n'', ''No'''
			, 'h',	NULL, 30, iose.value_id
	FROM #insert_output_sdv_external iose WHERE iose.[type_name] = 'MTM'	
END
ELSE 
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT ''y'' AS id, ''Yes'' AS Name UNION ALL SELECT ''n'', ''No'''
	WHERE Field_label = 'MTM'
END

DECLARE @power_id INT
DECLARE @gas_id INT
DECLARE @coal_id INT

SELECT @power_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Power Dynamic Limit'
SELECT @gas_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Gas Dynamic Limit'
SELECT @coal_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'UK Coal Dynamic Limit'

UPDATE generic_mapping_header SET total_columns_used = 5
WHERE mapping_table_id = @power_id

UPDATE generic_mapping_header SET total_columns_used = 5
WHERE mapping_table_id = @gas_id

UPDATE generic_mapping_header SET total_columns_used = 5
WHERE mapping_table_id = @coal_id


DECLARE @mtm INT
SELECT @mtm = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'MTM'

UPDATE  generic_mapping_definition 
SET  clm5_label = 'MTM',
	clm5_udf_id = @mtm
WHERE mapping_table_id = @power_id	
	
UPDATE  generic_mapping_definition 
SET  clm5_label = 'MTM',
	clm5_udf_id = @mtm
WHERE mapping_table_id = @gas_id	

UPDATE  generic_mapping_definition 
SET  clm5_label = 'MTM',
	clm5_udf_id = @mtm
WHERE mapping_table_id = @coal_id	


DECLARE @mapping_id INT
SELECT @mapping_id  = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Tenor Bucket UK' 

/*update Tenor Bucket to Tenor Bucket UK*/
--IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Tenor Bucket')
--BEGIN
	IF NOT EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Tenor Bucket UK')
	BEGIN
		UPDATE generic_mapping_header 
		SET mapping_name = 'Tenor Bucket UK'
		WHERE mapping_name = 'Tenor Bucket'


		UPDATE user_defined_fields_template 
		SET Field_label = 'Tenor Bucket UK',
			sql_string = 'SELECT bucket_header_id, bucket_header_name FROM risk_tenor_bucket_header WHERE bucket_header_name LIKE ''%UK'''
		 
		WHERE Field_label = 'Tenor Bucket'

		SELECT @mapping_id  = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Tenor Bucket UK' 

		UPDATE generic_mapping_definition
		SET clm2_label = 'Tenor Bucket UK'
		WHERE mapping_table_id = @mapping_id
	END
	ELSE 
	BEGIN
		UPDATE generic_mapping_definition
		SET clm2_label = 'Tenor Bucket UK'
		WHERE mapping_table_id = @mapping_id
		
		--SELECT * 
		DELETE gmd FROM generic_mapping_definition gmd
		INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
		WHERE gmh.mapping_name = 'Tenor Bucket'
		
		--SELECT * 
		DELETE FROM generic_mapping_header WHERE mapping_name = 'Tenor Bucket' 
	END
--END                                                                                                                                                                                          