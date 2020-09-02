DECLARE @mapping_table_id INT = NULL
--Delete generic mapping Trayport Deal Template Mapping
SELECT @mapping_table_id = gmh.mapping_table_id FROM generic_mapping_header AS gmh WHERE gmh.mapping_name = 'Trayport Deal Template Mapping'
IF @mapping_table_id IS NOT NULL
BEGIN
	DELETE FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id
	DELETE FROM generic_mapping_values WHERE mapping_table_id = @mapping_table_id
	DELETE FROM generic_mapping_header WHERE mapping_table_id = @mapping_table_id
END

--Delete generic mapping Trayport Block Mapping
SELECT @mapping_table_id = gmh.mapping_table_id FROM generic_mapping_header AS gmh WHERE gmh.mapping_name = 'Trayport Block Mapping'
IF @mapping_table_id IS NOT NULL
BEGIN
	DELETE FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id
	DELETE FROM generic_mapping_values WHERE mapping_table_id = @mapping_table_id
	DELETE FROM generic_mapping_header WHERE mapping_table_id = @mapping_table_id
END
