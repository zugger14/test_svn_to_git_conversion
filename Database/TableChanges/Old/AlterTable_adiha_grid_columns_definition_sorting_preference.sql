IF COL_LENGTH('adiha_grid_columns_definition', 'sorting_preference') IS NULL
BEGIN
    ALTER TABLE adiha_grid_columns_definition ADD sorting_preference VARCHAR(20)
END
GO

UPDATE adiha_grid_columns_definition SET sorting_preference = 'str' WHERE sorting_preference IS NULL
