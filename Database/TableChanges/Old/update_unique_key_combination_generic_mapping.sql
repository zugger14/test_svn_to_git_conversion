DECLARE @mapping_id INT
SELECT @mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'SAP GL Code Mapping'
--SELECT @mapping_id 
UPDATE generic_mapping_definition SET unique_columns_index = NULL WHERE mapping_table_id = @mapping_id

SELECT @mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'VAT Rule Mapping'
--SELECT @mapping_id
UPDATE generic_mapping_definition SET unique_columns_index = NULL WHERE mapping_table_id = @mapping_id

SELECT @mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Invoice Title'
--SELECT @mapping_id
UPDATE generic_mapping_definition SET unique_columns_index = NULL WHERE mapping_table_id = @mapping_id

SELECT @mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Contract Meters'
UPDATE generic_mapping_definition SET unique_columns_index = '1,2,3' WHERE mapping_table_id = @mapping_id

SELECT @mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Contract Curves'
UPDATE generic_mapping_definition SET unique_columns_index = '1,2,3' WHERE mapping_table_id = @mapping_id

SELECT @mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Contract Value'
UPDATE generic_mapping_definition SET unique_columns_index = '1,2,3' WHERE mapping_table_id = @mapping_id

SELECT @mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Contract Meters'
UPDATE generic_mapping_definition SET required_columns_index = '1,2,3,4' WHERE mapping_table_id = @mapping_id

SELECT @mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Contract Curves'
UPDATE generic_mapping_definition SET required_columns_index = '1,2,3,4' WHERE mapping_table_id = @mapping_id

SELECT @mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Contract Value'
UPDATE generic_mapping_definition SET required_columns_index = '1,2,3,4' WHERE mapping_table_id = @mapping_id




