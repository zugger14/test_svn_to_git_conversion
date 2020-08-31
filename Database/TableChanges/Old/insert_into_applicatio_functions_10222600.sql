IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10222600)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10222600, 'Send Deal Confirmation Detail', 'Send Deal Confirmation Detail', 10220000, '')
 	PRINT ' Inserted 10222600 - Send Deal Confirmation Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10222600 - Send Deal Confirmation Detail already EXISTS.'
END