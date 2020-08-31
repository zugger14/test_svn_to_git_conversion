IF COL_LENGTH('adiha_grid_definition', 'is_tree_grid') IS NULL
BEGIN
    ALTER TABLE adiha_grid_definition ADD is_tree_grid CHAR(1)
END
GO

IF COL_LENGTH('adiha_grid_definition', 'grouping_column') IS NULL
BEGIN
    ALTER TABLE adiha_grid_definition ADD grouping_column VARCHAR(500)
END
GO

