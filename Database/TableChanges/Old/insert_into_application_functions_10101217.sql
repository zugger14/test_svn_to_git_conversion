IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101217)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101217, 'Strategy Property', 'Strategy Property', 10101200, NULL)
 	PRINT ' Inserted 10101217 - Strategy Property.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101217 - Strategy Property already EXISTS.'
END
