--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101900)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10101900, 'Setup Logical Trade Lock', 'Setup Logical Trade Lock', NULL, '_setup/setup_logical_trade_lock/setup.logical.trade.lock.php', NULL, NULL, 0)
	PRINT ' Inserted 10101900 - Setup Logical Trade Lock.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101900 - Setup Logical Trade Lock already EXISTS.'
END

--Update application_functions
UPDATE application_functions
	SET function_name = 'Setup Logical Trade Lock',
		function_desc = 'Setup Logical Trade Lock',
		func_ref_id = NULL,
		file_path = '_setup/setup_logical_trade_lock/setup.logical.trade.lock.php',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 10101900
PRINT 'Updated Application Function.'


--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10167200)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10167200, 'Forecast Parameters Mapping', 'Forecast Parameters Mapping', 10160000, '_scheduling_delivery/forecast_parameters_mapping/forecast.parameters.mapping.php', NULL, NULL, 0)
	PRINT ' Inserted 10167200 - Forecast Parameters Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10167200 - Forecast Parameters Mapping already EXISTS.'
END


--Update application_functions
UPDATE application_functions
	SET function_name = 'Forecast Parameters Mapping',
		function_desc = 'Forecast Parameters Mapping',
		func_ref_id = 10160000,
		file_path = '_scheduling_delivery/forecast_parameters_mapping/forecast.parameters.mapping.php',
		function_parameter = NULL,
		module_type = NULL,
		book_required = 0
		WHERE [function_id] = 10167200
PRINT 'Updated Application Function.'

