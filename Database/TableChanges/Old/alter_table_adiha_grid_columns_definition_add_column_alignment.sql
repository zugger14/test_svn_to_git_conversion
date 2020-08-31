IF COL_LENGTH(N'adiha_grid_columns_definition', 'column_alignment') IS NULL
BEGIN
	ALTER TABLE adiha_grid_columns_definition ADD column_alignment VARCHAR(20) NOT NULL DEFAULT 'left'
	PRINT 'Column column_alignment Added'
END
ELSE
BEGIN
	PRINT 'Column column_alignment Already exists'
END