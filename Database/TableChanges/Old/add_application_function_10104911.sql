IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104911)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104911, 'Delete', 'Delete', 10104900, NULL)
 	PRINT ' Inserted 10104911 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104911 - Delete already EXISTS.'
END
