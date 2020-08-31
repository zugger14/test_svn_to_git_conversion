IF COL_LENGTH('attachment_detail_info', 'is_imported') IS NULL
BEGIN
    ALTER TABLE attachment_detail_info ADD is_imported CHAR(1)
END
GO