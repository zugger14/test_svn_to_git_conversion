IF COL_LENGTH('adiha_grid_definition', 'is_tree_grid') IS NOT NULL
BEGIN
	ALTER TABLE adiha_grid_definition
	DROP COLUMN is_tree_grid
END
GO