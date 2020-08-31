IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161510)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161510, 'Maintain Source Generator IU', 'Maintain Source Generator IU', 10161500, 'windowMaintainRecGeneratorIU')
 	PRINT ' Inserted 10161510 - Maintain Source Generator IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161510 - Maintain Source Generator IU already EXISTS.'
END