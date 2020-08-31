IF COL_LENGTH('adiha_grid_columns_definition', 'sql_string') IS NOT NULL
BEGIN
  ALTER TABLE adiha_grid_columns_definition
  ALTER COLUMN sql_string varchar(5000)
END
GO