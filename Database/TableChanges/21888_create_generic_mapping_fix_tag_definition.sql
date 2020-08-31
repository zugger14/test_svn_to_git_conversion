/***********************************
Step 1: Insert into static_data_value
************************************/
--	static data values already prepared 

/************************************************
Step 2: Insert into user_defined_fields_template
************************************************/

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE field_id = 110300)
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
        SEQUENCE,
        field_size,
        field_id
      )
    SELECT sdv.value_id,
           'Tag Id',
           't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           sdv.value_id
    FROM static_data_value sdv
    WHERE  sdv.value_id = 110300
END

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE field_id = 110301)
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
        SEQUENCE,
        field_size,
        field_id
      )
    SELECT sdv.value_id,
           'Field Name',
           't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           sdv.value_id
    FROM static_data_value sdv
    WHERE  sdv.value_id = 110301
END

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE field_id = 110302)
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
        SEQUENCE,
        field_size,
        field_id
      )
    SELECT sdv.value_id,
           'Conditional Value',
           't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           sdv.value_id
    FROM static_data_value sdv
    WHERE  sdv.value_id = 110302
END

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE field_id = 110303)
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
        SEQUENCE,
        field_size,
        field_id
      )
    SELECT sdv.value_id,
           'Table Field Name',
           't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           sdv.value_id
    FROM static_data_value sdv
    WHERE  sdv.value_id = 110303
END



IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE  field_id = 110304)
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
        SEQUENCE,
        field_size,
        field_id
      )
    SELECT sdv.value_id,
           'Tag type',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT [id], [value] FROM (SELECT 1 [id], ''Trade Capture Report'' [Value] UNION SELECT 2 [id], ''Sides'' [Value] UNION SELECT 3 [id], ''Party Id'' [Value] UNION SELECT 4 [id], ''Legs Group'' [Value] UNION SELECT 5 [id], ''Nested Party Id'' [Value] UNION SELECT 6 [id], ''Nested Party Role'' [Value] UNION SELECT 7 [id], ''Trayport Trades'' [Value]) tbl ORDER BY 1',
           'h',
           NULL,
           30,
           sdv.value_id
    FROM static_data_value sdv
    WHERE  sdv.value_id = 110304
END

/*****************************************
Step 3: Insert into generic_mapping_header
******************************************/
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'XConnect Tag Definition')
BEGIN
	UPDATE generic_mapping_header
	SET total_columns_used = 5
	WHERE mapping_name = 'XConnect Tag Definition'
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'XConnect Tag Definition',
	5
	)
END


/*********************************************
Step 4: Insert into generic_mapping_definition
**********************************************/
DECLARE @tag_id INT
DECLARE @field_name INT
DECLARE @conditional_value INT
DECLARE @table_field_name INT
DECLARE @tag_type INT

SELECT @tag_id = udf_template_id FROM user_defined_fields_template WHERE field_id = 110300
SELECT @field_name = udf_template_id FROM user_defined_fields_template WHERE field_id = 110301
SELECT @conditional_value = udf_template_id FROM user_defined_fields_template WHERE field_id = 110302
SELECT @table_field_name = udf_template_id FROM user_defined_fields_template WHERE field_id = 110303
SELECT @tag_type = udf_template_id FROM user_defined_fields_template WHERE field_id = 110304

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'XConnect Tag Definition')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Tag Id',
		clm1_udf_id = @tag_id,
		clm2_label = 'Field Name',
		clm2_udf_id = @field_name,
		clm3_label = 'Conditional Value',
		clm3_udf_id = @conditional_value,
		clm4_label = 'Table Field Name',
		clm4_udf_id = @table_field_name,
		clm5_label = 'Tag Type',
		clm5_udf_id = @tag_type
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'XConnect Tag Definition'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id,
		clm5_label, clm5_udf_id,
		unique_columns_index,
		required_columns_index				
	)
	SELECT 
		mapping_table_id,
		'Tag Id', @tag_id,
		'Field Name', @field_name,
		'Conditional Value',@conditional_value,
		'Table Field Name',@table_field_name,
		'Tag Type',@tag_type,
		'4',
		'4'
	FROM generic_mapping_header 
	WHERE mapping_name = 'XConnect Tag Definition'
END



