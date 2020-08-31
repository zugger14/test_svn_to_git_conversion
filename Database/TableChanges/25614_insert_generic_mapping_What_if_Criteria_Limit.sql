IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'What if Criteria')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'What if Criteria', 'What if Criteria'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'What if Criteria'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Limit for Delta MTM')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Limit for Delta MTM', 'Limit for Delta MTM'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Limit for Delta MTM'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Limit for Shift MTM')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Limit for Shift MTM', 'Limit for Shift MTM'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Limit for Shift MTM'
END

--Step 2: 
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'What if Criteria'
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
           'What if Criteria',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT criteria_id AS id, criteria_name AS value FROM maintain_whatif_criteria',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'What if Criteria'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT criteria_id AS id, criteria_name AS value FROM maintain_whatif_criteria'
    WHERE  Field_label = 'What if Criteria'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Limit for Delta MTM'
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
           'Limit for Delta MTM',
           't',
           'INT',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Limit for Delta MTM'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = ''
    WHERE  Field_label = 'Limit for Delta MTM'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Limit for Shift MTM'
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
           'Limit for Shift MTM',
           't',
           'INT',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Limit for Shift MTM'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = ''
    WHERE  Field_label = 'Limit for Shift MTM'
END


IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'What if Criteria Limit')
BEGIN
	PRINT 'What if Criteria Limit already exists.'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'What if Criteria Limit',
	3
	)
END

DECLARE @id INT 
SELECT @id  = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'What if Criteria Limit'
DELETE FROM generic_mapping_definition WHERE mapping_table_id = @id

/*Insert into Generic Mapping Defination*/
DECLARE @what_if_criteria INT
,@limit_for_delta_mtm INT
,@limit_for_shift_mtm INT

SELECT @what_if_criteria = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'What if Criteria'
SELECT @limit_for_delta_mtm = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Limit for Delta MTM'
SELECT @limit_for_shift_mtm = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Limit for Shift MTM'

IF EXISTS (
	SELECT 1 FROM generic_mapping_definition gmd 
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id 
	WHERE gmh.mapping_name = 'What if Criteria limit'
)
BEGIN
	UPDATE gmd
	SET 
		clm1_label= 'What if Criteria',
		clm1_udf_id = @what_if_criteria,
		clm2_label = 'Limit for Delta MTM', 
		clm2_udf_id = @limit_for_delta_mtm  ,
		clm3_label = 'Limit for Shift MTM',
		clm3_udf_id = @limit_for_shift_mtm
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name =  'What if Criteria limit'
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
		'What if Criteria', @what_if_criteria,
		'Limit for Delta MTM', @limit_for_delta_mtm,
		'Limit for Shift MTM', @limit_for_shift_mtm
	FROM generic_mapping_header 
	WHERE mapping_name =  'What if Criteria limit'
END
