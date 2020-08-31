--Update application_functions
UPDATE application_functions
	SET function_name = 'Assignment',
		function_desc = 'Assignment Form',
		func_ref_id = NULL,
		file_path = '',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 12101720
PRINT 'Updated Application Function.'