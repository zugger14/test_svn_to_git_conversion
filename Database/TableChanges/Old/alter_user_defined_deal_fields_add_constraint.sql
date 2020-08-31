ALTER TABLE [dbo].[user_defined_deal_fields]  WITH NOCHECK ADD  CONSTRAINT [FK_user_defined_deal_fields_user_defined_fields_template] FOREIGN KEY([udf_template_id])
REFERENCES [dbo].[user_defined_fields_template] ([udf_template_id])
GO

