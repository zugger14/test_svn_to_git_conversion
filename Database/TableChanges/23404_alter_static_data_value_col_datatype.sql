
IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[static_data_value]')  AND name = N'IX_static_data_value') 
BEGIN 
	ALTER TABLE [dbo].[static_data_value] DROP CONSTRAINT [IX_static_data_value]
END 

GO 

IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[static_data_value]')  AND name = N'IX_static_data_value_1') 
BEGIN
	DROP INDEX [IX_static_data_value_1] ON [dbo].[static_data_value]
END

GO

IF COL_LENGTH(N'static_data_value', N'code') IS  NOT NULL
BEGIN 
	ALTER TABLE [static_data_value] ALTER COLUMN [code] NVARCHAR(500) 
END

GO

IF COL_LENGTH(N'static_data_value', N'description') IS  NOT NULL 
BEGIN
	ALTER TABLE [static_data_value] ALTER COLUMN [description] NVARCHAR(500)
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[static_data_value]')  AND name = N'IX_static_data_value') 
BEGIN
 	ALTER TABLE [dbo].[static_data_value] ADD  CONSTRAINT [IX_static_data_value] UNIQUE NONCLUSTERED ([type_id] ASC, [code] ASC)
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[static_data_value]')  AND name = N'IX_static_data_value_1') 
BEGIN
 	CREATE NONCLUSTERED INDEX [IX_static_data_value_1] ON [dbo].[static_data_value]( [code] ASC )
END
GO

