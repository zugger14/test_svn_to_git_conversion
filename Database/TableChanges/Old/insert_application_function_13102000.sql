IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13102000)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13102000, 'Generic Mapping', 'Generic Mapping', 10100000, NULL)
 	PRINT ' Inserted 13102000 - Generic Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13102000 - Generic Mapping already EXISTS.'
END	


