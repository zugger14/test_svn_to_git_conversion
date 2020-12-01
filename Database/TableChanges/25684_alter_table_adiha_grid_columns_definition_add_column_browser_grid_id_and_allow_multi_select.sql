IF COL_LENGTH('adiha_grid_columns_definition', 'browser_grid_id') IS NULL
BEGIN
	ALTER TABLE adiha_grid_columns_definition ADD browser_grid_id VARCHAR(100)
END

IF COL_LENGTH('adiha_grid_columns_definition', 'allow_multi_select') IS NULL
BEGIN
	ALTER TABLE adiha_grid_columns_definition ADD allow_multi_select CHAR(1) DEFAULT 'n'
END