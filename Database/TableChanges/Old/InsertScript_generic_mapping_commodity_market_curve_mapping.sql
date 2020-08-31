IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Location')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Location', 'Location'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Location'
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Index')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Index', 'Index'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Index'
END

IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Location'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Location',
           'd',
           'VARCHAR(150)',
           'n',
           'select source_minor_location_id, Location_Name from source_minor_location',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Location'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'select source_minor_location_id, Location_Name from source_minor_location'
    WHERE  Field_label = 'Location'
END

IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Commodity'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Commodity',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_source_commodity_maintain ''a''',
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
		   sql_string = 'EXEC spa_source_commodity_maintain ''a'''
    WHERE  Field_label = 'Commodity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Index'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Index',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_GetAllPriceCurveDefinitions @flag=''a'', @is_active=''y''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Index'
END
ELSE
BEGIN
     UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_GetAllPriceCurveDefinitions @flag=''a'', @is_active=''y'''
    WHERE  Field_label = 'Index'
END

DECLARE @location_id INT
DECLARE @commodity_id INT
DECLARE @index INT

SELECT @location_id = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Location'

SELECT @commodity_id = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Commodity'

SELECT @index = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Index'


IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Commodity Market Curve Mapping')
BEGIN
	DECLARE @new_table_id INT
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used) VALUES ('Commodity Market Curve Mapping', 3)
	
	SET @new_table_id = SCOPE_IDENTITY()
	
	INSERT INTO generic_mapping_definition (mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, clm3_label, clm3_udf_id)
	SELECT @new_table_id, 'Location', @location_id, 'Commodity', @commodity_id, 'Index', @index
END   