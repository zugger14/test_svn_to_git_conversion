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
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Template'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Contract')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Contract', 'Contract'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Contract'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Contract'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Contract',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT contract_id AS id,contract_name AS value FROM contract_group cg',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Contract'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT contract_id AS id,contract_name AS value FROM contract_group cg'
    WHERE  Field_label = 'Contract'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Template'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Template',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT template_id, template_name FROM source_deal_header_template ORDER BY template_name',
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
		   sql_string = 'SELECT template_id, template_name FROM source_deal_header_template ORDER BY template_name'
    WHERE  Field_label = 'Template'
END

DECLARE @contract_id INT
DECLARE @template_id INT

SELECT @contract_id = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Contract'

SELECT @template_id = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Template'

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Imbalance Close Out Mapping')
BEGIN
	DECLARE @new_table_id INT
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used) VALUES ('Imbalance Close Out Mapping', 2)
	
	SET @new_table_id = SCOPE_IDENTITY()
	
	INSERT INTO generic_mapping_definition (mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id)
	SELECT @new_table_id, 'Contract', @contract_id, 'Template', @template_id
END