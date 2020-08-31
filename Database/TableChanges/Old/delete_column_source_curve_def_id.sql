IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'maintain_location_routes' AND COLUMN_NAME = 'source_curve_def_id')
BEGIN
	ALTER TABLE maintain_location_routes DROP COLUMN source_curve_def_id
END