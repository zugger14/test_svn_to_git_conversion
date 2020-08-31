IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101721)
BEGIN
	INSERT INTO application_functions(function_id, function_name, file_path, book_required)
	VALUES (12101721, 'Assignment Form Details', '_models_and_activity/setup_renewable_source/assignment.percent.details.php', 0)
END