IF COL_LENGTH(N'application_notes', 'UI') IS NULL
BEGIN
    ALTER TABLE [dbo].[application_notes] ADD [UI] uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE DEFAULT (NEWID())
    PRINT 'Column UI added.'
END
ELSE
    PRINT 'UI Already Exists.'
GO

IF COL_LENGTH(N'application_notes', 'FS_Data') IS NULL
BEGIN
    ALTER TABLE [dbo].[application_notes] ADD [FS_Data] [varbinary](MAX) FILESTREAM NULL
    PRINT 'Column FS_Data added.'
END
ELSE
    PRINT 'FS_Data Already Exists.'
GO

IF COL_LENGTH(N'application_notes', 'type_column_name') IS NULL
BEGIN
    ALTER TABLE [dbo].[application_notes] ADD [type_column_name] [varchar](30) NULL
    PRINT 'Column type_column_name added.'
END
ELSE
    PRINT 'type_column_name Already Exists.'
GO

