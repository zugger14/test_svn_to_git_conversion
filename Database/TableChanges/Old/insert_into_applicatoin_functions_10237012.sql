IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237012)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237012, 'Maintain Manual Journal Entries Detail', 'Maintain Manual Journal Entries Detail', 10237000, NULL)
 	PRINT ' Inserted 10237012 - Maintain Manual Journal Entries Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237012 - Maintain Manual Journal Entries Detail already EXISTS.'
END
