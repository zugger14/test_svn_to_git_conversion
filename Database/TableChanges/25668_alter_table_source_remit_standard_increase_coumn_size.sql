IF COL_LENGTH('source_remit_standard', 'file_export_name') IS NOT NULL
BEGIN
	ALTER TABLE source_remit_standard
	ALTER COLUMN file_export_name NVARCHAR(2000)
END