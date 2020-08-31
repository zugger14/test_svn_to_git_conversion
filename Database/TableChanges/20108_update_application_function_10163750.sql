--Update application_functions
UPDATE application_functions
	SET function_name = 'Match',
		function_desc = 'Match',
		func_ref_id = 10163700,
		file_path = '',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 10163750
PRINT 'Updated Application Function.'