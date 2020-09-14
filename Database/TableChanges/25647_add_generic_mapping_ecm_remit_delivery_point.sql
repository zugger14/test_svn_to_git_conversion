IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Location Group')
BEGIN
	INSERT INTO static_data_value ([type_id],[value_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', '-10000347', 'Location Group', 'Location Group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Location Group'
END
SET IDENTITY_INSERT static_data_value OFF   

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
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source Commodity'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Delivery Point')
BEGIN
	INSERT INTO static_data_value ([type_id],[value_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', '-5722', 'Delivery Point', 'Delivery Point'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Delivery Point'
END
SET IDENTITY_INSERT static_data_value OFF  

/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Location Group'
   )
BEGIN
	INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Location Group',
           'd',
           'int',
           'n',
           'EXEC spa_source_minor_location ''o''',
           'o',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Location Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_source_minor_location ''o''',
		   field_size = 180,
		   is_required = 'n'
    WHERE  Field_label = 'Location Group'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Commodity'
   )
BEGIN
	INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'HUB',
           'd',
           'int',
           'n',
           'EXEC spa_source_commodity_maintain ''a''',
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
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_source_commodity_maintain ''a''',
		   field_size = 200,
		   is_required = 'n'
    WHERE  Field_label = 'Source Commodity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Delivery Point'
   )
BEGIN
	INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Delivery Point',
           't',
           'NVARCHAR(MAX)',
           'n',
           NULL,
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Delivery Point'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL,
		   field_size = 180,
		   is_required = 'n'
    WHERE  Field_label = 'Delivery Point'
END

/* Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'ECM /Remit Delivery Point')
BEGIN
	PRINT 'Mapping Table Already Exists'
	UPDATE generic_mapping_header
	SET total_columns_used = 3
	WHERE mapping_name = 'ECM /Remit Delivery Point'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'ECM /Remit Delivery Point',
	3
	)

END

/*Insert into Generic Mapping Defination*/

DECLARE @location_group INT
DECLARE @source_commodity INT
DECLARE @delivery_point INT

SELECT @location_group = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Location Group'
SELECT @source_commodity = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Source Commodity'
SELECT @delivery_point = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Delivery Point'


IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'ECM /Remit Delivery Point')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Location Group',
		clm1_udf_id = @location_group,
		clm2_label = 'Source Commodity',
		clm2_udf_id = @source_commodity,
		clm3_label = 'Delivery Point',
		clm3_udf_id = @delivery_point,
		unique_columns_index = '1,2,3',
		required_columns_index = '1,2,3'
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'ECM /Remit Delivery Point'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		unique_columns_index,
		required_columns_index
	)
	SELECT 
		mapping_table_id,
		'Location Group', @location_group,
		'Source Commodity', @source_commodity,
		'Delivery Point', @delivery_point,
		 '1,2,3',
		'1,2,3'
	FROM generic_mapping_header 
	WHERE mapping_name = 'ECM /Remit Delivery Point'
END
