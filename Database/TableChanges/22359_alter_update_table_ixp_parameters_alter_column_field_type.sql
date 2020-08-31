IF COL_LENGTH('ixp_parameters', 'field_type') IS NOT NULL 
BEGIN
	ALTER TABLE ixp_parameters ALTER COLUMN field_type VARCHAR(100)
END

UPDATE ixp_parameters SET field_type = 'browser' WHERE field_type = 'm' 
UPDATE ixp_parameters SET field_type = 'calendar' WHERE field_type = 'a' 
UPDATE ixp_parameters SET field_type = 'input' WHERE field_type = 't' 
