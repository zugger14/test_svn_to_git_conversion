/***********************************
Step 1: Insert into static_data_value
************************************/
/************************************************
Step 2: Insert into user_defined_fields_template
************************************************/
--step 1 and 2 not required in this case as deal template is already present in sdc and udft.

/*****************************************
Step 3: Insert into generic_mapping_header
******************************************/
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'REC Inventory Mapping')
BEGIN
	UPDATE generic_mapping_header
	SET total_columns_used = 1
	WHERE mapping_name = 'REC Inventory Mapping'
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'REC Inventory Mapping',
	1
	)
END


/*********************************************
Step 4: Insert into generic_mapping_definition
**********************************************/
DECLARE @deal_template INT

SELECT @deal_template = udf_template_id FROM user_defined_fields_template WHERE field_id = 307175

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'REC Inventory Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Deal Template',
		clm1_udf_id = @deal_template		
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'REC Inventory Mapping'
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
		'Deal Template', @deal_template,		
		'1',
		'1'
	FROM generic_mapping_header 
	WHERE mapping_name = 'REC Inventory Mapping'
END