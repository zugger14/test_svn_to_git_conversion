ALTER TABLE [dbo].[user_defined_deal_fields_template] ADD udf_type CHAR(1) NOT NULL DEFAULT 'u'
GO
ALTER TABLE [dbo].[user_defined_deal_fields_template] ADD sequence INT NULL
GO