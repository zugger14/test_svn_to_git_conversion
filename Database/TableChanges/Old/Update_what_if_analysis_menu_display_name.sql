IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id=10183400)
BEGIN
	UPDATE setup_menu SET display_name = 'Run What If Analysis' WHERE function_id = 10183400
	PRINT 'Menu name updated'
END