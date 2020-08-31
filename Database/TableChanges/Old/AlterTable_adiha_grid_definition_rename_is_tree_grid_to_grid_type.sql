IF COL_LENGTH('adiha_grid_definition', 'is_tree_grid') IS NOT NULL
BEGIN
   EXEC SP_RENAME 'adiha_grid_definition.[is_tree_grid]' , 'grid_type', 'COLUMN'
END
GO

-- 'g' - grid 't' - tree grid - 'a' - accordion
UPDATE adiha_grid_definition
SET grid_type = CASE WHEN ISNULL(grid_type, 'n') = 'n' THEN 'g' WHEN ISNULL(grid_type, 'n') = 'y' THEN 't' ELSE 'a' END

