IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND   tc.Table_Name = 'time_series_definition' 
                    AND ccu.COLUMN_NAME = 'time_series_definition_id'
)
ALTER TABLE [dbo].[time_series_definition] WITH NOCHECK ADD CONSTRAINT [PK_time_series_definition_id] PRIMARY KEY([time_series_definition_id])
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_time_series_definition_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[time_series_data]'))
	ALTER TABLE [dbo].[time_series_data] DROP CONSTRAINT FK_time_series_definition_id

BEGIN
	ALTER TABLE [dbo].[time_series_data] WITH CHECK ADD CONSTRAINT [FK_time_series_definition_id] 
	FOREIGN KEY([time_series_definition_id])
	REFERENCES [dbo].[time_series_definition] ([time_series_definition_id])
		ON DELETE CASCADE 
END
