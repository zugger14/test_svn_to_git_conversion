DECLARE @mapping_table_id INT, @counterparty INT, @contract INT, @book INT, @deal_type INT, @deal_sub_type INT, @commodity INT, @template INT, @confimation_status INT, @deal_status INT, @submission_type INT 

SELECT @mapping_table_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Submission Field Mapping'
SELECT @counterparty= udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @contract = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @book = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Book'
SELECT @deal_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Type'
SELECT @deal_sub_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Sub Type'
SELECT @commodity = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Commodity'
SELECT @template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Template'
SELECT @confimation_status = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Confirmation Status'
SELECT @deal_status = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Status'
SELECT @submission_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Submission Type'

DELETE gmv
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh
	ON gmh.mapping_table_id = gmv.mapping_table_id
WHERE mapping_name = 'Submission Field Mapping'

DELETE gmd
FROM generic_mapping_definition gmd
INNER JOIN generic_mapping_header gmh
	ON gmh.mapping_table_id = gmd.mapping_table_id
WHERE mapping_name = 'Submission Field Mapping'

DELETE
FROM generic_mapping_header
WHERE mapping_name = 'Submission Field Mapping'

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Submission Field Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Submission Field Mapping',
	10
	)
END

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Submission Field Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Counterparty',
		clm1_udf_id = @counterparty,
		clm2_label = 'Contract',
		clm2_udf_id = @contract,
		clm3_label = 'Book',
		clm3_udf_id = @book,
		clm4_label = 'Deal Type',
		clm4_udf_id = @deal_type,
		clm5_label = 'Deal Sub Type',
		clm5_udf_id = @deal_sub_type,
		clm6_label = 'Commodity',
		clm6_udf_id = @commodity,
		clm7_label = 'Template',
		clm7_udf_id = @template,
		clm8_label = 'Confirmation Status',
		clm8_udf_id = @confimation_status,
		clm9_label = 'Deal Status',
		clm9_udf_id = @deal_status,
		clm10_label = 'Submission Type',
		clm10_udf_id = @submission_type
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Submission Field Mapping'
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
		clm6_label, clm6_udf_id,
		clm7_label, clm7_udf_id,
		clm8_label, clm8_udf_id,
		clm9_label, clm9_udf_id,
		clm10_label, clm10_udf_id
	)
	SELECT 
		mapping_table_id,
		'Counterparty', @counterparty,
		'Contract', @contract,
		'Book', @book,
		'Deal Type', @deal_type,
		'Deal Sub Type', @deal_sub_type,
		'Commodity', @commodity,
		'Template', @template,
		'Confirmation Status', @confimation_status,
		'Deal Status', @deal_status,
		'Submission Type', @submission_type
	FROM generic_mapping_header 
	WHERE mapping_name = 'Submission Field Mapping'
END
