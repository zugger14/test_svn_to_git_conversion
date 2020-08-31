--Update application_functions
UPDATE application_functions
	SET function_name = 'Add/Save',
		function_desc = 'Setup Renewable Generators Edit',
		func_ref_id = 12101700,
		file_path = '',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 12101710
PRINT 'Updated Application Function.'
