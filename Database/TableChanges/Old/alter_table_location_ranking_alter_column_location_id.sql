IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'location_ranking' AND COLUMN_NAME = 'location_id')
BEGIN
	ALTER TABLE location_ranking ALTER COLUMN location_id INT NULL
END