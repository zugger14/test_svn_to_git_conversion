IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211417)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10211417, 'Delete', 'Delete', 10211415, NULL )
	PRINT 'INSERTED 10211417 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211417 - Delete already EXISTS.'
END
