IF COL_LENGTH('time_series_data', 'time_series_group') IS NULL
BEGIN
    ALTER TABLE time_series_data ADD time_series_group INT
END
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_time_series_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[time_series_data]'))
	ALTER TABLE [dbo].[time_series_data] DROP CONSTRAINT FK_time_series_group

BEGIN
	ALTER TABLE [dbo].[time_series_data] WITH CHECK ADD CONSTRAINT [FK_time_series_group] 
	FOREIGN KEY([time_series_group])
	REFERENCES [dbo].[static_data_value] ([value_id])
		ON DELETE CASCADE 
END
