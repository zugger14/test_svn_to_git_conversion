/***********************************
Step 1: Insert into static_data_value
************************************/
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112000)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112000, 112000, 'Source System', 'Source System', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112000 - Source System.'
END
ELSE
BEGIN
    PRINT 'Static data value 112000 - Source System already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112001)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112000, 112001, 'Field Type', 'Field Type', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112001 - Field Type.'
END
ELSE
BEGIN
    PRINT 'Static data value 112001 - Field Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF                

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112002)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112000, 112002, 'TRM Value', 'TRM Value', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112002 - TRM Value.'
END
ELSE
BEGIN
    PRINT 'Static data value 112002 - TRM Value already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF    

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112003)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112000, 112003, 'Account ID', 'Account ID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112003 - Account ID.'
END
ELSE
BEGIN
    PRINT 'Static data value 112003 - Account ID already EXISTS.'
END     
SET IDENTITY_INSERT static_data_value OFF

/************************************************
Step 2: Insert into user_defined_fields_template
************************************************/
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE  field_id = 112000)
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
           'Source System',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''p'' AS code, ''PJM Inventory'' AS value
		    UNION ALL
			SELECT ''t'' AS code, ''Trayport'' AS value
			UNION ALL
			SELECT ''i'' AS code, ''ICE'' AS value ',
           'h',
           NULL,
           30,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.value_id = 112000
END


IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE  field_id = 112001)
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
           'Field Type',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''c'' AS code, ''Counterparty'' AS value
		    UNION ALL
			SELECT ''t'' AS code, ''Technology'' AS value ',
           'h',
           NULL,
           30,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.value_id = 112001
END

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE  field_id = 112002)
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
           'TRM Value',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_counterparty_id AS code, counterparty_id AS value 
			FROM source_counterparty
			UNION ALL
			SELECT sdv.value_id, sdv.code 
			FROM static_data_value sdv
			INNER JOIN static_data_type sdt
				ON sdt.type_id = sdv.type_id
			WHERE type_name = ''Technology Type''',
           'h',
           NULL,
           30,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.value_id = 112002
END

IF NOT EXISTS (SELECT top 100 * FROM user_defined_fields_template WHERE  field_id = 112003)
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
           'Account ID',
           't',
           'NVARCHAR(250)',
           'n',
           '',
           'h',
           NULL,
           30,
           sdv.value_id
    FROM static_data_value sdv
    WHERE sdv.value_id = 112003
END

/*****************************************
Step 3: Insert into generic_mapping_header
******************************************/
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Value Mapping')
BEGIN
	UPDATE generic_mapping_header
	SET total_columns_used = 5
	WHERE mapping_name = 'Value Mapping'
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Value Mapping',
	5
	)
END


/*********************************************
Step 4: Insert into generic_mapping_definition
**********************************************/
DECLARE @source_system INT
DECLARE @field_type INT
DECLARE @value INT
DECLARE @trm_value INT
DECLARE @account_id INT


SELECT @source_system = udf_template_id FROM user_defined_fields_template WHERE field_id = 112000
SELECT @field_type = udf_template_id FROM user_defined_fields_template WHERE field_id = 112001
SELECT @value = udf_template_id FROM user_defined_fields_template WHERE field_id = 303269
SELECT @trm_value = udf_template_id FROM user_defined_fields_template WHERE field_id = 112002
SELECT @account_id = udf_template_id FROM user_defined_fields_template WHERE field_id = 112003


IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Value Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Source System',
		clm1_udf_id = @source_system,
		clm2_label = 'Field Type',
		clm2_udf_id = @field_type,
		clm3_label = 'Account ID',
		clm3_udf_id = @account_id,
		clm4_label = 'Value',
		clm4_udf_id = @value,
		clm5_label = 'TRM Value',
		clm5_udf_id = @trm_value,		
		unique_columns_index = '1,2,4',
		required_columns_index = '1,2,4,5' 
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Value Mapping'
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
		'Source System', @source_system,
		'Field Type', @field_type,
		'Account ID', @account_id,
		'Value', @value,
		'TRM Value', @trm_value,
		'1,2,4', '1,2,4,5' 
	FROM generic_mapping_header 
	WHERE mapping_name = 'Value Mapping'
END