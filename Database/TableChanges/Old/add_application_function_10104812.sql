IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104812)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104812, 'Data Import\Export Run', 'Data Import\Exportr Run', 10104800, '')
 	PRINT ' Inserted 10104812 - Data Import\Export Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104812 - Data Import\Export Run already EXISTS.'
END
