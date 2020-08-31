IF COL_LENGTH('adiha_grid_definition', 'split_at') IS NULL
BEGIN
    ALTER TABLE adiha_grid_definition ADD split_at INT NULL
END
GO