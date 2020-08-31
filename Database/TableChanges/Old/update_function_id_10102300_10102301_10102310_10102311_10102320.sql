UPDATE application_functions 
	 SET function_name = 'Run Power Bidding Nomination Report',
		function_desc = 'Run Power Bidding Nomination Report',
		func_ref_id = 10140000,
		function_call = 'windowPowerBiddingNominationReport'
		 WHERE [function_id] = 10142300
PRINT 'Updated Application Function '
UPDATE application_functions 
	 SET function_name = 'Power Bidding Nomination Calc',
		function_desc = 'Power Bidding Nomination Calc',
		func_ref_id = 10142300,
		function_call = 'windowPowerBiddingNominationReport'
		 WHERE [function_id] = 10142301
PRINT 'Updated Application Function '
UPDATE application_functions 
	 SET function_name = 'Power Bidding Nomination Copy',
		function_desc = 'Power Bidding Nomination Copy',
		func_ref_id = 10142300,
		function_call = 'windowPowerBiddingNominationReport'
		 WHERE [function_id] = 10142310
PRINT 'Updated Application Function '
UPDATE application_functions 
	 SET function_name = 'Power Bidding Nomination Order',
		function_desc = 'Power Bidding Nomination Order',
		func_ref_id = 10142300,
		function_call = 'windowPowerBiddingNominationReport'
		 WHERE [function_id] = 10142311
PRINT 'Updated Application Function '
UPDATE application_functions 
	 SET function_name = 'Exclude ST dates',
		function_desc = 'Exclude ST dates',
		func_ref_id = 10142300,
		function_call = 'windowExcludeSTDates'
		 WHERE [function_id] = 10142320
PRINT 'Updated Application Function '
