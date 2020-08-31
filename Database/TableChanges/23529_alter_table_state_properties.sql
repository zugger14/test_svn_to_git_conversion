IF COL_LENGTH('dbo.state_properties', 'current_next_year') IS NULL
BEGIN
	ALTER TABLE state_properties
	ADD current_next_year NCHAR(1) NULL
END

 