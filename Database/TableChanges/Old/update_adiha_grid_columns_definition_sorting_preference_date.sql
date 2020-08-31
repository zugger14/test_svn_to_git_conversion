UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_label LIKE '%date %' OR agcd.column_label LIKE '% date%'