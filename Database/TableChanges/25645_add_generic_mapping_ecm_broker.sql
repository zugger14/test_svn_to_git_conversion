IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Broker')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000352', '5500', 'Broker', 'Broker'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Broker'	AND TYPE_ID = 5500
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'ECM Broker')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000353', '5500', 'ECM Broker', 'ECM Broker'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'ECM Broker'	AND TYPE_ID = 5500
END           

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Broker'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Broker',
           'd',
           'int',
           'n',
           'EXEC spa_source_counterparty_maintain ''c'', @int_ext_flag=''b''',
           'o',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Broker'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_source_counterparty_maintain ''c'', @int_ext_flag=''b'''
    WHERE  Field_label = 'Broker'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'ECM Broker'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'ECM Broker',
           't',
           'NVARCHAR(MAX)',
           'n',
           NULL,
           'o',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'ECM Broker'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL,
		   data_type = 'NVARCHAR(MAX)'
    WHERE  Field_label = 'ECM Broker'
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'ECM Broker')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('ECM Broker', 2, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'ECM Broker'
	  , total_columns_used = 2
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'ECM Broker'
END

DECLARE @broker_id INT
	  , @ecm_broker INT
	  , @mapping_table_id INT
	
SELECT @broker_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Broker')

SELECT @ecm_broker = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'ECM Broker')

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'ECM Broker'
----- needed for text
IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(mapping_table_id, clm1_label, clm1_udf_id, clm2_label,clm2_udf_id, unique_columns_index,required_columns_index)
	SELECT @mapping_table_id, 'Broker', @broker_id, 'ECM Broker', @ecm_broker,  '1,2' ,  '1,2'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Broker'
	  , clm1_udf_id = @broker_id
	  , clm2_label = 'ECM Broker'
	  , clm2_udf_id = @ecm_broker
	  , unique_columns_index = '1,2'
	  , required_columns_index	 = '1,2'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'ECM Broker'
END