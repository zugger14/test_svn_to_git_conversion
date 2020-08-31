IF COL_LENGTH('adiha_grid_definition', 'load_sql') IS NULL
BEGIN
    ALTER TABLE adiha_grid_definition ADD load_sql VARCHAR(5000)
END

IF COL_LENGTH('adiha_grid_definition', 'grid_label') IS NULL
BEGIN
    ALTER TABLE adiha_grid_definition ADD grid_label VARCHAR(500)
END
GO

