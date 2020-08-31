IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104221)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104221, 'Edit All Fields Properties', 'Edit All Fields Properties', 10104215, 'windowEditAllFields')
 	PRINT ' Inserted 10104221 - Edit All Fields Properties.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104221 - Edit All Fields Properties already EXISTS.'
END