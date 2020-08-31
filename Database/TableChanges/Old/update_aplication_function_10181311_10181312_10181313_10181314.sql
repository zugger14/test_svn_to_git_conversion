UPDATE application_functions 
	 SET function_name = 'Maintain Limits Book IU',
		function_desc = 'Maintain Limits Book IU',
		func_ref_id = 10181310,
		function_call = 'LimitTrackingBookIU'
		 WHERE [function_id] = 10181311
PRINT 'Updated Application Function '

UPDATE application_functions 
	 SET function_name = 'Delete Maintain Limits Book',
		function_desc = 'Delete Maintain Limits Book',
		func_ref_id = 10181310,
		function_call = NULL
		 WHERE [function_id] = 10181312
PRINT 'Updated Application Function '

UPDATE application_functions 
	 SET function_name = 'Maintain Limits Pos Tenor IU',
		function_desc = 'Maintain Limits Pos Tenor IU',
		func_ref_id = 10181310,
		function_call = 'LimitTrackingCurveIU'
		 WHERE [function_id] = 10181313
PRINT 'Updated Application Function '

UPDATE application_functions 
	 SET function_name = 'Delete Maintain Limits Pos Tenor',
		function_desc = 'Delete Maintain Limits Pos Tenor',
		func_ref_id = 10181310,
		function_call = NULL
		 WHERE [function_id] = 10181314
PRINT 'Updated Application Function '

