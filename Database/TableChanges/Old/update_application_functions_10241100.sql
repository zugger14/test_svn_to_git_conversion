UPDATE application_functions 
	 SET function_name = 'Apply Cash',
		function_desc = 'Apply Cash',
		func_ref_id = 10220000,
		function_call = 'windowApplyCash',
		file_path = '_settlement_billing/apply_cash/apply.cash.php'
		 WHERE [function_id] = 10241100
PRINT 'Updated Application Function '