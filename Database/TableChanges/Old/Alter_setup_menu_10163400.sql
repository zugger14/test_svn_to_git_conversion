IF EXISTS (SELECT 1 from setup_menu WHERE window_name = 'windowSchedulesView' AND function_id = 10163400)
BEGIN
	UPDATE setup_menu
		SET display_name='View Nomination Schedule'
	WHERE function_id = 10163400
END