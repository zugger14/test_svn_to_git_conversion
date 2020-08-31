IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104222)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104222, 'Edit All Fields Properties Detail', 'Edit All Fields Properties Detail', 10104215, 'windowEditAllFieldsDetail')
 	PRINT ' Inserted 10104222 - Edit All Fields Properties Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104222 - Edit All Fields Properties Detail already EXISTS.'
END