IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 20001200)
BEGIN
	UPDATE setup_menu SET parent_menu_id = 10104099 WHERE function_id = 20001200
END