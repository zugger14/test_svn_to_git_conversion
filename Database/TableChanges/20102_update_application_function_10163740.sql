--Update application_functions
UPDATE application_functions
	SET function_name = 'Inject into Storage',
		function_desc = 'Inject into Storage',
		func_ref_id = 10163700,
		file_path = 'scheduling_delivery/scheduling_workbench/begining.storage.deal.php',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 10163740
PRINT 'Updated Application Function.'