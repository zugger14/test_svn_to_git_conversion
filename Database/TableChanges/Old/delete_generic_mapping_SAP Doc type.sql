
DECLARE @mapping_table_id INT 
SELECT  @mapping_table_id = mapping_table_id FROM generic_mapping_header AS gmh WHERE gmh.mapping_name ='SAP Doc type'

DELETE FROM generic_mapping_values WHERE mapping_table_id = @mapping_table_id
DELETE FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id
DELETE FROM generic_mapping_header WHERE mapping_table_id = @mapping_table_id
