IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163910)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163910, 'Route Group IU', 'Route Group IU', 10163900, NULL)
 	PRINT ' Inserted 10163910 - Route Group IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163910 - Route Group IU already EXISTS.'
END