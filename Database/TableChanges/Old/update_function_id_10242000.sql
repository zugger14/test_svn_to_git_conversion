UPDATE application_functions
	 SET function_name = 'De-designation by Dynamic Limit',
		function_desc = 'De-designation by Dynamic Limit',
		func_ref_id = 13140000,
		function_call = NULL
WHERE [function_id] = 10242000
PRINT 'Updated Application Function '
