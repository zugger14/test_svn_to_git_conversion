IF OBJECT_ID(N'source_system_data_import_status_detail', N'U') IS NOT NULL AND COL_LENGTH('source_system_data_import_status_detail', 'process_id') IS NOT NULL
BEGIN
    ALTER TABLE source_system_data_import_status_detail ALTER COLUMN process_id VARCHAR(100)
END
GO