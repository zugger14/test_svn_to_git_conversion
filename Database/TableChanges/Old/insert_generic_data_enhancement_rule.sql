/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
GO
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Meter ID')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-5713', '5500', 'Meter ID', 'Meter ID'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Meter ID'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Formula')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT -5697, 5500, 'Formula'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Formula'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'No Of Days')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT 5728, 5500, 'No Of Days'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'No Of Days'
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Meter ID'
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
           'Meter ID',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT meter_id id, [description] value FROM meter_id order by 2',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Meter ID'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'SELECT meter_id id, [description] value FROM meter_id order by 2'
    WHERE  Field_label = 'Meter ID'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Formula'
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
           'Formula',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT 1 Id,''Average last # of days'' Formula UNION SELECT 2 Id,''Copy last available data'' Formula ',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Formula'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'SELECT 1 Id,''Average last # of days'' Formula UNION SELECT 2 Id,''Copy last available data'' Formula '
    WHERE  Field_label = 'Formula'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'No Of Days'
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
           'No Of Days',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'No Of Days'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = ''
    WHERE  Field_label = 'No Of Days'
END


DECLARE @ean_id INT
DECLARE @formula_id INT
declare @no_of_days INT


SELECT @ean_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Meter ID'
SELECT @formula_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Formula'
SELECT @no_of_days = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'No Of Days'

/* end of part 2 */
-- Update previous Name
IF EXISTS (SELECT 1 FROM  generic_mapping_header gmh WHERE gmh.mapping_name = 'Accural Data')
BEGIN
	UPDATE generic_mapping_header
	SET
		mapping_name = 'Data Enhancement Rule' WHERE mapping_name = 'Accural Data'
END

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Data Enhancement Rule')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Data Enhancement Rule',
		total_columns_used = 3,
		system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Data Enhancement Rule'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Data Enhancement Rule',
	3
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Data Enhancement Rule')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Meter ID',
		clm1_udf_id = @ean_id,
		clm2_label = 'Formula',
		clm2_udf_id = @formula_id,
		clm3_label = 'No Of Days',
		clm3_udf_id = @no_of_days
		
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Data Enhancement Rule'
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
		'Meter ID', @ean_id,
		'Formula', @formula_id,
		'No Of Days', @no_of_days
		
		
	FROM generic_mapping_header 
	WHERE mapping_name = 'Data Enhancement Rule'
END

