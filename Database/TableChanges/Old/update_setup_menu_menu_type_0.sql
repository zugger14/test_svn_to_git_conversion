IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10183000)
BEGIN
	UPDATE setup_menu
	SET menu_type = 0 WHERE function_id = 10183000 
END

IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 10183200)
BEGIN
	UPDATE setup_menu
	SET menu_type = 0 WHERE function_id = 10183200 
END