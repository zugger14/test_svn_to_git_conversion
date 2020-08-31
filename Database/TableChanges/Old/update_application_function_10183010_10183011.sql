UPDATE application_functions 
	 SET function_name = 'Monte Carlo Model Parameters Delete',
		function_desc = 'Monte Carlo Model Parameters Delete',
		func_ref_id = 10183000,
		function_call = 'windowMaintainMonteCarloModels'
		 WHERE [function_id] = 10183011
PRINT 'Updated Application Function '
UPDATE application_functions 
	 SET function_name = 'Define Monte Carlo Model Parameters IU',
		function_desc = 'Define Monte Carlo Model Parameters IU',
		func_ref_id = 10183000,
		function_call = 'windowMonteCarloModelParameter'
		 WHERE [function_id] = 10183010
PRINT 'Updated Application Function '
