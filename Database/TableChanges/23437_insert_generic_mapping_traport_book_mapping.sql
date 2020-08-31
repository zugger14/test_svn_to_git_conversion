IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Trader')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Source Trader', 'Source Trader'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source Commodity'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Commodity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Source Commodity', 'Source Commodity'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source Commodity'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Book')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Source Book', 'Source Book'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source Book'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TRM SubBook')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'TRM SubBook', 'TRM SubBook'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TRM SubBook'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Trader'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Source Trader',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source Trader'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 200
    WHERE  Field_label = 'Source Trader'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Commodity'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Source Commodity',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 200
    WHERE  Field_label = 'Source Commodity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Book'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Source Book',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source Book'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 200
    WHERE  Field_label = 'Source Book'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'TRM SubBook'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'TRM SubBook',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_GetAllSourceBookMapping NULL, NULL, ''s'', NULL',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TRM SubBook'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
           sql_string = 'EXEC spa_GetAllSourceBookMapping NULL, NULL, ''s'', NULL'
    WHERE  Field_label = 'TRM SubBook'
END


IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Trayport Book Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Trayport Book Mapping', 4, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'Trayport Book Mapping'
	  , total_columns_used = 4
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Trayport Book Mapping'
END

DECLARE @trayport_book_mapping_table_id INT
	  , @trader_id INT
	  , @commodity_id INT
	  , @source_book INT
	  , @sub_book INT
	

SELECT @trayport_book_mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Trayport Book Mapping'

SELECT @trader_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Source Trader')

SELECT @commodity_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Source Commodity')

SELECT @source_book = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Source Book')

SELECT @sub_book = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'TRM SubBook')


IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @trayport_book_mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(mapping_table_id, clm1_label, clm1_udf_id, clm2_label,clm2_udf_id,clm3_label, clm3_udf_id, clm4_label,clm4_udf_id, unique_columns_index)
	SELECT @trayport_book_mapping_table_id, 'Source Trader', @trader_id, 'Source Commodity', @commodity_id,'Source Book',@source_book,'TRM SubBook',@sub_book, '1,2,3,4'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Source Trader'
	  , clm1_udf_id = @trader_id
	  , clm2_label = 'Source Commodity'
	  , clm2_udf_id = @commodity_id
	  , clm3_label ='Source Book'
	   ,clm3_udf_id =@source_book
	   , clm4_label ='TRM SubBook'
	   ,clm4_udf_id =@sub_book
	    , unique_columns_index = '1,2,3,4'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Trayport Book Mapping'
END


