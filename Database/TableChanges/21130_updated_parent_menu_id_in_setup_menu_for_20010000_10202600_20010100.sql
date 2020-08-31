--Update menu structure for Excel Add-In
UPDATE setup_menu
SET parent_menu_id = 10200000
WHERE function_id = 20010000 AND product_category = 10000000

UPDATE setup_menu
SET parent_menu_id = 20010000
WHERE function_id = 10202600 AND product_category = 10000000

UPDATE setup_menu
SET parent_menu_id = 20010000
WHERE function_id = 20010100 AND product_category = 10000000