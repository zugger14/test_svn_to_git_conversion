IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122500)
BEGIN
	UPDATE application_functions 
		SET file_path = '_compliance_management/setup_alerts/setup.alerts.php', 
			function_name = 'Setup Alerts',
			function_desc = 'Setup Alerts',
			function_call = 'windowSetupAlerts'
		WHERE function_id='10122500'
END
ELSE 
PRINT 'Function id 10122500 does not exists.'