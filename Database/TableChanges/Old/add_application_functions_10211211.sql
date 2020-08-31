IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211211)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10211211, 'Delete Maintain Contract', 'Delete Maintain Contract', 10211200, NULL)
 	PRINT ' Inserted 10211211 - Delete Maintain Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211211 - Delete Maintain Contract already EXISTS.'
END
