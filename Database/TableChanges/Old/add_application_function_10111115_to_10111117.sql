IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111115)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10111115, 'Users', 'Users', 10111100, NULL)
 	PRINT ' Inserted 10111115 - Users.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111115 - Users already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111116)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10111116, 'Add/Save', 'Add users to role', 10111115, NULL)
 	PRINT ' Inserted 10111116 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111116 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111117)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10111117, 'Delete', 'Delete users from role', 10111115, NULL)
 	PRINT ' Inserted 10111117 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111117 - Delete already EXISTS.'
END

