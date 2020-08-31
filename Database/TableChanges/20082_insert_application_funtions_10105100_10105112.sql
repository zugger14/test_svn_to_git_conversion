IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105100)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105100, 'Regression Testing', 'Regression Testing', NULL, '_setup/regression_testing/regression.testing.php', NULL, NULL, 0)
	PRINT ' Inserted 10105100 - Regression Testing.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105100 - Regression Testing already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105110)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105110, 'Regression Testing IU', 'Regression Testing IU', 10105100, '', NULL, NULL, 0)
	PRINT ' Inserted 10105110 - Regression Testing IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105110 - Regression Testing IU already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105111)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105111, 'Regression Testing Delete', 'Regression Testing Delete', 10105100, '', NULL, NULL, 0)
	PRINT ' Inserted 10105111 - Regression Testing Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105111 - Regression Testing Delete already EXISTS.'
END

--Insert into application_functions
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105112)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path, function_parameter, module_type, book_required)
	VALUES (10105112, 'Run Regression Testing', 'Run Regression Testing', 10105100, '', NULL, NULL, 0)
	PRINT ' Inserted 10105112 - Run Regression Testing.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105112 - Run Regression Testing already EXISTS.'
END
      