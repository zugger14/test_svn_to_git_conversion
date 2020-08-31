UPDATE application_functions 
	 SET function_name = 'Maintain Hedge Deferral Rules',
		function_desc = 'Maintain Hedge Deferral Rules',
		func_ref_id = 10100000,
		function_call = 'windowSetupHedgingRelationshipsTypes'
		 WHERE [function_id] = 10103500
PRINT 'Updated Application Function'
