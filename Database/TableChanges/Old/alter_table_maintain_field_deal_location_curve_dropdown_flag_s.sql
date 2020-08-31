UPDATE maintain_field_deal
SET field_type = 'd',
window_function_id = NULL, --10102510
sql_string =  'EXEC spa_source_minor_location ''s''' 
WHERE field_id = 109

UPDATE maintain_field_deal
SET field_type = 'd',
window_function_id = NULL, --10102510
sql_string =  'SELECT source_curve_def_id,curve_name FROM source_price_curve_def' 
WHERE field_id = 88


