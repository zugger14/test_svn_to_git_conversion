IF COL_LENGTH('user_defined_tables_metadata', 'reference_column') IS NULL
BEGIN
	ALTER TABLE user_defined_tables_metadata
	/**
	Columns 
	reference_column: column that will reference another table
	*/
	ADD reference_column BIT
	PRINT 'Column reference_column added in table user_defined_tables_metadata.'
END
ELSE
BEGIN
	PRINT 'Column reference_column already exists in table user_defined_tables_metadata.'
END