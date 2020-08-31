IF COL_LENGTH('schemaName.source_system_data_import_status_detail', 'description') IS NOT NULL
BEGIN
    ALTER TABLE source_system_data_import_status_detail
	ALTER COLUMN description NVARCHAR(1000)
END