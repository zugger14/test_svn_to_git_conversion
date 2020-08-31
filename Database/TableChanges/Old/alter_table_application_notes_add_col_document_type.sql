--add new column document_type on applicaation_notes and set FK referencing document_id of documents_type table.
IF COL_LENGTH(N'[dbo].[application_notes]', N'document_type') IS NULL
BEGIN
    ALTER TABLE [dbo].[application_notes]
    ADD document_type INT NULL
    PRINT 'Column ''document_type'' added on table ''[dbo].[application_notes]''.'
END
ELSE
    PRINT 'Column ''document_type'' on table ''[dbo].[application_notes]'' already exists.'
GO
IF OBJECT_ID(N'FK_document_type_application_notes_documents_type', N'F') IS NULL
BEGIN
    ALTER TABLE [dbo].[application_notes]
    ADD CONSTRAINT [FK_document_type_application_notes_documents_type]
    FOREIGN KEY ([document_type])
    REFERENCES [dbo].[documents_type] ([document_id])
    ON DELETE SET NULL
    PRINT 'FK ''FK_document_type_application_notes_documents_type'' created.'
END
ELSE
    PRINT 'FK ''FK_document_type_application_notes_documents_type'' already exists.'
GO