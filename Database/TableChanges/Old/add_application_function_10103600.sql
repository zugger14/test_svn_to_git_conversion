IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103600)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103600, 'Remove Data', 'Remove Data', 10100000, 'windowRemoveData')
 	PRINT ' Inserted 10103600 - Remove Data.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103600 - Remove Data already EXISTS.'
END
