IF COL_LENGTH(N'adiha_grid_columns_definition', 'validation_rule') IS NULL
BEGIN
	ALTER TABLE adiha_grid_columns_definition 
		ADD validation_rule VARCHAR(50) 
		
END


