IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104612)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104612, 'Maintain Settlement Netting Group Detail', 'Maintain Settlement Netting Group Detail', 10104600, NULL)
 	PRINT ' Inserted 10104612 - Maintain Settlement Netting Group Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104612 - Maintain Settlement Netting Group Detail already EXISTS.'
END