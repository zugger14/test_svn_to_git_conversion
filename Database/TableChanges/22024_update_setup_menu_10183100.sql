
UPDATE setup_menu
SET display_name = 'Run Price Simulation'
FROM setup_menu 
WHERE function_id = 10183100
AND product_category = 10000000

UPDATE application_functions
SET function_name = 'Run Price Simulation'
, function_desc = 'Run Price Simulation'
FROM application_functions 
WHERE function_id = 10183100