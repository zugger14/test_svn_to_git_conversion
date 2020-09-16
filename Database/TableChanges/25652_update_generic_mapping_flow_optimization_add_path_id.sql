/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
GO
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Delivery Path')
BEGIN
	--SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Delivery Path', 'Delivery Path'
	--SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Delivery Path'	AND TYPE_ID = 5500
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Delivery Path'
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
           'Delivery Path',
           'd',
           'VARCHAR(150)',
           'y',
           'EXEC spa_delivery_path ''w''',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Delivery Path'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_delivery_path ''w'''
    WHERE  Field_label = 'Delivery Path'
END

DECLARE @delivery_path INT, @pipeline INT, @sub_book INT

SELECT @delivery_path = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Delivery Path'
SELECT @pipeline = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Pipeline'
SELECT @sub_book = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sub Book'

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Flow Optimization Mapping')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Flow Optimization Mapping',
		total_columns_used = 3,
		system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Flow Optimization Mapping'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Flow Optimization Mapping',
	3
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Flow Optimization Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm3_label = 'Delivery Path',
		clm3_udf_id = @delivery_path
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Flow Optimization Mapping'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id
	)
	SELECT 
		mapping_table_id,
		'Pipeline', @pipeline,
		'Sub Book', @sub_book,
		'Delivery Path', @delivery_path
		
	FROM generic_mapping_header 
	WHERE mapping_name = 'Flow Optimization Mapping'
END

