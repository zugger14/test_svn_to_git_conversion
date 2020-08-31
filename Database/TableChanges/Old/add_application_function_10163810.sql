IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163810)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163810, 'Add/Save', 'Add/Save', 10163800, NULL )
	PRINT 'INSERTED 10163810 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163810 - Add/Save already EXISTS.'
END
