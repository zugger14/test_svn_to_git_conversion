IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10105300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10105300, 'Deal Detail Lock', 'Deal Detail Lock', 10100000, NULL)
 	PRINT ' Inserted 10105300 - Deal Detail Lock.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10105300 - Deal Detail Lock already EXISTS.'
END
