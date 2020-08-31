UPDATE application_functions 
	 SET function_name = 'Maintain Hedge Deferral Rules IU',
		function_desc = 'Setup Hedging Relationship Types IU',
		func_ref_id = 10103500,
		function_call = 'windowSetupHedgingRelationshipsTypesDetail'
		 WHERE [function_id] = 10103510
		 
PRINT 'Updated Application Function '
UPDATE application_functions 
	 SET function_name = 'Copy Maintain Hedge Deferral Rules',
		function_desc = 'Copy Hedging Relationship Types',
		func_ref_id = 10103500,
		function_call = NULL
		 WHERE [function_id] = 10103511		 
PRINT 'Updated Application Function '

UPDATE application_functions 
	 SET function_name = 'Delete Maintain Hedge Deferral Rules',
		function_desc = 'Delete Setup Hedging Relationship Types',
		func_ref_id = 10103500,
		function_call = NULL
		 WHERE [function_id] = 10103512
PRINT 'Updated Application Function '

UPDATE application_functions 
	 SET function_name = 'Approve Maintain Hedge Deferral Rules',
		function_desc = 'Approve Setup Hedging Relationship Types',
		func_ref_id = 10103500,
		function_call = NULL
		 WHERE [function_id] = 10103516
PRINT 'Updated Application Function '
