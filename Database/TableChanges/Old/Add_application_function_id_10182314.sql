IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182314)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10182314, 'Financial Model Detail', 'Financial Model Detail', 10182312, 'windowContractGroupIU')
 	PRINT ' Inserted 10182314 - Financial Model Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182314 - Financial Model Detail already EXISTS.'
END
