IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163410)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163410, 'Add/Save', 'Add/Save', NULL, NULL )
	PRINT 'INSERTED 10163410 - Add/Save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163410 - Add/Save already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163411)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163411, 'Delete', 'Delete', NULL, NULL )
	PRINT 'INSERTED 10163411 - Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163411 - Delete already EXISTS.'
END