--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10167400)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10167400, 'Run Forecasting', 'Run Forecasting', NULL, '_scheduling_delivery/run_forecasting/run.forecasting.php', NULL, NULL, 0)
	PRINT ' Inserted 10167400 - Run Forecasting.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10167400 - Run Forecasting already EXISTS.'
END

--Insert into setup_menu
IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = 10167400 AND sm.product_category = 10000000)
BEGIN
	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, hide_show, menu_type, menu_order, product_category)
	VALUES (10167400, 'Run Forecasting', 10106499, 1, 0, 0, 10000000)
	PRINT ' Setup Menu 10167400 inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Menu 10167400 already EXISTS.'
END


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10167410)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10167410, 'Run', 'Run', 10167400, '', NULL, NULL, 0)
	PRINT ' Inserted 10167410 - Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10167410 - Run already EXISTS.'
END