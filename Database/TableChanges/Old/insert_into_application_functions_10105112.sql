IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105112)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105112, 'Run Regression Testing', 'Run Regression Testing', 10100000, '')
 	PRINT ' Inserted 10105112 - Run Regression Testing.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105112 - Run Regression Testing already EXISTS.'
END
