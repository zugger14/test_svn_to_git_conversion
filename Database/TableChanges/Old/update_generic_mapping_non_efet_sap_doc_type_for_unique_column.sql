--Unique Column Index
DECLARE @mapping_table_id INT 
SELECT @mapping_table_id =  mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Non EFET SAP Doc Type'
IF @mapping_table_id IS NOT NULL
	UPDATE generic_mapping_definition
	SET    unique_columns_index     = '1,2,3,4'
	WHERE  mapping_table_id         = @mapping_table_id



