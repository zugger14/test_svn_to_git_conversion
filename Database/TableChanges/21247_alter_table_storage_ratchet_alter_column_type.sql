IF COL_LENGTH(N'storage_ratchet', 'type') IS NOT NULL
BEGIN
	ALTER TABLE storage_ratchet 
		ALTER COLUMN [type] CHAR

	PRINT 'Altered columns accounting_type.'
END