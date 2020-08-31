IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12131000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (12131000, 'Run Target Report', 'Run Target Report', 10202200, '', '')
 	PRINT ' Inserted 12131000 - 12131000.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12131000 - 12131000 already EXISTS.'
END