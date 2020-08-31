IF COL_LENGTH(N'application_notes', 'url') IS NOT NULL
BEGIN
	ALTER TABLE application_notes 
		ALTER COLUMN url VARCHAR(MAX) 		
END
ELSE
BEGIN
	PRINT 'Column url not found.'
END
