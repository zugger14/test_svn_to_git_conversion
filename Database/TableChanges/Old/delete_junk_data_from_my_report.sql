IF EXISTS (SELECT 1 FROM my_report WHERE my_report_name = 'Run Assessment Report' AND application_function_id = 10235800)
BEGIN
	DELETE FROM my_report WHERE application_function_id = 10235800
END