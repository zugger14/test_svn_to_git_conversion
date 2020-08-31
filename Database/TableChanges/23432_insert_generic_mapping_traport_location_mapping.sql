IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   

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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TRM Location')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'TRM Location', 'TRM Location'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TRM Location'
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
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Commodity'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TRM Counterparty')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'TRM Counterparty', 'TRM Counterparty'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TRM Counterparty'
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
           'NVARCHAR(150)',
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
       WHERE  Field_label = 'TRM Location'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'TRM Location',
           'd',
           'NVARCHAR(150)',
           'n',
           'EXEC spa_source_minor_location ''o''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TRM Location'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_source_minor_location ''o'''
    WHERE  Field_label = 'TRM Location'
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
           'NVARCHAR(150)',
           'n',
           'EXEC spa_source_commodity_maintain @flag = ''a''',
           'h',
           NULL,
           30,
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
       WHERE  Field_label = 'TRM Counterparty'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'TRM Counterparty',
           'd',
           'NVARCHAR(150)',
           'n',
           'EXEC spa_source_counterparty_maintain @flag = ''c'',  @not_int_ext_flag = ''b''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TRM Counterparty'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_source_counterparty_maintain @flag = ''c'',  @not_int_ext_flag = ''b'''
    WHERE  Field_label = 'TRM Counterparty'
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Trayport location Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Trayport location Mapping', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'Trayport location Mapping'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Trayport location Mapping'
END


DECLARE @trayport_mapping_table_id INT
	  , @trayport_source_instrument INT
	  , @trayport_trm_location INT
	  , @trayport_commodity INT
	  , @trayport_trm_counterparty INT
	  
SELECT @trayport_mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Trayport location Mapping'

SELECT @trayport_source_instrument = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Source Instrument')

SELECT @trayport_trm_location = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'TRM Location')

SELECT @trayport_commodity = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Commodity')

SELECT @trayport_trm_counterparty = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'TRM Counterparty')
	
----- needed for text
IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @trayport_mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(mapping_table_id, clm1_label, clm1_udf_id, clm2_label,clm2_udf_id
		, clm3_label,clm3_udf_id, clm4_label,clm4_udf_id, unique_columns_index)
	SELECT @trayport_mapping_table_id, 'Source Instrument', @trayport_source_instrument,'Commodity',@trayport_commodity,
		 'TRM Counterparty', @trayport_trm_counterparty, 'TRM Location', @trayport_trm_location, '1,2'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label	= 'Source Instrument'
	  , clm1_udf_id = @trayport_source_instrument
	  , clm2_label	= 'Commodity'
	  , clm2_udf_id = @trayport_commodity
	  , clm3_label	= 'TRM Counterparty'
	  , clm3_udf_id = @trayport_trm_counterparty
	  , clm4_label	= 'TRM Location'
	  , clm4_udf_id = @trayport_trm_location
	  , unique_columns_index = '1,2,3,4'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Trayport location Mapping'
END