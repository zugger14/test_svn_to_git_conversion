IF COL_LENGTH('state_properties_details', 'banking_years') IS NULL
BEGIN
	ALTER TABLE state_properties_details ADD banking_years INT NULL
END

GO