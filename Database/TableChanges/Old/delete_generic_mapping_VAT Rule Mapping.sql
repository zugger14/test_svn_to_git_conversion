DECLARE @mapping_name_list VARCHAR(200) = 'VAT Rule Mapping'
DECLARE @mapping_table_id INT


SELECT @mapping_table_id  = mapping_table_id FROM  generic_mapping_header WHERE mapping_name = @mapping_name_list



BEGIN TRY
DELETE  FROM   generic_mapping_values WHERE mapping_table_id = @mapping_table_id
DELETE  FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id
DELETE FROM generic_mapping_header WHERE mapping_name = @mapping_name_list
END TRY
BEGIN CATCH 
	IF @@ERROR <> 0 
		BEGIN 
			
			SELECT 11 
		END
END CATCH
