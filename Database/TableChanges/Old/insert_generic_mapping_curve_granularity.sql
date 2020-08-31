/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


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
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Index'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Granularity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Granularity', 'Granularity'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Granularity'
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Index'
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
           'Index',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT spcd.source_curve_def_id, spcd.curve_id FROM source_price_curve_def spcd',
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
    SET sql_string = 'SELECT spcd.source_curve_def_id, spcd.curve_id FROM source_price_curve_def spcd',
		is_required	= 'y'
    WHERE Field_label = 'Index'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Granularity'
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
           'Granularity',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE type_id = 978',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Granularity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string = 'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE type_id = 978',
		is_required	= 'y'
    WHERE  Field_label = 'Granularity'
END

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Curve Granularity')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Curve Granularity',
	2
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @index INT
DECLARE @granularity INT

SELECT @index = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Index'
SELECT @granularity = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Granularity'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Curve Granularity')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Index',
		clm1_udf_id = @index,
		clm2_label = 'Granularity',
		clm2_udf_id = @granularity
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Curve Granularity'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, 
		clm1_udf_id,
		clm2_label,
		clm2_udf_id
	)
	SELECT 
		mapping_table_id,
		'Index', 
		@index,
		'Granularity',
		@granularity
	FROM generic_mapping_header 
	WHERE mapping_name = 'Curve Granularity'
END