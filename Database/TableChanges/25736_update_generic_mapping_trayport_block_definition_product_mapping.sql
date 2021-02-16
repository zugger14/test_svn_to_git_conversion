IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   



IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Term Code')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Term Code', 'Term Code'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Term Code'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Instrument')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Source Instrument', 'Source Instrument'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source Instrument'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'DealTimeHour')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'DealTimeHour', 'DealTimeHour'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'DealTimeHour'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Block Definitions')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Block Definitions', 'Block Definitions'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Block Definitions'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'IS DST')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'IS DST', 'IS DST'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'IS DST'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Gas Day')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Gas Day', 'Gas Day'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Gas Day'
END

        

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Term Code'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Term Code',
           't',
           'NVARCHAR(250)',
           'y',
           '',
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Term Code'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 120
    WHERE  Field_label = 'Term Code'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Instrument'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Source Instrument',
           't',
           'NVARCHAR(250)',
           'n',
           '',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source Instrument'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 200
    WHERE  Field_label = 'Source Instrument'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'DealTimeHour'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'DealTimeHour',
           't',
           'NVARCHAR(250)',
           'y',
           '',
           'h',
           NULL,
           60,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'DealTimeHour'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 60
    WHERE  Field_label = 'DealTimeHour'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Block Definitions'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Block Definitions',
           'd',
           'NVARCHAR(250)',
           'y',
           'SELECT value_id, code FROM static_data_value WHERE TYPE_ID = 10018',
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Block Definitions'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
           field_size = 120,
		   sql_string = 'SELECT value_id, code FROM static_data_value WHERE TYPE_ID = 10018'
    WHERE  Field_label = 'Block Definitions'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'IS DST'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'IS DST',
           'd',
           'NVARCHAR(250)',
           'y',
           'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No''',
           'h',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'IS DST'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
           field_size = 120,
		   sql_string = 'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No'''
    WHERE  Field_label = 'IS DST'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Gas Day'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Gas Day',
           'd',
           'NVARCHAR(250)',
           'n',
           'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No''',
           'o',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Gas Day'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
           field_size = 120,
		   sql_string = 'SELECT ''y'' AS id , ''Yes'' VALUE UNION ALL SELECT ''n'', ''No'''
    WHERE  Field_label = 'Gas Day'
END



IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Trayport Block Definition Product Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Trayport Block Definition Product Mapping', 6, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'Trayport Block Definition Product Mapping'
	  , total_columns_used = 6
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Trayport Block Definition Product Mapping'
END


DECLARE @trayport_mapping_table_id INT
	  , @term_code INT
	  , @source_instrument INT
	  , @dealtimehour INT
	  , @block_definitions INT
	  , @is_dst INT
	  , @gas_day INT
	

SELECT @trayport_mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Trayport Block Definition Product Mapping'

SELECT @term_code = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Term Code'

SELECT @source_instrument = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Source Instrument'

SELECT @dealtimehour = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'DealTimeHour'

SELECT @block_definitions = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Block Definitions'

SELECT @is_dst = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'IS DST'

SELECT @gas_day = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Gas Day'

----- needed for text
IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @trayport_mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(mapping_table_id, clm1_label, clm1_udf_id, clm2_label,clm2_udf_id, clm3_label,clm3_udf_id,clm4_label,clm4_udf_id,clm5_label,clm5_udf_id, clm6_label,clm6_udf_id,unique_columns_index)
	SELECT @trayport_mapping_table_id, 'Term Code', @term_code, 'Source Instrument', @source_instrument,'DealTimeHour',@dealtimehour,'Block Definitions', @block_definitions, 'IS DST',@is_dst, 'Gas Day', @gas_day,  NULL
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Term Code'
	  , clm1_udf_id = @term_code
	  , clm2_label = 'Source Instrument'
	  , clm2_udf_id = @source_instrument
	  ,clm3_label = 'DealTimeHour'
	 , clm3_udf_id = @dealtimehour
	  ,clm4_label = 'Block Definitions'
	 , clm4_udf_id = @block_definitions
	 ,clm5_label = 'IS DST'
	 , clm5_udf_id = @is_dst
	 ,clm6_label = 'Gas Day'
	 , clm6_udf_id = @gas_day
	 , unique_columns_index = NULL
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Trayport Block Definition Product Mapping'
END