--Update application_functions
UPDATE application_functions
	SET function_name = 'View/Edit Meter Data',
		function_desc = 'View/Edit Meter Data',
		func_ref_id = NULL,
		file_path = '_settlement_billing/update_meter_data/update.meter.data.php',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 20001800
PRINT 'Updated Application Function.'

--Update setup_menu
UPDATE setup_menu
	SET display_name = 'View/Edit Meter Data',
		parent_menu_id = 10150000,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 20001800
		AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'
                    