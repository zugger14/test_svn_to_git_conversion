--Update application_functions
UPDATE application_functions
	SET function_name = 'Base Transportation Deals',
		function_desc = 'Base Transportation Deals',
		func_ref_id = NULL,
		file_path = '',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 10163760
PRINT 'Updated Application Function.'