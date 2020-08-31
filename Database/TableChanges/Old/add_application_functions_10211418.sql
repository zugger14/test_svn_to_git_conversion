IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211418)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211418, 'Map GL Code', 'Map GL Code', 10211415, NULL )
	PRINT 'INSERTED 10211418 - Map GL Code.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211418 - Map GL Code already EXISTS.'
END
