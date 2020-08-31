IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161500)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161500, 'Maintain Source Generator', 'Maintain Source Generator', 10100000, 'windowMaintainSourceGenerator')
 	PRINT ' Inserted 10161500 - Maintain Source Generator.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161500 - Maintain Source Generator already EXISTS.'
END