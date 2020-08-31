IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104800 AND product_category = 10000000)
BEGIN
UPDATE setup_menu
SET display_name = 'Setup Import/Export'
WHERE function_id = 10104800 AND product_category = 10000000
END

