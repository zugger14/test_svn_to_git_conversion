IF COL_LENGTH('source_remit_audit', 'error_description') IS NOT NULL
BEGIN
	ALTER TABLE source_remit_audit
	ALTER COLUMN error_description NVARCHAR(2000)
END