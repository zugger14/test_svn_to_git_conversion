IF COL_LENGTH('dbo.state_properties', 'program_scope') IS NULL
BEGIN
	ALTER TABLE state_properties
	ADD program_scope INT NULL
	REFERENCES dbo.static_data_value(value_id)
END

 