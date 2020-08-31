IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104610)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104610, 'Maintain Settlement Netting Group IU', 'Maintain Settlement Netting Group IU', 10104600, NULL)
 	PRINT ' Inserted 10104610 - Maintain Settlement Netting Group IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104610 - Maintain Settlement Netting Group IU already EXISTS.'
END