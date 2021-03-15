IF OBJECT_ID(N'source_system_data_import_status', N'U') IS NOT NULL AND COL_LENGTH('source_system_data_import_status', 'process_id') IS NOT NULL
BEGIN
    ALTER TABLE source_system_data_import_status ALTER COLUMN process_id VARCHAR(100)
END
GO