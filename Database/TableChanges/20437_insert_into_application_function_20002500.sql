--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20002500)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20002500, 'Deal Default Value Mapping', 'Deal Default Value Mapping', NULL, '', NULL, NULL, 0)
	PRINT ' Inserted 20002500 - Deal Default Value Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20002500 - Deal Default Value Mapping already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 20002500 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (20002500, 'Deal Default Value Mapping', 10106499, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 20002500 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 20002500 already EXISTS.'
END

--Update application_functions
UPDATE application_functions
	SET function_name = 'Deal Default Value Mapping',
		function_desc = 'Deal Default Value Mapping',
		func_ref_id = NULL,
		file_path = '_setup/deal_default_value_mapping/deal.default.value_mapping.php',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 20002500
PRINT 'Updated Application Function.'

--Update setup_menu
UPDATE setup_menu
	SET display_name = 'Deal Default Value Mapping',
		parent_menu_id = 10106499,
		menu_type = 0,
		hide_show = 1
		WHERE [function_id] = 20002500
		AND [product_category]= 10000000
PRINT 'Updated Setup Menu.'
                    