DECLARE @mapping_table_id INT 
SELECT @mapping_table_id =  mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'NON EFET SAP Doc Type'
UPDATE generic_mapping_definition 
SET clm2_label = 'Sub Process' WHERE mapping_table_id = @mapping_table_id




