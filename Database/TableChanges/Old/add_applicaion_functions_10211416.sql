IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211416)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211416, 'Add/Save', 'Add/Save', 10211415, NULL )
	PRINT 'INSERTED 10211416 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211416 - Add/Save already EXISTS.'
END
