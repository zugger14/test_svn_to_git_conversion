IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10166900)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10166900, 'Shut In Volume', 'Shut In Volume', 10160000, NULL)
 	PRINT ' Inserted 10166900 - Shut In Volume.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10166900 - Shut In Volume already EXISTS.'
END



