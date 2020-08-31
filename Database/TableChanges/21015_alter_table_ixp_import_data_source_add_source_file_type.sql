IF COL_LENGTH('ixp_import_data_source','source_file_type') IS NULL
	ALTER TABLE ixp_import_data_source ADD source_file_type VARCHAR(4)
GO
