--Update application_functions
UPDATE application_functions
	SET function_name = 'View Recovery Rate',
		function_desc = 'View Recovery Rate',
		func_ref_id = NULL,
		file_path = '_valuation_risk_analysis/view_recovery_rate/view.recovery.rate.php',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 20000700
PRINT 'Updated Application Function.'

--Update setup_menu
UPDATE setup_menu
	SET display_name = 'View Recovery Rate',
		parent_menu_id = 10181099,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 20000700
		AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'
                    