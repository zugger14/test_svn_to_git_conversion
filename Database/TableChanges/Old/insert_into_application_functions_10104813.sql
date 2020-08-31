IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104813)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104813, 'Data Import\Export Customized', 'Data Import\Export Customized', 10104800, '')
 	PRINT ' Inserted 10104813 - Data Import\Export Customized.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104813 - Data Import\Export Customized already EXISTS.'
END