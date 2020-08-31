IF COL_LENGTH('adiha_grid_columns_definition', 'is_hidden') IS NULL
BEGIN
    ALTER TABLE adiha_grid_columns_definition ADD is_hidden CHAR(1)
END
GO

