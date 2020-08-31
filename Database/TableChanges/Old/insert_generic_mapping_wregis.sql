IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Facility Name')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Facility Name', 'Facility Name'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Facility Name'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'WREGIS GU ID')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'WREGIS GU ID', 'WREGIS GU ID'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'WREGIS GU ID'
END

/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Facility Name'
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
           'Facility Name',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT code, name from rec_generator',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Facility Name'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT code, name from rec_generator'
    WHERE  Field_label = 'Facility Name'
END


/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'WREGIS GU ID'
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
           'WREGIS GU ID',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'WREGIS GU ID'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT code, name from rec_generator'
    WHERE  Field_label = 'Facility Name'
END

/* Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'WREGIS Facility Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
	UPDATE generic_mapping_header
	SET total_columns_used = 8
	WHERE mapping_name = 'WREGIS Facility Mapping'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used) 
	VALUES ('WREGIS Facility Mapping', 1)
END

/*Insert into Generic Mapping Defination*/

DECLARE @template INT

SELECT @template = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Facility Name'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'WREGIS Facility Mapping')
BEGIN
	UPDATE gmd
	SET    clm1_label      = 'Facility Name',
	       clm1_udf_id     = @template
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'WREGIS Facility Mapping'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (mapping_table_id, clm1_label, clm1_udf_id)
	SELECT mapping_table_id, 'Facility Name', @template
	FROM generic_mapping_header 
	WHERE mapping_name = 'WREGIS Facility Mapping'
END

SELECT @template = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'WREGIS GU ID'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'WREGIS Facility Mapping')
BEGIN
	UPDATE gmd
	SET    clm2_label      = 'WREGIS GU ID',
	       clm2_udf_id     = @template
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'WREGIS Facility Mapping'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (mapping_table_id, clm1_label, clm1_udf_id)
	SELECT mapping_table_id, 'WREGIS GU ID', @template
	FROM generic_mapping_header 
	WHERE mapping_name = 'WREGIS Facility Mapping'
END