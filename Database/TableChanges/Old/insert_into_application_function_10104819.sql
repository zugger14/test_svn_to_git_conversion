IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104819)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104819, 'Data Export Column Mapping', 'Data Export Column Mapping', 10104800, '')
 	PRINT ' Inserted 10104819 - Data Export Column Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104819 - Data Export Column Mapping already EXISTS.'
END