IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Broker')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Source Broker', 'Source Broker'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source Broker'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TRM Broker')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'TRM Broker', 'TRM Broker'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TRM Broker'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Broker'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Source Broker',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source Broker'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 200
    WHERE  Field_label = 'Source Broker'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'TRM Broker'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'TRM Broker',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_contract_group @flag = ''r'', @contract_name = ''broker''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TRM Broker'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_contract_group @flag = ''r'', @contract_name = ''broker'''
    WHERE  Field_label = 'TRM Broker'
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Trayport Broker Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Trayport Broker Mapping', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'Trayport Broker Mapping'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Trayport Broker Mapping'
END

DECLARE @trayport_mapping_table_id INT
	  , @trayport_source_Broker INT
	  , @trayport_trm_Broker INT
	

SELECT @trayport_mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Trayport Broker Mapping'

SELECT @trayport_trm_Broker = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'TRM Broker')

SELECT @trayport_source_Broker = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Source Broker')


----- needed for text
IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @trayport_mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(mapping_table_id, clm1_label, clm1_udf_id, clm2_label,clm2_udf_id, unique_columns_index)
	SELECT @trayport_mapping_table_id, 'Source Broker', @trayport_source_Broker, 'TRM Broker', @trayport_trm_Broker, '1,2'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Source Broker'
	  , clm1_udf_id = @trayport_source_Broker
	  , clm2_label = 'TRM Broker'
	  , clm2_udf_id = @trayport_trm_Broker
	   , unique_columns_index = '1,2'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Trayport Broker Mapping'
END


