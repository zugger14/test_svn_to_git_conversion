IF COL_LENGTH('transportation_rate_category','rate_category') IS NOT NULL
BEGIN
	ALTER TABLE transportation_rate_category 
	ALTER COLUMN rate_category INT NULL
	PRINT 'Altered column ''rate_category''.'
END
ELSE
PRINT 'column ''rate_category'' doesn''t exist.'