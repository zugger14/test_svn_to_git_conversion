IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10122500)
BEGIN
	UPDATE setup_menu 
		SET display_name = 'Setup Alerts',
			window_name = 'windowSetupAlerts'
		WHERE function_id='10122500'
END
ELSE 
PRINT 'Function id 10122500 does not exists.'