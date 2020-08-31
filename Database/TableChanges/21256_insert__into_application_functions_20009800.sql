--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 20009800)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (20009800, 'Calculate Imbalance', 'Calculate Imbalance', NULL, '_scheduling_delivery/calculate_imbalance/calculate.imbalance.php', NULL, NULL, 0)
	PRINT ' Inserted 20009800 - Calculate Imbalance.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 20009800 - Calculate Imbalance already EXISTS.'
END