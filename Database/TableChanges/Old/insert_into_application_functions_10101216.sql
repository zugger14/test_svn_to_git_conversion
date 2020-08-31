IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101216)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101216, 'Subsidiary Property', 'Subsidiary Property', 10101200, NULL)
 	PRINT ' Inserted 10101216 - Subsidiary Property.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101216 - Subsidiary Property already EXISTS.'
END
