IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221024)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10221024, 'Delete Settlement Dispute', 'Delete Settlement Dispute', 10221010, NULL)
 	PRINT ' Inserted 10221024 - Delete Settlement Dispute.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10221024 - Delete Settlement Dispute already EXISTS.'
END
