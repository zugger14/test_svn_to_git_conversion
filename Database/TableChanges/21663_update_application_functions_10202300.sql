IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10202300)
BEGIN
	UPDATE application_functions
	SET file_path = '_reporting/view_report/view.report.php?mode=run_process'
	WHERE function_id = 10202300
END