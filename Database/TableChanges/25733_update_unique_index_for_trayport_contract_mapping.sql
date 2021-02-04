DECLARE @mapping_table_id INT
SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Trayport Contract Mapping'


UPDATE generic_mapping_definition
SET  unique_columns_index = '1,2'
WHERE mapping_table_id = @mapping_table_id
