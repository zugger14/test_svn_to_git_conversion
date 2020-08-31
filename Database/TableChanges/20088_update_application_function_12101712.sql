--Update application_functions
UPDATE application_functions
	SET function_name = 'Setup Source Group',
		function_desc = 'Setup Source Group',
		func_ref_id = NULL,
		file_path = '',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 12101712
PRINT 'Updated Application Function.'
