/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Projection Index Group')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Projection Index Group', 'Projection Index Group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Commodity KID'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Commodity KID')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Commodity KID', 'Commodity KID'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Commodity KID'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Type of Product')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Type of Product', 'Type of Product'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Type of Product'
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Projection Index Group'
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
           'Projection Index Group',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 53',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Projection Index Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 53'
    WHERE  Field_label = 'Projection Index Group'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Commodity KID'
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
           'Commodity KID',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Commodity KID'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = '',
		   Field_type = 't'	
    WHERE  Field_label = 'Commodity KID'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Type of Product'
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
           'Type of Product',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Type of Product'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'Type of Product'
END
/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'KID-Projection Index Group')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'KID-Projection Index Group',
	3
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @projection_index_group INT
DECLARE @commodity_kid INT
DECLARE @type_of_product INT

SELECT @projection_index_group = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Projection Index Group'
SELECT @commodity_kid = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Commodity KID'
SELECT @type_of_product = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Type of Product'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'KID-Projection Index Group')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Projection Index Group',
		clm1_udf_id = @projection_index_group,
		clm2_label = 'Commodity KID',
		clm2_udf_id = @commodity_kid,
		clm3_label = 'Type of Product',
		clm3_udf_id = @type_of_product
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'KID-Projection Index Group'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, 
		clm1_udf_id,
		clm2_label,
		clm2_udf_id,
		clm3_label,
		clm3_udf_id
	)
	SELECT 
		mapping_table_id,
		'Projection Index Group', 
		@projection_index_group,
		'Commodity KID',
		@commodity_kid,
		'Type of Product',
		@type_of_product
	FROM generic_mapping_header 
	WHERE mapping_name = 'KID-Projection Index Group'
END