IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10241100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10241100, 'Apply Cash', 'Apply Cash', 10220000, 'windowApplyCash')
 	PRINT ' Inserted 10241100 - Apply Cash.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10241100 - Apply Cash already EXISTS.'
END
