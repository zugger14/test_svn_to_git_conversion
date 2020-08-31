IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_curve_def_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve]'))
	 ALTER TABLE dbo.source_price_curve DROP CONSTRAINT FK_source_curve_def_id

BEGIN
	ALTER TABLE [dbo].[source_price_curve] WITH CHECK ADD CONSTRAINT [FK_source_curve_def_id] 
	FOREIGN KEY([source_curve_def_id])
	REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
	  ON DELETE CASCADE 
END