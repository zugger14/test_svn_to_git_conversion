IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161400, 'Gas Storage Position Report', 'Gas Storage Position Report', 10202200, 'windowRunStoragePositionReport')
 	PRINT ' Inserted 10106400 - Gas Storage Position Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106400 - Gas Storage Position Report already EXISTS.'
END