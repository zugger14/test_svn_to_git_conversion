/**
ALTER TABLE TO ADD URL TEXT FIELD
**/
IF COL_LENGTH(N'application_notes', 'url') IS NULL
BEGIN
	ALTER TABLE application_notes ADD url VARCHAR(100)
END
ELSE
	PRINT 'Column : url, already exists.'


