UPDATE application_functions
SET
function_name = 'Customize Menu'
WHERE
function_id = 10111200


UPDATE
setup_menu
SET
display_name = 'Customize Menu'
WHERE
function_id = 10111200
AND product_category = 10000000