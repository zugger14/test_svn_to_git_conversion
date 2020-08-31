IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104815)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104815, 'Data Import\Export Tables Select', 'Data Import\Export Tables Select', 10104800, '')
 	PRINT ' Inserted 10104815 - Data Import\Export Tables Select.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104815 - Data Import\Export Tables Select already EXISTS.'
END
