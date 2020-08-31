DELETE FROM setup_menu WHERE function_id = 10122500 AND product_category = 15000000
DELETE FROM setup_menu WHERE function_id = 10106600 AND product_category = 15000000

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10122500 AND product_category = 15000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10122500, 'Setup Advanced Workflow Rule', 1, 10106699, 15000000, 7, 0)
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10122600 AND product_category = 15000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES (10122600, 'Setup Simple Alert', 1, 10106699, 15000000, 7, 0)
END

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10106600 AND product_category = 15000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, hide_show, parent_menu_id, product_category, menu_order, menu_type)
	VALUES(10106600, 'Setup Workflow/Alert', 1, 10106699, 15000000, 7, 0)
END

UPDATE setup_menu 
SET display_name = 'Prepare and Submit GL Entry'
WHERE display_name = 'Disclosure'

UPDATE application_functions
SET func_ref_id = 10221300
WHERE function_id = 10221313

UPDATE setup_menu
SET parent_menu_id = 10202200
WHERE function_id IN (10221900, 10221200, 10201900)
AND product_category = 15000000