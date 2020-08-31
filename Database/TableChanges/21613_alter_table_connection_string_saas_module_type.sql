IF COL_LENGTH('dbo.connection_string', 'saas_module_type') IS NULL
BEGIN
	ALTER TABLE connection_string
	ADD  saas_module_type VARCHAR(4)

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Defines module type (trm, fas etc.) for SaaS versions, which use same client folder (normally trmcloud). Default is NULL.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'connection_string', @level2type=N'COLUMN',@level2name=N'saas_module_type'
END

