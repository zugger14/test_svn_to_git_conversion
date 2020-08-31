IF COL_LENGTH(N'user_defined_tables', N'udt_hash') IS NULL
BEGIN
	ALTER TABLE user_defined_tables
	ADD udt_hash VARCHAR(150)
END

IF COL_LENGTH(N'user_defined_tables_metadata', N'udt_column_hash') IS NULL
BEGIN
	ALTER TABLE user_defined_tables_metadata
	ADD udt_column_hash VARCHAR(150)
END