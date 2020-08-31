IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10202100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10202100, 'Run Message Board Log Report', 'Run Message Board Log Report', 15180000, 'windowMessageBoardLogReport')
 	PRINT ' Inserted 10202100 - Run Message Board Log Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10202100 - Run Message Board Log Report already EXISTS.'
END
