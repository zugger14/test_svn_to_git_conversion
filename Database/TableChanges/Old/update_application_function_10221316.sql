UPDATE application_functions
	SET function_name = 'Unfinalize',
		function_desc = 'Unfinalize',
		func_ref_id = 10221300,
		file_path = '',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 10221316
PRINT 'Updated Application Function.'