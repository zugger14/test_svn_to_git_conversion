IF COL_LENGTH('interface_configuration_detail', 'file_store_path') IS NOT NULL
	ALTER TABLE interface_configuration_detail DROP COLUMN file_store_path
GO

IF COL_LENGTH('interface_configuration_detail', 'file_log_path') IS NOT NULL
	ALTER TABLE interface_configuration_detail DROP COLUMN file_log_path
GO