IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12101516)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (12101516, 'Maintain Emissions Source/Sinks IU', 'Maintain Emissions Source/Sinks IU', 12101500, NULL)
 	PRINT ' Inserted 12101516 - Maintain Emissions Source/Sinks IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12101516 - Maintain Emissions Source/Sinks IU already EXISTS.'
END	