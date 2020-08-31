IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Storage Location')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Storage Location', 'Storage Location'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Location'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Nomination Group Priority')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Nomination Group Priority', 'Nomination Group Priority'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Nomination Group Priority'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Effective Date')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Effective Date', 'Effective Date'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Effective Date'
END

IF NOT EXISTS (SELECT * FROM static_data_value WHERE [type_id] = 5500 AND code = 'Type')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Type', 'Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Type'
END

IF NOT EXISTS (SELECT * FROM static_data_value WHERE [type_id] = 5500 AND code = 'TSP')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'TSP', 'TSP'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TSP'
END


/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Storage Location'
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
           'Storage Location',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT smlo.source_minor_location_id, CASE WHEN smlo.Location_Name <> smlo.location_id THEN smlo.location_id + '' - '' + smlo.Location_Name ELSE smlo.Location_Name END + CASE WHEN sml.location_name IS NULL THEN '''' ELSE  '' ['' + sml.location_name + '']'' END  [name]	FROM source_minor_location smlo  LEFT JOIN source_major_location sml ON  smlo.source_major_location_ID = sml.source_major_location_ID WHERE sml.location_name = ''Storage''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Storage Location'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT smlo.source_minor_location_id, CASE WHEN smlo.Location_Name <> smlo.location_id THEN smlo.location_id + '' - '' + smlo.Location_Name ELSE smlo.Location_Name END + CASE WHEN sml.location_name IS NULL THEN '''' ELSE  '' ['' + sml.location_name + '']'' END  [name]	FROM source_minor_location smlo  LEFT JOIN source_major_location sml ON  smlo.source_major_location_ID = sml.source_major_location_ID WHERE sml.location_name = ''Storage'''
    WHERE  Field_label = 'Storage Location'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Nomination Group Priority'
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
           'Nomination Group Priority',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_StaticDataValues @flag=''h'', @type_id=32000',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Nomination Group Priority'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_StaticDataValues @flag=''h'', @type_id=32000'
    WHERE  Field_label = 'Nomination Group Priority'
END

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
           'n',
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
           'select ''''w'''' [value], ''Withdrawl'' [label] union all select ''i'', ''Injection''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'select ''w'' [value], ''Withdrawl'' [label] union all select ''i'', ''Injection'''
    WHERE  Field_label = 'Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'TSP'
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
           'TSP',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TSP'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't'
    WHERE  Field_label = 'TSP'
END


/* Insert Generic Mapping Header */
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Storage Rank')
BEGIN
	PRINT 'Mapping Table Already Exists'
	UPDATE generic_mapping_header
	SET total_columns_used = 5
	WHERE mapping_name = 'Storage Rank'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Storage Rank',
	5
	)
END

/*Insert into Generic Mapping Defination*/

DECLARE @location INT
DECLARE @nom_group_priority INT
DECLARE @effective_date INT
DECLARE @type INT
DECLARE @tsp INT

SELECT @location=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Storage Location'
SELECT @nom_group_priority=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Nomination Group Priority'
SELECT @effective_date=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Effective Date'
SELECT @type=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Type'
SELECT @tsp=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'TSP'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Storage Rank')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Effective Date',
		clm1_udf_id = @effective_date,
		clm2_label = 'Location',
		clm2_udf_id = @location,
		clm3_label = 'Type',
		clm3_udf_id = @type,
		clm4_label = 'Nomination Group Priority',
		clm4_udf_id = @nom_group_priority,
		clm5_label = 'TSP',
		clm5_udf_id = @tsp
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Storage Rank'
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
		'Location', @location,
		'Type', @type,		
		'Nomination Group Priority', @nom_group_priority ,
		'TSP', @tsp 
	FROM generic_mapping_header 
	WHERE mapping_name = 'Storage Rank'
END

