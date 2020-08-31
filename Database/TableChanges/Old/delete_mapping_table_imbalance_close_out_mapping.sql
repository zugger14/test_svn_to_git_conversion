DECLARE @mapping_table_id INT

SELECT @mapping_table_id = mapping_table_id
FROM   generic_mapping_header
WHERE  mapping_name = 'Imbalance Close Out Mapping'

IF EXISTS (SELECT 1 FROM generic_mapping_values WHERE mapping_table_id = @mapping_table_id)
BEGIN
	DELETE FROM generic_mapping_values WHERE mapping_table_id = @mapping_table_id
END
ELSE
BEGIN
	PRINT 'Mapping table does not exists.'
END

IF EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	DELETE FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id
END
ELSE
BEGIN
	PRINT 'Mapping table does not exists.'
END

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_table_id = @mapping_table_id)
BEGIN
	DELETE FROM generic_mapping_header WHERE mapping_table_id = @mapping_table_id
END
ELSE
BEGIN
	PRINT 'Mapping table does not exists.'
END
