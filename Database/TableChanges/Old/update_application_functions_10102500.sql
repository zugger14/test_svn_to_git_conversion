UPDATE application_functions 
	 SET function_name = 'Add/Save',
		function_desc = 'Add/Save',
		func_ref_id = 10102500,
		function_call = 'windowSetupLocationIU'
		 WHERE [function_id] = 10102510
PRINT 'Updated Application Function '
UPDATE application_functions 
	 SET function_name = 'Delete',
		function_desc = 'Delete',
		func_ref_id = 10102500,
		function_call = ''
		 WHERE [function_id] = 10102511
PRINT 'Updated Application Function '