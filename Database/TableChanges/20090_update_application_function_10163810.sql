--Update application_functions
UPDATE application_functions
	SET function_name = 'Save',
		function_desc = 'Save',
		func_ref_id = 10163800,
		file_path = '',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 10163810
PRINT 'Updated Application Function.'