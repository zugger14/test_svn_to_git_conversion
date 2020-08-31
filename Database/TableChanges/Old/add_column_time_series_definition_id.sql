
IF  EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'delivery_path' AND COLUMN_NAME = 'time_series_definition_id')
BEGIN
	ALTER TABLE delivery_path drop column time_series_definition_id 
END


IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'maintain_location_routes' AND COLUMN_NAME = 'time_series_definition_id')
BEGIN
	ALTER TABLE maintain_location_routes ADD time_series_definition_id INT NULL
END

