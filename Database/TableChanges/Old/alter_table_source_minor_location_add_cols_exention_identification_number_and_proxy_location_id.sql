IF NOT EXISTS(SELECT 'X' FROM   information_schema.columns WHERE  table_name = 'source_minor_location' AND column_name = 'external_identification_number')
BEGIN
	ALTER TABLE source_minor_location ADD external_identification_number VARCHAR(200)
END


IF NOT EXISTS(SELECT 'X' FROM   information_schema.columns WHERE  table_name = 'source_minor_location' AND column_name = 'proxy_location_id')
BEGIN
	ALTER TABLE source_minor_location ADD proxy_location_id INT
END