-- UDF Template

IF NOT EXISTS(SELECT * FROM user_defined_fields_template WHERE field_id = 303244)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT 303244, 'Contract', 'd', 'NVARCHAR(250)', 'n', 'EXEC spa_contract_group @flag = ''j''', 'h', 100, 303244
END
ELSE
BEGIN
	UPDATE udft
	SET field_label = 'Contract'
		, Field_type = 'd'
		, data_type = 'NVARCHAR(250)'
		, is_required = 'n'
		, sql_string = 'EXEC spa_contract_group @flag = ''j'''
	FROM user_defined_fields_template udft
	WHERE udft.field_id = 303244
END

IF NOT EXISTS(SELECT * FROM user_defined_fields_template WHERE field_id = 303262)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT 303262, 'Counterparty', 'd', 'NVARCHAR(250)', 'n', 'spa_source_counterparty_maintain @flag = ''c''', 'h', 100, 303262
END
ELSE
BEGIN
	UPDATE udft
	SET field_label = 'Counterparty'
		, Field_type = 'd'
		, data_type = 'NVARCHAR(250)'
		, is_required = 'n'
		, sql_string = 'spa_source_counterparty_maintain @flag = ''c'''
	FROM user_defined_fields_template udft
	WHERE udft.field_id = 303262
END

-- Generic Mapping Table 
IF NOT EXISTS( SELECT * FROM generic_mapping_header WHERE mapping_name = 'Trayport Contract Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Trayport Contract Mapping', 3, 0)
END

-- Mapping Definition
DECLARE @mapping_table_id INT
	  , @commodity INT
	  , @contract INT
	  , @counterparty INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Trayport Contract Mapping'

SELECT @counterparty = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = 303262

SELECT @commodity = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -5500

SELECT @contract = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = 303244


IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, clm3_label, clm3_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'Counterparty', @counterparty, 'Commodity', @commodity, 'Contract', @contract, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Counterparty'
	  , clm1_udf_id = @counterparty
	  , clm2_label = 'Commodity'
	  , clm2_udf_id = @commodity
	  , clm3_label = 'Contract'
	  , clm3_udf_id = @contract
	  , unique_columns_index = '1'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Trayport Contract Mapping'
END
