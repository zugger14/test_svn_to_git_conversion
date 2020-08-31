/***********************************
Step 1: Insert into static_data_value
************************************/

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5650)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5650, 5500, 'Report Type', 'Report Type', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5650 - Report Type.'
END
ELSE
BEGIN
    PRINT 'Static data value -5650 - Report Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000129)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000129, 5500, 'Report Level', 'Report Level', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000129 - Report Level.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000129 - Report Level already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000128)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000128, 5500, 'Book Structure', 'Book Structure', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000128 - Book Structure.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000128 - Book Structure already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

/************************************************
Step 2: Insert into user_defined_fields_template
************************************************/

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -5650)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -5650, 'Report Type', 'd', 'VARCHAR(150)', 'n', 'SELECT ''E'' id, ''EMIR'' code UNION ALL SELECT ''M'', ''MiFID''', 'h', NULL, 180, -5650
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000129)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000129, 'Report Level', 'd', 'VARCHAR(150)', 'n', 'SELECT 1 id, ''EMIR Position'' code UNION ALL SELECT 2 id, ''EMIR MTM'' UNION ALL SELECT 3 id, ''EMIR Trade'' UNION ALL SELECT 4 id, ''EMIR Collateral'' UNION ALL SELECT 5 id, ''Transaction (AFM)'' UNION ALL SELECT 6 id, ''Post Trade (Tradeweb)''', 'h', NULL, 180, -10000129
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000128)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000128, 'Book Structure', 'd', 'VARCHAR(150)', 'n', 'SELECT DISTINCT ssbm.book_deal_type_map_id sub_book_id, sub.[entity_name] + '' | '' + stra.[entity_name] + '' | '' + book.[entity_name] + '' | '' + ssbm.logical_name book_structure FROM source_system_book_map ssbm INNER JOIN portfolio_hierarchy book ON book.[entity_id] = ssbm.fas_book_id INNER JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.[entity_id] INNER JOIN portfolio_hierarchy sub ON stra.parent_entity_id = sub.[entity_id] ORDER BY book_structure', 'h', NULL, 180, -10000128
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

/*****************************************
Step 3: Insert into generic_mapping_header
******************************************/
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Regulatory Reporting - Book Structure')
BEGIN
	UPDATE generic_mapping_header
	SET total_columns_used = 3
	WHERE mapping_name = 'Regulatory Reporting - Book Structure'
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Regulatory Reporting - Book Structure',
	3
	)
END


/*********************************************
Step 4: Insert into generic_mapping_definition
**********************************************/
DECLARE @report_type INT
DECLARE @report_level INT
DECLARE @book_structure INT

SELECT @report_type = udf_template_id FROM user_defined_fields_template WHERE field_id = -5650
SELECT @report_level = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000129
SELECT @book_structure = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000128


IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Regulatory Reporting - Book Structure')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Report Type',
		clm1_udf_id = @report_type,
		clm2_label = 'Report Level',
		clm2_udf_id = @report_level,
		clm3_label = 'Book Structure',
		clm3_udf_id = @book_structure
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Regulatory Reporting - Book Structure'
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
		'Report Type', @report_type,
		'Report Level', @report_level,
		'Book Structure',@book_structure
	FROM generic_mapping_header 
	WHERE mapping_name = 'Regulatory Reporting - Book Structure'
END