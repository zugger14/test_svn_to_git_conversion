IF COL_LENGTH('import_data_files_audit', 'import_source') IS NULL
BEGIN
    ALTER TABLE import_data_files_audit ADD import_source VARCHAR(800)
END
GO
