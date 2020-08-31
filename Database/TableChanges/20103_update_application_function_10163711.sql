--Update application_functions
UPDATE application_functions
	SET func_ref_id = NULL
		WHERE [function_id] = 10163711
PRINT 'Updated Application Function.'