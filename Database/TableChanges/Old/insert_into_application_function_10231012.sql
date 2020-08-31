IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231012)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10231012, 'Maintain Inventory GL Account Type IU', 'Maintain Inventory GL Account Type IU', 10231000, NULL)
 	PRINT ' Inserted 10231012 - Maintain Inventory GL Account Type IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231012 - Maintain Inventory GL Account Type IU already EXISTS.'
END
