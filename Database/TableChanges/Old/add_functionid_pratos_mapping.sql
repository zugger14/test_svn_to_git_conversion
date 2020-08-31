IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103100)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103100, 'Pratos Mapping', 'Pratos Mapping', 10100000, 'windowProtosMapping')
 	PRINT ' Inserted 10103100 - Pratos Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103100 - Pratos Mapping already EXISTS.'
END
