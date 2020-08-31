IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161511)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161511, 'Maintain Source Generator Delete', 'Maintain Source Generator Delete', 10161500, 'windowMaintainSourceGeneratorIU')
 	PRINT ' Inserted 10161511 - Maintain Source Generator Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161511 - Maintain Source Generator Delete already EXISTS.'
END