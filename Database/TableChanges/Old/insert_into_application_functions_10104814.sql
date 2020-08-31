IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104814)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104814, 'Data Import\Export Relations', 'Data Import\Export Relations', 10104800, '')
 	PRINT ' Inserted 10104814 - Data Import\Export Relations.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104814 - Data Import\Export Relations already EXISTS.'
END