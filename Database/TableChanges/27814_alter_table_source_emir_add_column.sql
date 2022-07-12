IF COL_LENGTH('source_emir', 'document_version') IS NULL
BEGIN
    ALTER TABLE source_emir ADD document_version NVARCHAR(25)
END
GO

IF COL_LENGTH('source_emir', 'document_id') IS NOT NULL
BEGIN
    ALTER TABLE source_emir ALTER column document_id NVARCHAR(200)
END
GO