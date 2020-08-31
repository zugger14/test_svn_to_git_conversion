IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161112)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161112, 'Rate Schedule', 'Rate Schedule', 10161110, NULL)
 	PRINT ' Inserted 10161112 - Rate Schedule.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161112 - Rate Schedule already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161113)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161113, 'Delete Rate Schedule', 'Delete Rate Schedule', 10161110, NULL)
 	PRINT ' Inserted 10161113 - Delete Rate Schedule.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161113 - Delete Rate Schedule already EXISTS.'
END
