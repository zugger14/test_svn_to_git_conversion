IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211430)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211430, 'Charge Type Formula', 'Charge Type Formula', 10211415, NULL )
	PRINT 'INSERTED 10211430 - Charge Type Formula.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211430 - Charge Type Formula already EXISTS.'
END
