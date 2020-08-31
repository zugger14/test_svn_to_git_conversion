IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10151011)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10151011, 'View Price Copy', 'View Price Copy', 10151000, NULL)
 	PRINT ' Inserted 10151011 - View Price Copy.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10151011 - View Price Copy already EXISTS.'
END