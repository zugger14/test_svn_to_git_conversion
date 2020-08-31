IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101180)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101180, 'Maintain Definition System User IU', 'Maintain Definition System User IU', 10101100, 'windowMaintainDefinitionSystemUserIU')
 	PRINT ' Inserted 10101180 - Maintain Definition System User IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101180 - Maintain Definition System User IU already EXISTS.'
END