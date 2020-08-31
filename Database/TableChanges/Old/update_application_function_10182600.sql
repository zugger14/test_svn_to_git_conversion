UPDATE application_functions 
	 SET function_name = 'Calculate Financial Forecast',
		function_desc = 'Calculate Financial Forecast',
		func_ref_id = 10180000,
		function_call = 'windowWhatIfScenarioReport'
		 WHERE [function_id] = 10182600
PRINT 'Updated Application Function '
