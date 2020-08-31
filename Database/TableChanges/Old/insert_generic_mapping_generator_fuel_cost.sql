/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
GO
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Effective Date')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-5698', '5500', 'Effective Date'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Effective Date'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Generator')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-5699', '5500', 'Generator'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external 
	SELECT value_id, [type_id], code 
	FROM static_data_value SDV WHERE [code] = 'Generator' AND [type_id] = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Fuel')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-5700', 5500, 'Fuel'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Fuel'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Curve')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-5701', 5500, 'Curve'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Curve'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Heat Rate')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-5702', 5500, 'Heat Rate'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Heat Rate'
END
/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Effective Date'
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
           'Effective Date',
           'a',
           'DATETIME',
           'y',
           NULL,
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Effective Date'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'a'
    WHERE  Field_label = 'Effective Date'
END
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Generator'
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
           'Generator',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT sml.source_minor_location_id, sml.location_name FROM source_minor_location  sml LEFT JOIN source_major_location smjl ON sml.source_major_location_ID = smjl.source_major_location_ID WHERE smjl.location_name = ''Generator''',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Generator'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sml.source_minor_location_id, sml.location_name FROM source_minor_location  sml LEFT JOIN source_major_location smjl ON sml.source_major_location_ID = smjl.source_major_location_ID WHERE smjl.location_name = ''Generator'''
    WHERE  Field_label = 'Generator'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Fuel'
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
           'Fuel',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT value_id, code FROM static_data_value WHERE type_id = 10023',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Fuel'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value WHERE type_id = 10023', field_size = 180
    WHERE  Field_label = 'Fuel'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Curve'
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
           'Curve',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT source_curve_def_id, curve_name FROM source_price_curve_def',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Curve'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_curve_def_id, curve_name FROM source_price_curve_def', field_size = 180
    WHERE  Field_label = 'Curve'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Heat Rate'
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
           'Heat Rate',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           300,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Heat Rate'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = '', field_size = 300
    WHERE  Field_label = 'Heat Rate'
END

DECLARE @effective_date INT
DECLARE @generator INT
DECLARE @fuel INT
DECLARE @curve INT
DECLARE @heat_rate INT

SELECT @effective_date = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Effective Date'
SELECT @generator = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Generator'
SELECT @fuel = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Fuel'
SELECT @curve = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Curve'
SELECT @heat_rate = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Heat Rate'

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Generator Fuel Cost')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Generator Fuel Cost',
		total_columns_used = 5,
		system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Generator Fuel Cost'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Generator Fuel Cost',
	5
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Generator Fuel Cost')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Effective Date',
		clm1_udf_id = @effective_date,
		clm2_label = 'Generator',
		clm2_udf_id = @generator,
		clm3_label = 'Fuel',
		clm3_udf_id = @fuel,
		clm4_label = 'Curve',
		clm4_udf_id = @curve,
		clm5_label = 'Heat Rate',
		clm5_udf_id = @heat_rate
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Generator Fuel Cost'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id,
		clm5_label, clm5_udf_id
	)
	SELECT 
		mapping_table_id,
		'Effective Date', @effective_date,
		'Generator', @generator,
		'Fuel', @fuel,
		'Curve', @curve,
		'Heat Rate', @heat_rate
		
	FROM generic_mapping_header 
	WHERE mapping_name = 'Generator Fuel Cost'
END

