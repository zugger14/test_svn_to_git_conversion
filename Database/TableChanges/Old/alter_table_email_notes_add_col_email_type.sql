IF COL_LENGTH(N'[dbo].[email_notes]', N'email_type') IS NULL
BEGIN
    ALTER TABLE [dbo].[email_notes]
    ADD email_type char(1) NULL
    PRINT 'Column ''email_type'' added on table ''[dbo].[email_notes]''.'
END
ELSE
    PRINT 'Column ''email_type'' on table ''[dbo].[email_notes]'' already exists.'
GO

IF COL_LENGTH(N'email_notes', 'UI') IS NULL
BEGIN
    ALTER TABLE [dbo].[email_notes] 
	ADD [UI] uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE DEFAULT (NEWID())
    PRINT 'Column UI added.'
END
ELSE
    PRINT 'UI Already Exists.'
GO

IF COL_LENGTH(N'email_notes', 'FS_Data') IS NULL
BEGIN
    ALTER TABLE [dbo].[email_notes] 
	ADD [FS_Data] [varbinary](MAX) FILESTREAM NULL
    PRINT 'Column FS_Data added.'
END
ELSE
    PRINT 'FS_Data Already Exists.'
GO

IF COL_LENGTH(N'email_notes', 'type_column_name') IS NULL
BEGIN
    ALTER TABLE [dbo].[email_notes] 
	ADD [type_column_name] [varchar](30) NULL
    PRINT 'Column type_column_name added.'
END
ELSE
    PRINT 'type_column_name Already Exists.'
GO

IF COL_LENGTH(N'[dbo].[email_notes]', N'user_category') IS NULL
BEGIN
    ALTER TABLE [dbo].[email_notes]
    ADD user_category INT NULL CONSTRAINT FK_user_category_email_notes_static_data_value FOREIGN KEY (user_category) REFERENCES static_data_value(value_id) ON DELETE SET NULL
    PRINT 'Column ''user_category'' added on table ''[dbo].[email_notes]''.'
END
ELSE
    PRINT 'Column ''user_category'' on table ''[dbo].[email_notes]'' already exists.'
GO

IF COL_LENGTH(N'[dbo].[email_notes]', N'attachment_folder') IS NULL
BEGIN
    ALTER TABLE [dbo].[email_notes]
    ADD attachment_folder varchar(300)
    PRINT 'Column ''attachment_folder'' added on table ''[dbo].[email_notes]''.'
END
ELSE
    PRINT 'Column ''attachment_folder'' on table ''[dbo].[email_notes]'' already exists.'
GO

IF COL_LENGTH(N'[dbo].[email_notes]', N'document_type') IS NULL
BEGIN
    ALTER TABLE [dbo].[email_notes]
    ADD document_type INT NULL
    PRINT 'Column ''document_type'' added on table ''[dbo].[email_notes]''.'
END
ELSE
    PRINT 'Column ''document_type'' on table ''[dbo].[email_notes]'' already exists.'
GO
IF OBJECT_ID(N'FK_document_type_email_notes_documents_type', N'F') IS NULL
BEGIN
    ALTER TABLE [dbo].[email_notes]
    ADD CONSTRAINT [FK_document_type_email_notes_documents_type]
    FOREIGN KEY ([document_type])
    REFERENCES [dbo].[documents_type] ([document_id])
    ON DELETE SET NULL
    PRINT 'FK ''FK_document_type_email_notes_documents_type'' created.'
END
ELSE
    PRINT 'FK ''FK_document_type_email_notes_documents_type'' already exists.'
GO