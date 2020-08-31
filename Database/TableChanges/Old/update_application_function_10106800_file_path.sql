IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106800)
BEGIN
	UPDATE af
	SET file_path = '_setup/setup_calendar/calendar.php'
	FROM application_functions af
	WHERE function_id = 10106800
END