IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104818)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104818, 'Data Import\Export Custom Column Mapping', 'Data Import\Export Custom Column Mapping', 10104800, '')
 	PRINT ' Inserted 10104818 - Data Import\Export Custom Column Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104818 - Data Import\Export Custom Column Mapping already EXISTS.'
END