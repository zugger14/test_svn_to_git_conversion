IF NOT EXISTS(SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'source_price_curve_def' AND column_name LIKE 'block_type')
ALTER TABLE source_price_curve_def ADD block_type INT 
GO
IF NOT EXISTS(SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'source_price_curve_def' AND column_name LIKE 'block_define_id')	
ALTER TABLE source_price_curve_def ADD block_define_id INT 
GO
	
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_def_static_data_value3]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_def]'))
ALTER TABLE [dbo].[source_price_curve_def]  WITH CHECK ADD  CONSTRAINT [FK_source_price_curve_def_static_data_value3] FOREIGN KEY([block_type])
REFERENCES [dbo].[static_data_value] ([value_id])
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_def_static_data_value4]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_def]'))
ALTER TABLE [dbo].[source_price_curve_def]  WITH CHECK ADD  CONSTRAINT [FK_source_price_curve_def_static_data_value4] FOREIGN KEY([block_define_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
