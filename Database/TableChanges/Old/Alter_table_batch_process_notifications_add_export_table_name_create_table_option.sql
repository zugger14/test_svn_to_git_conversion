IF COL_LENGTH('batch_process_notifications', 'export_table_name') IS NULL
BEGIN
	ALTER TABLE batch_process_notifications ADD export_table_name VARCHAR(200) NULL
END

