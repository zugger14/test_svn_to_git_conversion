IF COL_LENGTH('application_users', 'company_catalog_id') IS NULL
BEGIN
    ALTER TABLE application_users ADD company_catalog_id INT

	ALTER TABLE [dbo].[application_users] ADD CONSTRAINT [FK_company_catalog_application_users_company_catalog_id] 
		FOREIGN KEY([company_catalog_id])
		REFERENCES [dbo].[company_catalog] ([company_catalog_id])

	PRINT 'Column company_catalog_id added in table application_users.'
END
ELSE
BEGIN
	PRINT 'Column company_catalog_id already exists in table application_users.'
END