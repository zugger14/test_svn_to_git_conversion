/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500), [description] VARCHAR (500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Pipeline')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -5677, 5500, 'Pipeline', 'Pipeline'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Pipeline'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Nomination Model')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	SELECT 5500, 'Nomination Model', 'Nomination Model'

	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Nomination Model'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Nomination Model'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Rounding Method')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	SELECT 5500, 'Rounding Method', 'Rounding Method'

	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Rounding Method'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Rounding Method'
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Pipeline'
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
           'Pipeline',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT sc.source_counterparty_id, sc.counterparty_name 
			FROM source_counterparty sc 
			inner join static_data_value sdv on sdv.value_id = sc.type_of_entity
				and sdv.type_id = 10020
			WHERE sdv.code IN (''Pipeline'')',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Pipeline'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT sc.source_counterparty_id, sc.counterparty_name 
			FROM source_counterparty sc 
			inner join static_data_value sdv on sdv.value_id = sc.type_of_entity
				and sdv.type_id = 10020
			WHERE sdv.code IN (''Pipeline'')'
    WHERE  Field_label = 'Pipeline'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Nomination Model'
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
           'Nomination Model',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''Pathed Threaded'' [value],''Pathed Threaded'' [label] UNION SELECT ''Pathed Non-Threaded'' [value],''Pathed Non-Threaded'' [label] UNION SELECT ''Non-Pathed'' [value],''Non-Pathed'' [label] ',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Nomination Model'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''Pathed Threaded'' [value],''Pathed Threaded'' [label] UNION SELECT ''Pathed Non-Threaded'' [value],''Pathed Non-Threaded'' [label] UNION SELECT ''Non-Pathed'' [value],''Non-Pathed'' [label] '
    WHERE  Field_label = 'Nomination Model'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Rounding Method'
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
           'Rounding Method',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value sdv WHERE sdv.[type_id] = 32400',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Rounding Method'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value sdv WHERE sdv.[type_id] = 32400'
    WHERE  Field_label = 'Rounding Method'
END

DECLARE @pipeline INT
DECLARE @nomination_model INT
DECLARE @rounding_method INT

SELECT @pipeline = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Pipeline'
SELECT @nomination_model = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Nomination Model'
SELECT @rounding_method = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Rounding Method'

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Pipeline Nomination Model')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Pipeline Nomination Model',
		total_columns_used = 3
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Pipeline Nomination Model'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Pipeline Nomination Model',
	3
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Pipeline Nomination Model')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Pipeline',
		clm1_udf_id = @pipeline,
		clm2_label = 'Nomination Model',
		clm2_udf_id = @nomination_model,
		clm3_label = 'Rounding Method',
		clm3_udf_id = @rounding_method
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Pipeline Nomination Model'
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
		'Nomination Model', @nomination_model,
		'Rounding Method', @rounding_method
	FROM generic_mapping_header 
	WHERE mapping_name = 'Pipeline Nomination Model'
END
