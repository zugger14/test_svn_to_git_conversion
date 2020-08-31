IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105111)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105111, 'Regression Testing Delete', 'Regression Testing Delete', 10100000, '')
 	PRINT ' Inserted 10105111 - Regression Testing Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105111 - Regression Testing Delete already EXISTS.'
END
