IF NOT EXISTS (SELECT 1 FROM sys.indexes 
			   WHERE name = 'UQ_function_name' AND object_id = OBJECT_ID('map_function_category'))
BEGIN
	ALTER TABLE [map_function_category] 
	ADD CONSTRAINT UQ_function_name
	UNIQUE (function_name)	
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_function_name]')
				 AND parent_object_id = OBJECT_ID(N'[dbo].[formula_editor_parameter]'))
BEGIN
	ALTER TABLE [dbo].[formula_editor_parameter] 
	ADD CONSTRAINT [FK_function_name] 
	FOREIGN KEY([function_name])
	REFERENCES [dbo].[map_function_category] ([function_name])
END
