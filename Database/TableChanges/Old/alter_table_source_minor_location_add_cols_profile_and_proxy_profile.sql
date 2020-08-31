IF NOT EXISTS(SELECT 'X' FROM   information_schema.columns WHERE  table_name = 'source_minor_location' AND column_name = 'profile')
BEGIN
	ALTER TABLE source_minor_location ADD [profile] INT
END


IF NOT EXISTS(SELECT 'X' FROM   information_schema.columns WHERE  table_name = 'source_minor_location' AND column_name = 'proxy_profile')
BEGIN
	ALTER TABLE source_minor_location ADD proxy_profile INT
END