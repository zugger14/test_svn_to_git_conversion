IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101510)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101510, 'Setup Netting Group IU', 'Setup Netting Group IU', 10101500, 'parentNetGrpDetailIU')
 	PRINT ' Inserted 10101510 - Setup Netting Group IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101510 - Setup Netting Group IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101511)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101511, 'Delete Setup Netting Group', 'Delete Setup Netting Group', 10101500, NULL)
 	PRINT ' Inserted 10101511 - Setup Parent Netting Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101511 - Delete Setup Netting Group already EXISTS.'
END
