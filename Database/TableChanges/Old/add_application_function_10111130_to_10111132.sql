IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111130)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10111130, 'Privilege', 'Privilege', 10111100, NULL)
 	PRINT ' Inserted 10111130 - Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111130 - Privilege already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111131)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10111131, 'Add/Save', 'Add privilege to role', 10111130, NULL)
 	PRINT ' Inserted 10111131 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111131 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111132)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10111132, 'Delete', 'Delete privilege from role', 10111130, NULL)
 	PRINT ' Inserted 10111132 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111132 - Delete already EXISTS.'
END