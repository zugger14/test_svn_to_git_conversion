IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106300 AND product_category = 10000000)
BEGIN
DELETE FROM 
setup_menu
WHERE function_id = 10106300 AND product_category = 10000000
END

IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106300)
BEGIN
DELETE FROM application_functional_users WHERE function_id = 10106300
DELETE FROM application_functions
WHERE function_id = 10106300
END

