IF COL_LENGTH('ixp_import_data_source', 'clr_function_id') IS  NULL 
BEGIN
	ALTER TABLE ixp_import_data_source
	ADD clr_function_id INT
END