--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10167300)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10167300, 'Setup Forecast Model', 'Setup Forecast Model', NULL, '_scheduling_delivery/setup_forecast_model/setup.forecast.model.php', NULL, NULL, 0)
	PRINT ' Inserted 10167300 - Setup Forecast Model.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10167300 - Setup Forecast Model already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10167300 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10167300, 'Setup Forecast Model', 10106499, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 10167300 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10167300 already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10167310)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10167310, 'Add/Save', 'Add/Save', 10167300, '', NULL, NULL, 0)
	PRINT ' Inserted 10167310 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10167310 - Add/Save already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10167311)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10167311, 'Delete', 'Delete', 10167300, '', NULL, NULL, 0)
	PRINT ' Inserted 10167311 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10167311 - Delete already EXISTS.'
END