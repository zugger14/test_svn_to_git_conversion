/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
GO
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Sub Book')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -5674, 5500, 'Sub Book', 'Sub Book'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Sub Book'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Location')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -5690, 5500, 'Location', 'Location'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Location'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Type')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -5691, 5500, 'Type', 'Type'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Type'
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
           'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc WHERE sc.type_of_entity = 301994',
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
    SET    sql_string = 'SELECT sc.source_counterparty_id, sc.counterparty_name FROM source_counterparty sc WHERE sc.type_of_entity = 301994'
    WHERE  Field_label = 'Pipeline'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Sub Book'
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
           'Sub Book',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_GetAllSourceBookMapping NULL, NULL, ''s'', NULL',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Sub Book'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'EXEC spa_GetAllSourceBookMapping NULL, NULL, ''s'', NULL'
    WHERE  Field_label = 'Sub Book'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Location'
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
           'Location',
           'd',
           'VARCHAR(150)',
           'n',
           'select m.source_minor_location_id, m.Location_Name from source_minor_location m 
inner join source_major_location mj on mj.source_major_location_ID = m.source_major_location_ID
where mj.location_name = ''Storage''',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Location'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'select m.source_minor_location_id, m.Location_Name from source_minor_location m 
inner join source_major_location mj on mj.source_major_location_ID = m.source_major_location_ID
where mj.location_name = ''Storage'''
    WHERE  Field_label = 'Location'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Type'
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
           'Type',
           'd',
           'VARCHAR(150)',
           'n',
           'select ''w'' [value], ''Withdrawl'' [label] union all select ''i'', ''Injection''',
           'h',
           NULL,
           400,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 400,
		sql_string = 'select ''w'' [value], ''Withdrawl'' [label] union all select ''i'', ''Injection'''
    WHERE  Field_label = 'Type'
END

DECLARE @pipeline INT
DECLARE @subbook INT
DECLARE @location INT
DECLARE @type INT

SELECT @pipeline = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Pipeline'
SELECT @subbook = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sub Book'
SELECT @location = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Location'
SELECT @type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Type'

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Storage Book Mapping')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Storage Book Mapping',
		total_columns_used = 4
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Storage Book Mapping'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Storage Book Mapping',
	4
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Storage Book Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Location',
		clm1_udf_id = @location,
		clm2_label = 'Type',
		clm2_udf_id = @type,
		clm3_label = 'Pipeline',
		clm3_udf_id = @pipeline,
		clm4_label = 'Sub Book',
		clm4_udf_id = @subbook
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Storage Book Mapping'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id
	)
	SELECT 
		mapping_table_id,
		'Location', @location,
		'Type', @type,
		'Pipeline', @pipeline,
		'Sub Book', @subbook
		
	FROM generic_mapping_header 
	WHERE mapping_name = 'Storage Book Mapping'
END
