IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   

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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Start Hour')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Start Hour', 'Start Hour'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Start Hour'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'End Hour')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'End Hour', 'End Hour'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'End Hour'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Business Day')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Business Day', 'Business Day'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Business Day'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Is Interval')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Is Interval', 'Is Interval'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Is Interval'
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
       WHERE  Field_label = 'Start Hour'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Start Hour',
           't',
           'NVARCHAR(250)',
           'n',
           '',
           'o',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Start Hour'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 120,
		   udf_type = 'o'
    WHERE  Field_label = 'Start Hour'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'End Hour'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'End Hour',
           't',
           'NVARCHAR(250)',
           'n',
           '',
           'o',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'End Hour'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 200,
		   udf_type = 'o'
    WHERE  Field_label = 'End Hour'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Business Day'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Business Day',
           'd',
           'NVARCHAR(250)',
           'n',
           'SELECT ''n'' value, ''No'' label UNION SELECT ''y'' value, ''Yes'' label',
           'o',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Business Day'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
           field_size = 120,
		   sql_string = 'SELECT ''n'' value, ''No'' label UNION SELECT ''y'' value, ''Yes'' label'
    WHERE  Field_label = 'Business Day'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Is Interval'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Is Interval',
           'd',
           'NVARCHAR(250)',
           'n',
           'SELECT ''n'' value, ''No'' label UNION SELECT ''y'' value, ''Yes'' label',
           'o',
           NULL,
           120,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Is Interval'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
           field_size = 120,
		   sql_string = 'SELECT ''n'' value, ''No'' label UNION SELECT ''y'' value, ''Yes'' label'
    WHERE  Field_label = 'Is Interval'
END


IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'ECM Time Interval')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('ECM Time Interval', 5, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ECM Time Interval'
	  , total_columns_used = 5
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ECM Time Interval'
END


DECLARE @trayport_mapping_table_id INT
	  , @start_hour INT
	  , @end_hour INT
	  , @block_definitions INT
	  , @business_day INT
	  , @is_interval INT

	

SELECT @trayport_mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ECM Time Interval'

SELECT @block_definitions = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Block Definitions'

SELECT @start_hour = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Start Hour'

SELECT @end_hour = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'End Hour'

SELECT @business_day = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Business Day'

SELECT @is_interval = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Is Interval'


----- needed for text
IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @trayport_mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(mapping_table_id, clm1_label, clm1_udf_id, clm2_label,clm2_udf_id, clm3_label,clm3_udf_id, clm4_label,clm4_udf_id, clm5_label,clm5_udf_id,unique_columns_index)
	SELECT @trayport_mapping_table_id,'Block Definitions', @block_definitions, 'Start Hour', @start_hour, 'End Hour', @end_hour, 'Business Day', @business_day,'Is Interval',@is_interval, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Block Definitions'
	  , clm1_udf_id = @block_definitions
	  , clm2_label = 'Start Hour'
	  , clm2_udf_id = @start_hour
	  , clm3_label = 'End Hour'
	  , clm3_udf_id = @end_hour
	  , clm4_label = 'Business Day'
	  , clm4_udf_id = @business_day
	  , clm5_label = 'Is Interval'
	  , clm5_udf_id = @is_interval
	 , unique_columns_index = '1'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ECM Time Interval'
END