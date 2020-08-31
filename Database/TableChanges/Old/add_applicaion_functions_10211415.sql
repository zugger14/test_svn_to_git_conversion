IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211415)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211415, 'Charge Type', 'Charge Type', 10211400, NULL )
	PRINT 'INSERTED 10211415 - Charge Type.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211415 - Charge Type already EXISTS.'
END
