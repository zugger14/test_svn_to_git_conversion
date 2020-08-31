
IF COL_LENGTH('netting_group','invoice_template') IS NULL
	ALTER TABLE netting_group ADD invoice_template INT
GO

IF COL_LENGTH('netting_group','create_individual_invoice') IS NULL
	ALTER TABLE netting_group ADD create_individual_invoice BIT NOT NULL DEFAULT 0
GO


IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_netting_group_invoice_template]') AND parent_object_id = OBJECT_ID(N'[dbo].[netting_group]'))
	ALTER TABLE [dbo].[netting_group] DROP CONSTRAINT [FK_netting_group_invoice_template]

BEGIN
	ALTER TABLE [dbo].[netting_group] WITH CHECK ADD CONSTRAINT [FK_netting_group_invoice_template] 
	FOREIGN KEY(invoice_template)
	REFERENCES [dbo].[contract_report_template] ([template_id])
		ON DELETE CASCADE 
END
GO




