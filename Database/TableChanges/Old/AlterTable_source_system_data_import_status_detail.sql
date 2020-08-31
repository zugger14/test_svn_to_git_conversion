IF COL_LENGTH('source_system_data_import_status_detail', 'import_file_name') IS NULL
BEGIN
    ALTER TABLE source_system_data_import_status_detail ADD import_file_name VARCHAR(2000)
END
GO