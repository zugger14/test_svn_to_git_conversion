IF COL_LENGTH('adiha_grid_definition', 'edit_permission') IS NULL
BEGIN
    ALTER TABLE adiha_grid_definition ADD edit_permission VARCHAR(100)
END
GO

IF COL_LENGTH('adiha_grid_definition', 'delete_permission') IS NULL
BEGIN
    ALTER TABLE adiha_grid_definition ADD delete_permission VARCHAR(100)
END
GO