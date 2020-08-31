IF COL_LENGTH(N'power_outage', 'comments') IS NULL
BEGIN
	ALTER TABLE power_outage ADD comments VARCHAR(500)  
	PRINT 'Column added.'
END
ELSE
	PRINT 'Column already exists.'