IF COL_LENGTH('ixp_rules','is_active') is null
BEGIN
	ALTER TABLE ixp_rules ADD is_active INT 
END
ELSE 
	PRINT 'Column already exists.'
	
GO
UPDATE ixp_rules
SET is_active = 1
WHERE is_active IS NULL