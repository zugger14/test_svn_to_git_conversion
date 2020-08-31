IF COL_LENGTH('adiha_grid_columns_definition', 'column_width') IS NULL
BEGIN
    ALTER TABLE adiha_grid_columns_definition ADD column_width INT
END
GO


UPDATE adiha_grid_columns_definition 
SET column_width = 150
WHERE column_width IS NULL