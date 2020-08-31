IF COL_LENGTH('user_defined_tables','is_system') IS NULL
	ALTER TABLE user_defined_tables ADD is_system BIT