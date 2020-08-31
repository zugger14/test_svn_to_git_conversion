IF COL_LENGTH('adiha_grid_columns_definition', 'fk_table') IS NULL
BEGIN
    ALTER TABLE adiha_grid_columns_definition ADD fk_table VARCHAR(500)
END
GO

IF COL_LENGTH('adiha_grid_columns_definition', 'fk_column') IS NULL
BEGIN
    ALTER TABLE adiha_grid_columns_definition ADD fk_column VARCHAR(500)
END
GO

IF COL_LENGTH('adiha_grid_columns_definition', 'is_unique') IS NULL
BEGIN
    ALTER TABLE adiha_grid_columns_definition ADD is_unique CHAR(1)
END
GO

