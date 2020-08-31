UPDATE admin_email_configuration SET module_type = 17800 WHERE cust_id = 1

IF COL_LENGTH('admin_email_configuration', 'Module_type') IS NOT NULL
BEGIN
	EXECUTE sp_rename N'dbo.admin_email_configuration.Module_type', N'Tmp_module_type', 'COLUMN' 
	EXECUTE sp_rename N'dbo.admin_email_configuration.Tmp_module_type', N'module_type', 'COLUMN'
END

IF COL_LENGTH('admin_email_configuration', 'Module_description') IS NOT NULL 
	ALTER TABLE dbo.admin_email_configuration DROP COLUMN Module_description

IF OBJECT_ID(N'FK_admin_email_configuration_static_data_value', N'F') IS NULL
BEGIN
	ALTER TABLE dbo.admin_email_configuration ADD CONSTRAINT
	FK_admin_email_configuration_static_data_value FOREIGN KEY
	(
	cust_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
END



	




