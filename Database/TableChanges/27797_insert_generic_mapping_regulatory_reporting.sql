/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Submission Type')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Submission Type', 'Submission Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Submission Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TR and RRM')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT 5500, 'TR and RRM', 'TR and RRM'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TR and RRM'
END
--/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Submission Type')
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
           'Submission Type',
           'd',
           'NVARCHAR(250)',
           'n',
           'EXEC spa_staticdataValues @type_id = 44700, @flag = ''h''',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Submission Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_staticdataValues @type_id = 44700, @flag = ''h''', Field_type ='d'
    WHERE  Field_label = 'Submission Type'
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'TR and RRM')
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
           'TR and RRM',
           'd',
           'NVARCHAR(250)',
           'n',
           'EXEC spa_staticdataValues @type_id = 116900, @flag = ''h''',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TR and RRM'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_staticdataValues @type_id = 116900, @flag = ''h''', Field_type ='d'
    WHERE  Field_label = 'TR and RRM'
END

/* end of part 2 */

DECLARE @submission_type INT
DECLARE @tr_rrm INT


SELECT @submission_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Submission Type'
SELECT @tr_rrm = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'TR and RRM'

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Regulatory Repository')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Regulatory Repository',
		total_columns_used = 2
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Regulatory Repository'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Regulatory Repository',
	2
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Regulatory Repository')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Submission Type',
		clm1_udf_id = @submission_type,
		clm2_label = 'TR and RRM',
		clm2_udf_id = @tr_rrm,
		unique_columns_index = 1
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Regulatory Repository'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		unique_columns_index
	)
	SELECT 
		mapping_table_id,
		'Submission Type', @submission_type,
		'TR and RRM', @tr_rrm,
		1
	FROM generic_mapping_header 
	WHERE mapping_name = 'Regulatory Repository'
END
