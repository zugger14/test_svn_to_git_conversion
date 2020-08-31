/***********************************
Step 1: Insert into static_data_value
************************************/
--sdv : Import Source
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -111701)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (111700, -111701, 'Import Source', 'Import Source', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -111701 - Import Source.'
END
ELSE
BEGIN
    PRINT 'Static data value -111701 - Import Source already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF   
/************************************************
Step 2: Insert into user_defined_fields_template
************************************************/

IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE  field_id = -111701)
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
           'Import Source',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ixp_rules_id [id], ixp_rules_name [value] FROM ixp_rules WHERE ixp_category = 23502 ORDER BY 2',
           'h',
           NULL,
           30,
           sdv.value_id
    FROM static_data_value sdv
    WHERE  sdv.value_id = -111701
END

/*****************************************
Step 3: Insert into generic_mapping_header
******************************************/
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'REC Inventory Mapping')
BEGIN
	UPDATE generic_mapping_header
	SET total_columns_used = 4
	WHERE mapping_name = 'REC Inventory Mappingn'
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'REC Inventory Mapping',
	4
	)
END


/*********************************************
Step 4: Insert into generic_mapping_definition
**********************************************/
DECLARE @deal_template INT
DECLARE @import_source INT
DECLARE @sub_book INT
DECLARE @trader INT

SELECT @deal_template = udf_template_id FROM user_defined_fields_template WHERE field_id = 307175
SELECT @import_source = udf_template_id FROM user_defined_fields_template WHERE field_id = -111701
SELECT @sub_book	  = udf_template_id FROM user_defined_fields_template WHERE field_id = -5674
SELECT @trader		  = udf_template_id FROM user_defined_fields_template WHERE field_id = 307250

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'REC Inventory Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Import Source',
		clm1_udf_id = @import_source,
		clm2_label = 'Deal Source Template',
		clm2_udf_id = @deal_template,
		clm3_label = 'Sub Book',
		clm3_udf_id = @sub_book,
		clm4_label = 'Trader',
		clm4_udf_id = @trader,
		unique_columns_index = '1,2,3,4',
		required_columns_index = '2,3,4'
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'REC Inventory Mapping'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id,
		unique_columns_index,
		required_columns_index				
	)
	SELECT 
		mapping_table_id,
		'Import Source', @import_source,
		'Deal Source Template', @deal_template,
		'Sub Book', @sub_book,
		'Trader', @trader,
		'1,2,3,4',
		'2,3,4'
	FROM generic_mapping_header 
	WHERE mapping_name = 'REC Inventory Mapping'
END



