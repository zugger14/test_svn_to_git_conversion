UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'from_no_of_months' AND agd.grid_name = 'var_time_bucket_mapping'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'to_no_of_months' AND agd.grid_name = 'var_time_bucket_mapping'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'map_no_of_months' AND agd.grid_name = 'price_curve_fv_mapping'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'from_no_of_months' AND agd.grid_name = 'var_time_bucket_mapping'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'to_no_of_months' AND agd.grid_name = 'var_time_bucket_mapping'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'map_no_of_months' AND agd.grid_name = 'var_time_bucket_mapping'

