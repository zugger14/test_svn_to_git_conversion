IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163911)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163911, 'Route Group Delete', 'Route Group Delete', 10163900, NULL)
 	PRINT ' Inserted 10163911 - Route Group Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163911 - Route Group Delete already EXISTS.'
END