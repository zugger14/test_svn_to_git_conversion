IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105110)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105110, 'Regression Testing IU', 'Regression Testing IU', 10100000, '')
 	PRINT ' Inserted 10105110 - Regression Testing IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105110 - Regression Testing IU already EXISTS.'
END