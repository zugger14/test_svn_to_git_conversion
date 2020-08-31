IF COL_LENGTH('time_series_definition', 'group_id') IS NULL
BEGIN
    ALTER TABLE time_series_definition ADD group_id INT 
END
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_time_series_definition_group_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[time_series_definition]'))
	ALTER TABLE [dbo].[time_series_definition] DROP CONSTRAINT FK_time_series_definition_group_id

BEGIN
	ALTER TABLE [dbo].[time_series_definition] WITH CHECK ADD CONSTRAINT [FK_time_series_definition_group_id] 
	FOREIGN KEY([group_id])
	REFERENCES [dbo].[static_data_type] ([type_id])
		ON DELETE CASCADE 
END