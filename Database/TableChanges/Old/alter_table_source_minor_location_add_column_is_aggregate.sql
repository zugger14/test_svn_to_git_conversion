IF COL_LENGTH('source_minor_location', 'is_aggregate') IS NULL
BEGIN
	ALTER TABLE source_minor_location ADD is_aggregate CHAR(1) NULL
	PRINT 'Column source_minor_location.is_aggregate added.'
END
ELSE
BEGIN
	PRINT 'Column source_minor_location.is_aggregate already exists.'
END
GO