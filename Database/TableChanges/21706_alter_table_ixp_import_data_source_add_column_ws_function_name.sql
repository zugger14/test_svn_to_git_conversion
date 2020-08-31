IF COL_LENGTH('ixp_import_data_source','ws_function_name') IS NULL
BEGIN
	ALTER TABLE ixp_import_data_source ADD ws_function_name VARCHAR(200)
	PRINT('Column ws_function_name added')
END
ELSE	
	PRINT('Column ws_function_name already exists')	
GO