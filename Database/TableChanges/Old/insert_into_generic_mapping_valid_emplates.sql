IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Template')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Template', 'Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Template'
END

/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Template'
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
           'Template',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT template_id, template_name FROM source_deal_header_template',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT template_id, template_name FROM source_deal_header_template'
    WHERE  Field_label = 'Template'
END

/* Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Valid Templates')
BEGIN
	PRINT 'Mapping Table Already Exists'
	UPDATE generic_mapping_header
	SET total_columns_used = 8
	WHERE mapping_name = 'Valid Templates'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used) 
	VALUES ('Valid Templates', 1)
END

/*Insert into Generic Mapping Defination*/

DECLARE @template INT

SELECT @template = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Template'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Valid Templates')
BEGIN
	UPDATE gmd
	SET    clm1_label      = 'Template',
	       clm1_udf_id     = @template
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Valid Templates'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (mapping_table_id, clm1_label, clm1_udf_id)
	SELECT mapping_table_id, 'Template', @template
	FROM generic_mapping_header 
	WHERE mapping_name = 'Valid Templates'
END