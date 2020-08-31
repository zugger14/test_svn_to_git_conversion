IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104816)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104816, 'Data Import Column Mapping', 'Data Import Column Mapping', 10104800, '')
 	PRINT ' Inserted 10104816 - Data Import Column Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104816 - Data Import Column Mapping already EXISTS.'
END
