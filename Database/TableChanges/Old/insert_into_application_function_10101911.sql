IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101911)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101911, 'Delete', 'Delete Deal Lock', 10101900, NULL)
 	PRINT ' Inserted 10101911 - Delete Deal Lock.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101911 - Delete Deal Lock already EXISTS.'
END
