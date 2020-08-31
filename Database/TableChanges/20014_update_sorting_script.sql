UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'int'
WHERE
column_label in ('Channel', 'Multiplier')
AND grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'recorder_properties')

UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'int'
WHERE
column_name IN ('gre_per', 'gre_volume')
AND grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'meter_id_allocation')

UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'int'
WHERE
grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'price_curve_fv_mapping') 
AND
column_label IN ('Month From', 'Month To')

UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'date'
WHERE
column_name IN ('production_month')
AND grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'meter_id_allocation')