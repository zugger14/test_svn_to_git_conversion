IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Document')
BEGIN
	INSERT INTO static_data_value ([type_id],[value_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', '-10000367', 'Document', 'Document'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Document'
END
SET IDENTITY_INSERT static_data_value OFF   



/* Insert into user_defined_fields_template */
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Document'
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
           'Document',
           't',
           'NVARCHAR(MAX)',
           'n',
           NULL,
           'o',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Document'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL,
		   field_size = 180,
		   is_required = 'n'
    WHERE  Field_label = 'Document'
END

/* Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Document Usage')
BEGIN
	PRINT 'Mapping Table Already Exists'
	UPDATE generic_mapping_header
	SET total_columns_used = 1
	WHERE mapping_name = 'Document Usage'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Document Usage',
	1
	)

END

/*Insert into Generic Mapping Defination*/

DECLARE @document INT

SELECT @document = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Document'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Document Usage')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Document',
		clm1_udf_id = @document,
		unique_columns_index = '1',
		required_columns_index = '1'
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Document Usage'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		unique_columns_index,
		required_columns_index
	)
	SELECT 
		mapping_table_id,
		'Document', @document,
		 '1',
		'1'
	FROM generic_mapping_header 
	WHERE mapping_name = 'Document Usage'
END
