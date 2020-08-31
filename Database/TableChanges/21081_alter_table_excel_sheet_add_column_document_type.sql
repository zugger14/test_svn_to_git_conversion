IF COL_LENGTH('excel_sheet', 'document_type') IS NULL
BEGIN
    ALTER TABLE excel_sheet ADD document_type INT
END
GO