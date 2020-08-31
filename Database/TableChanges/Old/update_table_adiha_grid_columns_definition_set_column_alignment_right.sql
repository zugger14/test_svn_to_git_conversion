IF COL_LENGTH(N'adiha_grid_columns_definition', 'column_alignment') IS NOT NULL
BEGIN
	UPDATE adiha_grid_columns_definition SET column_alignment = 'right'  WHERE field_type IN ('ron','ro_no','ro_p')
	PRINT 'Column column_alignment Updated for field type ron,ro_no,ro_p'
END
ELSE
BEGIN
	PRINT 'Column column_alignment Does not exists'
END