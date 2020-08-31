IF COL_LENGTH('gis_certificate', 'certification_entity') IS NULL
BEGIN
	ALTER TABLE gis_certificate
	ADD certification_entity INT NULL
	PRINT 'Column ''certification_entity'' added.'
END
ELSE PRINT 'Column ''certification_entity'' already exists.'
GO