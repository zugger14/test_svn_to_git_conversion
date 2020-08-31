IF COL_LENGTH('adiha_grid_columns_definition', 'column_order') IS NULL
BEGIN
    ALTER TABLE adiha_grid_columns_definition ADD column_order INT
END
GO



-- NOTE: PLease update the column order if columns are not ordered as expected after running the update query below.
WITH cte AS (
SELECT 
ROW_NUMBER() OVER (PARTITION BY grid_id ORDER BY column_id) row_no, agcd.column_id, agcd.column_name, agcd.grid_id
FROM adiha_grid_columns_definition agcd
) 

UPDATE agcd
SET column_order = cte.row_no
FROM adiha_grid_columns_definition agcd
INNER JOIN cte ON cte.column_id = agcd.column_id AND cte.grid_id = agcd.grid_id
WHERE column_order IS NULL