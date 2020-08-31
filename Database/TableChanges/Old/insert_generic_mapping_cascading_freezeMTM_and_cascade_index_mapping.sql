

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


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Cascade Date')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Cascade Date', 'Cascade Date'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Cascade Date'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Pre Cascade Index')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Pre Cascade Index', 'Pre Cascade Index'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Pre Cascade Index'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Post Cascade Index')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Post Cascade Index', 'Post Cascade Index'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Post Cascade Index'
END

--Step 2
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
           'n',
           'SELECT source_curve_def_id, curve_name FROM source_price_curve_def',
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
    SET    sql_string = 'SELECT source_curve_def_id, curve_name FROM source_price_curve_def'
    WHERE  Field_label = 'Index'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Cascade Date'
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
           'Cascade Date',
           'a',
           'datetime',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Cascade Date'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'Cascade Date'
END




IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Pre Cascade Index'
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
           'Pre Cascade Index',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_curve_def_id, curve_name FROM source_price_curve_def',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Pre Cascade Index'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_curve_def_id, curve_name FROM source_price_curve_def'
    WHERE  Field_label = 'Pre Cascade Index'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Post Cascade Index'
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
           'Post Cascade Index',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_curve_def_id, curve_name FROM source_price_curve_def',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Post Cascade Index'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_curve_def_id, curve_name FROM source_price_curve_def'
    WHERE  Field_label = 'Post Cascade Index'
END

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Cascading')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Cascading',
	2
	)
END


IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Freeze MTM')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Freeze MTM',
	1
	)
END

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Cascade Index Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Cascade Index Mapping',
	2
	)
END

/* step 4: Insert into Generic Mapping Defination*/


DECLARE @index_id INT
DECLARE @cascade_date_id INT

SELECT @index_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Index'
SELECT @cascade_date_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Cascade Date'



IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Cascading')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Index',
		clm1_udf_id = @index_id,
		clm2_label = 'Cascade Date',
		clm2_udf_id = @cascade_date_id
		
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Cascading'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id
	)
	SELECT 
		mapping_table_id,
		'Index', @index_id,
		'Cascade Date', @cascade_date_id
		
	FROM generic_mapping_header 
	WHERE mapping_name = 'Cascading'
END

DECLARE @index_id2 INT

SELECT @index_id2 =udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Index'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Freeze MTM')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Index',
		clm1_udf_id = @index_id2
		
		
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Freeze MTM'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id
	)
	SELECT 
		mapping_table_id,
		'Index', @index_id2
		
	FROM generic_mapping_header 
	WHERE mapping_name = 'Freeze MTM'
END

DECLARE @mapping_id INT

SELECT @mapping_id = mapping_table_id FROM generic_mapping_header 
WHERE mapping_name = 'Freeze MTM'

UPDATE generic_mapping_header
SET total_columns_used = 2
WHERE mapping_table_id = @mapping_id

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Freeze MTM')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Freeze MTM', 'Freeze MTM'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Freeze MTM'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Freeze MTM'
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
           'Freeze MTM',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''y'' AS [Id], ''Yes'' AS [Code] UNION ALL SELECT ''n'' AS [Id], ''No'' AS [Code] ',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Freeze MTM'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''y'' AS [Id], ''Yes'' AS [Code] UNION ALL SELECT ''n'' AS [Id], ''No'' AS [Code] '
    WHERE  Field_label = 'Freeze MTM'

END

DECLARE @yes_no INT

SELECT @yes_no = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Freeze MTM'

--SELECT *  
UPDATE gmd
	SET clm2_label = 'Freeze MTM',
		clm2_udf_id = @yes_no
FROM generic_mapping_definition gmd
WHERE gmd.mapping_table_id = @mapping_id


--------------------------------------------------------------end Freeze MTM

DECLARE @pre_cascade_index_id INT
DECLARE @post_cascade_index_id INT

SELECT @pre_cascade_index_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Pre Cascade Index'
SELECT @post_cascade_index_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Post Cascade Index'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Cascade Index Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Pre Cascade Index',
		clm1_udf_id = @pre_cascade_index_id,
		clm2_label = 'Post Cascade Index',
		clm2_udf_id = @post_cascade_index_id
		
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Cascade Index Mapping'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id
	)
	SELECT 
		mapping_table_id,
		'Pre Cascade Index', @pre_cascade_index_id,
		'Post Cascade Index', @post_cascade_index_id
		
	FROM generic_mapping_header 
	WHERE mapping_name = 'Cascade Index Mapping'
END