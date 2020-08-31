IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106800)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10106800, 'Calendar', 'Calendar', 10100000, NULL)
 	PRINT ' Inserted 10106800 - Calendar.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106800 - Calendar already EXISTS.'
END