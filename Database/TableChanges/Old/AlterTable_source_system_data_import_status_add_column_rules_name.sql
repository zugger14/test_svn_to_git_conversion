IF COL_LENGTH('source_system_data_import_status', 'rules_name') IS NULL
BEGIN
    ALTER TABLE source_system_data_import_status ADD rules_name VARCHAR(5000)
END
GO
