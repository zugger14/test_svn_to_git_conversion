IF OBJECT_ID(N'source_system_data_import_status_detail', N'U') IS NOT NULL AND COL_LENGTH('source_system_data_import_status_detail', 'description') IS NOT NULL
BEGIN
    ALTER TABLE source_system_data_import_status_detail ALTER COLUMN [description] VARCHAR(MAX)
END
GO