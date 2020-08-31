IF COL_LENGTH('user_defined_tables_metadata','effective_date_filter') IS NULL
	ALTER TABLE user_defined_tables_metadata ADD effective_date_filter BIT

IF COL_LENGTH('user_defined_tables_metadata','required_filter') IS NULL
	ALTER TABLE user_defined_tables_metadata ADD required_filter BIT