IF COL_LENGTH(N'power_outage', 'derate_mw') IS NOT NULL
BEGIN
	ALTER TABLE power_outage ALTER COLUMN derate_mw FLOAT NULL
	PRINT 'Column derate_mw altered.'
END
ELSE
PRINT 'Column derate_mw does not exists.'